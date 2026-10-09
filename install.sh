#!/usr/bin/env bash
# ==============================================================================
# install.sh - Build lại dự án (nếu cần) và cài đặt TextEditor trên Linux (GNOME/Fedora...)
# 
# Các tác vụ thực hiện:
#   1. Tự động build lại release binary mới nhất (gọi ./build.sh)
#   2. Cài đặt vào $PREFIX (mặc định: ~/.local)
#      - Libexec / binary chính: $PREFIX/TextEditor.app/
#      - CLI launcher symlink : $PREFIX/bin/text-editor
#      - Desktop entry        : $PREFIX/share/applications/app.liten.text-editor.desktop
#      - Icons (SVG & PNG)    : $PREFIX/share/icons/hicolor/...
#   3. Tự động phát hiện cấu hình và tạo file .desktop chuẩn FreeDesktop / GNOME.
#   4. Cập nhật database desktop và icon cache của GNOME.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
fi

INSTALL_PREFIX="${HOME}/.local"
SKIP_BUILD=false

usage() {
    echo "Cách dùng: $0 [options]"
    echo "Options:"
    echo "  --prefix PREFIX    Đường dẫn cài đặt (mặc định: $HOME/.local)"
    echo "  --skip-build       Bỏ qua bước build lại, dùng ngay binary đã build sẵn"
    echo "  -h, --help         Hiển thị trợ giúp"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --prefix)
            shift
            [[ $# -lt 1 ]] && { echo "Thiếu PREFIX"; exit 1; }
            INSTALL_PREFIX="$1"
            shift
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Tham số không hợp lệ: $1" >&2
            exit 1
            ;;
    esac
done

# 1. Build lại dự án
if [ "$SKIP_BUILD" = false ]; then
    echo "=== [1/4] Tiến hành build lại dự án TextEditor (Release profile) ==="
    chmod +x ./build.sh
    ./build.sh --release
else
    echo "=== [1/4] Bỏ qua bước build theo yêu cầu (--skip-build) ==="
fi

TARGET_DIR="${CARGO_TARGET_DIR:-target}/release"
if [ ! -f "$TARGET_DIR/gram" ] || [ ! -f "$TARGET_DIR/cli" ]; then
    echo "Lỗi: Không tìm thấy $TARGET_DIR/gram hoặc $TARGET_DIR/cli!" >&2
    echo "Hãy chạy ./build.sh trước hoặc bỏ cờ --skip-build." >&2
    exit 1
fi

# 2. Chuẩn bị thư mục cài đặt
echo "=== [2/4] Cài đặt TextEditor vào $INSTALL_PREFIX ==="
APP_DIR="$INSTALL_PREFIX/TextEditor.app"
BIN_DIR="$INSTALL_PREFIX/bin"
SHARE_APPS_DIR="$INSTALL_PREFIX/share/applications"
SHARE_ICONS_DIR="$INSTALL_PREFIX/share/icons/hicolor"

mkdir -p "$APP_DIR/bin" "$APP_DIR/libexec" "$APP_DIR/lib"
mkdir -p "$BIN_DIR" "$SHARE_APPS_DIR"

# Copy binary và strip debug symbols để binary nhẹ và khởi động nhanh
# Sử dụng cp --remove-destination hoặc install để không bị lỗi "Text file busy" nếu app đang chạy
echo "Copy và tối ưu hóa binaries..."
cp --remove-destination "$TARGET_DIR/cli" "$APP_DIR/bin/text-editor"
cp --remove-destination "$TARGET_DIR/gram" "$APP_DIR/libexec/text-editor"

if command -v objcopy >/dev/null 2>&1; then
    objcopy --strip-debug "$APP_DIR/bin/text-editor" 2>/dev/null || true
    objcopy --strip-debug "$APP_DIR/libexec/text-editor" 2>/dev/null || true
fi

chmod 755 "$APP_DIR/bin/text-editor" "$APP_DIR/libexec/text-editor"

# Tạo symlink vào $INSTALL_PREFIX/bin/text-editor
ln -sf "$APP_DIR/bin/text-editor" "$BIN_DIR/text-editor"

# Cài đặt Icons
echo "Cài đặt biểu tượng (icons)..."
mkdir -p "$SHARE_ICONS_DIR/scalable/apps"
mkdir -p "$SHARE_ICONS_DIR/symbolic/apps"
mkdir -p "$SHARE_ICONS_DIR/512x512/apps"
mkdir -p "$SHARE_ICONS_DIR/1024x1024/apps"

if [ -f "crates/gram/resources/app.liten.text-editor.svg" ]; then
    cp "crates/gram/resources/app.liten.text-editor.svg" "$SHARE_ICONS_DIR/scalable/apps/app.liten.text-editor.svg"
fi
if [ -f "crates/gram/resources/app.liten.text-editor-symbolic.svg" ]; then
    cp "crates/gram/resources/app.liten.text-editor-symbolic.svg" "$SHARE_ICONS_DIR/symbolic/apps/app.liten.text-editor-symbolic.svg"
fi
if [ -f "crates/gram/resources/app-icon.png" ]; then
    cp "crates/gram/resources/app-icon.png" "$SHARE_ICONS_DIR/512x512/apps/app.liten.text-editor.png"
fi
if [ -f "crates/gram/resources/app-icon@2x.png" ]; then
    cp "crates/gram/resources/app-icon@2x.png" "$SHARE_ICONS_DIR/1024x1024/apps/app.liten.text-editor.png"
fi

# Đồng thời copy icon vào trong App bundle
mkdir -p "$APP_DIR/share/icons/hicolor/scalable/apps"
mkdir -p "$APP_DIR/share/icons/hicolor/512x512/apps"
[ -f "crates/gram/resources/app.liten.text-editor.svg" ] && cp "crates/gram/resources/app.liten.text-editor.svg" "$APP_DIR/share/icons/hicolor/scalable/apps/"
[ -f "crates/gram/resources/app-icon.png" ] && cp "crates/gram/resources/app-icon.png" "$APP_DIR/share/icons/hicolor/512x512/apps/text-editor.png"

# Copy license nếu có
if [ -f "assets/licenses.md" ]; then
    cp "assets/licenses.md" "$APP_DIR/licenses.md"
fi

# 3. Tạo file Desktop Entry tích hợp GNOME
echo "=== [3/4] Cấu hình Desktop Entry cho GNOME ==="
DESKTOP_FILE="$SHARE_APPS_DIR/app.liten.text-editor.desktop"

EXEC_CMD="$BIN_DIR/text-editor %U"
EXEC_NEW_CMD="$BIN_DIR/text-editor --new %U"

cat > "$DESKTOP_FILE" << 'DESKTOP_ENTRY_EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=TextEditor
GenericName=Text Editor
Comment=A powerful and modern code editor
TryExec=BIN_DIR_PLACEHOLDER/text-editor
StartupNotify=true
Exec=BIN_DIR_PLACEHOLDER/text-editor %U
Icon=app.liten.text-editor
Categories=Development;TextEditor;IDE;
Keywords=text-editor;editor;gram;code;
MimeType=text/plain;application/x-zerosize;x-scheme-handler/gram;inode/directory;
Actions=NewWorkspace;
StartupWMClass=app.liten.text-editor

[Desktop Action NewWorkspace]
Exec=BIN_DIR_PLACEHOLDER/text-editor --new %U
Name=Open a new workspace
DESKTOP_ENTRY_EOF

sed -i "s|BIN_DIR_PLACEHOLDER|$BIN_DIR|g" "$DESKTOP_FILE"
chmod 644 "$DESKTOP_FILE"

# 4. Cập nhật GNOME desktop database & icon cache
echo "=== [4/4] Cập nhật cache hệ thống (Desktop & Icon Cache) ==="
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$SHARE_APPS_DIR" 2>/dev/null || true
fi

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t "$SHARE_ICONS_DIR" 2>/dev/null || true
fi

echo ""
echo "=========================================================="
echo " Cài đặt TextEditor hoàn tất thành công!"
echo " Vị trí cài đặt:"
echo "   - App Bundle : $APP_DIR"
echo "   - CLI binary : $BIN_DIR/text-editor"
echo "   - Desktop App: $DESKTOP_FILE"
echo ""
echo " Bạn có thể chạy ứng dụng:"
echo "   1. Từ terminal: text-editor (đảm bảo $BIN_DIR có trong PATH)"
echo "   2. Từ menu ứng dụng GNOME: tìm 'TextEditor'"
echo "=========================================================="
