#!/usr/bin/env bash
# ==============================================================================
# prepare.sh - Cài đặt môi trường và dependencies cần thiết cho TextEditor trên Linux
# Hỗ trợ: Fedora/Nobara/RHEL/CentOS, Debian/Ubuntu, Arch/Manjaro, openSUSE, Void, Gentoo
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== [1/4] Kiểm tra quyền thực thi và quyền người dùng ==="
if [ "$(id -u)" -eq 0 ]; then
    SUDO_CMD=''
else
    SUDO_CMD="$(command -v sudo || command -v sudo-rs || command -v doas || true)"
fi

echo "=== [2/4] Cài đặt dependencies hệ thống ==="
# Tận dụng script/linux của dự án đã hỗ trợ đa distro
if [ -f "script/linux" ]; then
    chmod +x script/linux
    ./script/linux
else
    echo "Lỗi: Không tìm thấy script/linux!" >&2
    exit 1
fi

echo "=== [3/4] Cài đặt / cập nhật Rust toolchain và components ==="
if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
fi

# Cài đặt target và components theo rust-toolchain.toml
if command -v rustup >/dev/null 2>&1; then
    echo "Đảm bảo target và components từ rust-toolchain.toml được cài đặt..."
    rustup show active-toolchain || true
    rustup target add wasm32-wasip2 || true
    rustup component add rustfmt clippy rust-analyzer rust-src || true
else
    echo "Cảnh báo: Không tìm thấy rustup trong PATH. Hãy đảm bảo toolchain Rust >= 1.90 đã được cấu hình."
fi

# Cài đặt cargo-about nếu chưa có (dùng để generate third-party licenses khi build bundle)
if ! command -v cargo-about >/dev/null 2>&1; then
    echo "Cài đặt cargo-about (dùng cho bước generate licenses)..."
    cargo install cargo-about@0.8.2 || cargo install cargo-about || true
fi

echo "=== [4/4] Tải WASI SDK cho extension builder ==="
if [ -f "script/download-wasi-sdk" ]; then
    chmod +x script/download-wasi-sdk
    ./script/download-wasi-sdk || echo "Bỏ qua tải WASI SDK nếu có lỗi mạng."
fi

echo ""
echo "=========================================================="
echo " Chuẩn bị môi trường hoàn tất thành công!"
echo " Bạn có thể chạy ./build.sh để build binary."
echo "=========================================================="
