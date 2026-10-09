# Uninstall

This guide covers how to uninstall TextEditor on different operating systems.

## macOS

### Bundle compilation

If you installed TextEditor by compiling it using the `script/bundle-mac` command:

1. Quit TextEditor if it's running
2. Open Finder and go to your Applications folder
3. Drag TextEditor to the Trash (or right-click and select "Move to Trash")
4. Empty the Trash

### Removing User Data (Optional)

To completely remove all TextEditor configuration files and data:

1. Open Finder
2. Press `Cmd + Shift + G` to open "Go to Folder"
3. Delete the following directories if they exist:
   - `~/Library/Application Support/TextEditor`
   - `~/Library/Saved Application State/app.liten.text-editor.savedState`
   - `~/Library/Logs/TextEditor`
   - `~/Library/Caches/app.liten.text-editor`

## Linux

### Standard Uninstall

If TextEditor was installed using the default installation script, run:

```sh
text-editor --uninstall
```

You'll be prompted whether to keep or delete your preferences. After making a
choice, you should see a message that TextEditor was successfully uninstalled.

If the `text-editor` command is not found in your PATH, try:

```sh
$HOME/.local/bin/text-editor --uninstall
```

or:

```sh
$HOME/.local/TextEditor.app/bin/text-editor --uninstall
```

### Package Manager

If you installed TextEditor using a package manager (such as Flatpak or a
distribution-specific package manager), consult that package manager's
documentation for uninstallation instructions.

### Manual Removal

If the uninstall command fails or TextEditor was installed to a custom location, you
can manually remove:

- Installation directory: `~/.local/TextEditor.app` (or your custom installation path)
- Binary symlink: `~/.local/bin/text-editor`
- Configuration and data: `~/.config/text-editor`

## Windows

### Standard Installation

1. Quit TextEditor if it's running
2. Open Settings (Windows key + I)
3. Go to "Apps" > "Installed apps" (or "Apps & features" on Windows 10)
4. Search for "TextEditor"
5. Click the three dots menu next to TextEditor and select "Uninstall"
6. Follow the prompts to complete the uninstallation

Alternatively, you can:

1. Open the Start menu
2. Right-click on TextEditor
3. Select "Uninstall"

### Removing User Data (Optional)

To completely remove all TextEditor configuration files and data:

1. Press `Windows key + R` to open Run
2. Type `%APPDATA%` and press Enter
3. Delete the `TextEditor` folder if it exists
4. Press `Windows key + R` again, type `%LOCALAPPDATA%` and press Enter
5. Delete the `TextEditor` folder if it exists

## Troubleshooting

If you encounter issues during uninstallation:

- **macOS/Windows**: Ensure TextEditor is completely quit before attempting to
  uninstall. Check Activity Manager (macOS) or Task Manager (Windows) for any
  running TextEditor processes.
- **Linux**: If the uninstall script fails, check the error message and consider
  manual removal of the directories listed above.
- **All platforms**: If you want to start fresh while keeping TextEditor installed,
  you can delete the configuration directories instead of uninstalling the
  application entirely.

For additional help, see the [Linux-specific documentation](./linux.md).
