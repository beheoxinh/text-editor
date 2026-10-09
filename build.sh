#!/usr/bin/env bash
# ==============================================================================
# build.sh - Triển khai các bước build dự án TextEditor ra binary hoàn chỉnh
# Tùy chọn:
#   --release (mặc định) : Build bản release được tối ưu hóa
#   --debug              : Build bản debug
#   --tarball            : Đóng gói thành text-editor-linux-<arch>.tar.gz
#   --clean              : Dọn dẹp target trước khi build
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
fi

BUILD_PROFILE="release"
DO_TARBALL=false
DO_CLEAN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --release)
            BUILD_PROFILE="release"
            shift
            ;;
        --debug)
            BUILD_PROFILE="debug"
            shift
            ;;
        --tarball)
            DO_TARBALL=true
            shift
            ;;
        --clean)
            DO_CLEAN=true
            shift
            ;;
        -h|--help)
            echo "Cách dùng: $0 [options]"
            echo "Options:"
            echo "  --release   Build bản release (mặc định)"
            echo "  --debug     Build bản debug"
            echo "  --tarball   Đóng gói .tar.gz bundle đầy đủ"
            echo "  --clean     Chạy cargo clean trước khi build"
            echo "  -h, --help  Hiển thị trợ giúp"
            exit 0
            ;;
        *)
            echo "Tham số không hợp lệ: $1" >&2
            exit 1
            ;;
    esac
done

if [ "$DO_CLEAN" = true ]; then
    echo "=== Dọn dẹp build target cũ ==="
    cargo clean
fi

# Tự động xử lý tương thích với GCC 14+ khi link
if command -v gcc >/dev/null 2>&1 && command -v clang >/dev/null 2>&1; then
    GCC_VERSION="$(gcc -dumpversion || echo 0)"
    if [ "$(printf '%s\n' "14" "$GCC_VERSION" | sort -V | head -n1)" = "14" ]; then
        export AWS_LC_SYS_CC=clang
    fi
fi

# 1. Tạo license metadata nếu chưa có hoặc cập nhật
echo "=== [1/3] Tạo licenses metadata (assets/licenses.md) ==="
if [ -f "script/generate-licenses" ]; then
    chmod +x script/generate-licenses
    ALLOW_MISSING_LICENSES=1 ./script/generate-licenses assets/licenses.md || true
fi

# 2. Build binaries (gram và cli)
echo "=== [2/3] Build TextEditor binaries (profile: $BUILD_PROFILE) ==="
CARGO_FLAGS=()
if [ "$BUILD_PROFILE" = "release" ]; then
    CARGO_FLAGS+=("--release")
fi

# Build 2 crate chính: gram (GUI app) và cli (terminal CLI launcher)
echo "Đang compile crates: gram, cli..."
cargo build "${CARGO_FLAGS[@]}" --package gram --package cli

# 3. Đóng gói hoặc xuất ra thư mục binary
echo "=== [3/3] Kiểm tra binary sau build ==="
TARGET_DIR="${CARGO_TARGET_DIR:-target}/$BUILD_PROFILE"

if [ -f "$TARGET_DIR/gram" ] && [ -f "$TARGET_DIR/cli" ]; then
    echo "Build thành công!"
    echo "  - Editor GUI binary : $TARGET_DIR/gram ($(du -h "$TARGET_DIR/gram" | cut -f1))"
    echo "  - CLI binary        : $TARGET_DIR/cli ($(du -h "$TARGET_DIR/cli" | cut -f1))"
else
    echo "Lỗi: Không tìm thấy binary trong $TARGET_DIR!" >&2
    exit 1
fi

if [ "$DO_TARBALL" = true ]; then
    echo "=== Đang đóng gói Tarball thông qua script/bundle-linux ==="
    chmod +x script/bundle-linux
    ./script/bundle-linux --tarball --no-build-remote --no-build
    echo "Tarball đã được tạo trong target/release/"
fi

echo ""
echo "=========================================================="
echo " Quá trình build hoàn thành xuất sắc!"
echo " Bạn có thể chạy ngay với: cargo run (hoặc $TARGET_DIR/cli)"
echo " Hoặc cài đặt vào hệ thống bằng: ./install.sh"
echo "=========================================================="
