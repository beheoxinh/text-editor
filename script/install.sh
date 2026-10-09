#!/usr/bin/env bash
# shellcheck shell=bash
# Installation script for Linux
set -eu

err() {
  echo "$1" >&2
  exit 1
}

has_command() {
  if ! command -v $1; then
    err "Required command not found: $1"
  fi
}

usage() {
  echo "
Usage: ${0##*/} [options] [BUNDLE]
Install TextEditor on Linux from a tar bundle.

Options:
  -h, --help          Display this help and exit.
  --build             Build the tar bundle before installation.
  --build-remote      Build the `remote_server` binary
  --prefix PREFIX     Install into PREFIX (default ~/.local).
  "
}

TEXTEDITOR_BUILD_TARBALL=false
TEXTEDITOR_BUILD_REMOTE=false
TEXTEDITOR_INSTALL_PREFIX="$HOME/.local"
TEXTEDITOR_BUNDLE_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --build)
            TEXTEDITOR_BUILD_TARBALL=true
            shift
            ;;
        --build-remote)
            TEXTEDITOR_BUILD_REMOTE=true
            shift
            ;;
        --prefix)
            shift
            [[ $# -lt 1 ]] && err "Expected PREFIX"
            TEXTEDITOR_INSTALL_PREFIX="$1"
            shift
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            help_info
            exit 1
            ;;
        *)
            if [[ $# -gt 1 ]]; then
              err "Too many arguments, expected [BUNDLE]"
            fi
            if [[ $# -eq 1 ]]; then
              TEXTEDITOR_BUNDLE_FILE="$1"
              shift
            fi
            ;;
    esac
done

version=$(
  curl -s -X GET -H 'accept: application/json' https://codeberg.org/api/v1/repos/GramEditor/gram/releases/latest \
    | grep -o '"tag_name":"[^"]\+"' \
    | sed -e 's,"tag_name":"\([^"]\+\)",\1,g'
)

host_line="$(rustc --version --verbose | grep "host")"
target_triple=${host_line#*: }
arch="$(echo $target_triple | awk -F - '{print $1}')"

target_dir="${CARGO_TARGET_DIR:-target}"

if [[ "$TEXTEDITOR_BUILD_TARBALL" = "true" ]]; then
  no_build_flag=""
  if [ "$TEXTEDITOR_BUILD_REMOTE" = false ]; then
    no_build_flag="--no-build-remote"
  fi

  ./script/bundle-linux --tarball $no_build_flag
  TEXTEDITOR_BUNDLE_FILE="${target_dir}/release/text-editor-linux-$arch.tar.gz"
elif [ "$TEXTEDITOR_BUNDLE_FILE" = "" ]; then
  TEXTEDITOR_BUNDLE_FILE="text-editor-linux-$arch-$version.tar.gz"
  curl --skip-existing -L -O https://codeberg.org/GramEditor/gram/releases/download/"$version"/"$TEXTEDITOR_BUNDLE_FILE"
fi
[[ ! -f "$TEXTEDITOR_BUNDLE_FILE" ]] && err "$TEXTEDITOR_BUNDLE_FILE not found, exiting..."

channel=stable
if tar ztf "$TEXTEDITOR_BUNDLE_FILE" | head -1 | grep -q "dev"; then
  channel=dev
fi
appid="app.liten.text-editor"
suffix=""
if [ "$channel" != "stable" ]; then
  suffix="-$channel"
  appid="app.liten.text-editor-dev"
fi
mkdir -p "$TEXTEDITOR_INSTALL_PREFIX/TextEditor$suffix.app"
mkdir -p "$TEXTEDITOR_INSTALL_PREFIX/bin" "$TEXTEDITOR_INSTALL_PREFIX/share/applications"
tar -xzf "$TEXTEDITOR_BUNDLE_FILE" -C "$TEXTEDITOR_INSTALL_PREFIX/"

ln -sf "$TEXTEDITOR_INSTALL_PREFIX/TextEditor$suffix.app/bin/text-editor" "$HOME/.local/bin/text-editor"

desktop_file_path="$TEXTEDITOR_INSTALL_PREFIX/share/applications/${appid}.desktop"
src_dir="$TEXTEDITOR_INSTALL_PREFIX/TextEditor$suffix.app/share/applications"
cp "$src_dir/text-editor${suffix}.desktop" "${desktop_file_path}"

sed -i -e "s|Icon=text-editor|Icon=$TEXTEDITOR_INSTALL_PREFIX/TextEditor$suffix.app/share/icons/hicolor/512x512/apps/text-editor.png|g" "${desktop_file_path}"
sed -i -e "s|Exec=text-editor|Exec=$TEXTEDITOR_INSTALL_PREFIX/TextEditor$suffix.app/bin/text-editor|g" "${desktop_file_path}"

echo "Installation to $TEXTEDITOR_INSTALL_PREFIX complete."

