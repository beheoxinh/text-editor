#!/usr/bin/env sh
set -eu

# Uninstalls TextEditor that was installed using the install.sh script

check_remaining_installations() {
    platform="$(uname -s)"
    if [ "$platform" = "Darwin" ]; then
        # Check for any TextEditor variants in /Applications
        remaining=$(ls -d /Applications/TextEditor*.app 2>/dev/null | wc -l)
        [ "$remaining" -eq 0 ]
    else
        # Check for any TextEditor variants in ~/.local
        remaining=$(ls -d "$HOME/.local/TextEditor"*.app "$HOME/.local/gram"*.app 2>/dev/null | wc -l)
        [ "$remaining" -eq 0 ]
    fi
}

prompt_remove_preferences() {
    printf "Do you want to keep your TextEditor preferences? [Y/n] "
    read -r response
    case "$response" in
    [nN] | [nN][oO])
        rm -rf "$HOME/.config/text-editor" "$HOME/.config/gram"
        echo "Preferences removed."
        ;;
    *)
        echo "Preferences kept."
        ;;
    esac
}

main() {
    platform="$(uname -s)"
    channel="${TEXTEDITOR_CHANNEL:-${GRAM_CHANNEL:-stable}}"

    if [ "$platform" = "Darwin" ]; then
        platform="macos"
    elif [ "$platform" = "Linux" ]; then
        platform="linux"
    else
        echo "Unsupported platform $platform"
        exit 1
    fi

    "$platform"

    echo "TextEditor has been uninstalled"
}

linux() {
    suffix=""
    if [ "$channel" != "stable" ]; then
        suffix="-$channel"
    fi

    # Remove the app directory
    rm -rf "$HOME/.local/TextEditor$suffix.app" "$HOME/.local/gram$suffix.app"

    # Remove the binary symlink
    rm -f "$HOME/.local/bin/text-editor" "$HOME/.local/bin/gram"

    # Remove the .desktop file
    rm -f "$HOME/.local/share/applications/text-editor$suffix.desktop" "$HOME/.local/share/applications/gram$suffix.desktop"

    # Remove the database directory for this channel
    rm -rf "$HOME/.local/share/gram/db/0-$suffix"

    # Remove socket file
    rm -f "$HOME/.local/share/gram/gram-$suffix.sock"

    # Remove the entire TextEditor directory if no installations remain
    if check_remaining_installations; then
        rm -rf "$HOME/.local/share/gram"
        prompt_remove_preferences
    fi

    rm -rf "$HOME"/.text-editor_server
}

macos() {
    app="TextEditor.app"
    db_suffix="stable"
    app_id="app.liten.text-editor"
    case "$channel" in
    dev)
        app="TextEditor Dev.app"
        db_suffix="dev"
        app_id="app.liten.text-editor-dev"
        ;;
    esac

    # Remove the app bundle
    if [ -d "/Applications/$app" ]; then
        rm -rf "/Applications/$app"
    fi

    # Remove the binary symlink
    rm -f "$HOME/.local/bin/text-editor" "$HOME/.local/bin/gram"

    # Remove the database directory for this channel
    rm -rf "$HOME/Library/Application Support/TextEditor/db/0-$db_suffix"

    # Remove app-specific files and directories
    rm -rf "$HOME/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/$app_id.sfl"*
    rm -rf "$HOME/Library/Caches/$app_id"
    rm -rf "$HOME/Library/HTTPStorages/$app_id"
    rm -rf "$HOME/Library/Preferences/$app_id.plist"
    rm -rf "$HOME/Library/Saved Application State/$app_id.savedState"

    # Remove the entire TextEditor directory if no installations remain
    if check_remaining_installations; then
        rm -rf "$HOME/Library/Application Support/TextEditor"
        rm -rf "$HOME/Library/Logs/TextEditor"

        prompt_remove_preferences
    fi

    rm -rf "$HOME"/.text-editor_server
}

main "$@"
