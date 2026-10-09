# TextEditor



<p><strong>A high-performance, lightweight, and modern code editor built with Rust and GPUI.</strong></p>

<p>
    <a href="https://github.com/beheoxinh/text-editor">GitHub Repository</a> •
    <a href="#quick-start">Quick Start</a> •
    <a href="#features">Features</a> •
    <a href="#installation">Installation</a>
  </p>
</div>

---

## Overview

**TextEditor** is a fast, responsive, and minimalist code editor crafted for developers who value performance and simplicity. Powered by Rust and hardware-accelerated GPU rendering (Vulkan/Metal/DirectX via GPUI), it delivers instant startup, smooth scrolling, and an efficient keyboard-driven development experience without bloat or telemetry.

## Features

- ⚡ **High Performance**: Native binary compiled in Rust with GPU-accelerated rendering.
- 🎨 **Modern Interface**: Clean and customizable UI with theme and icon theme support.
- 🛠️ **Language Support**: Syntax highlighting, code navigation, diagnostics, and LSP integration out of the box.
- 🐛 **Built-in Debugger**: DAP (Debug Adapter Protocol) support for interactive debugging.
- 🔀 **Integrated Git**: Source control gutter diffs, status panels, and quick staging.
- 💻 **Integrated Terminal**: Seamlessly work with CLI tools inside your editor.
- 🔒 **Privacy Focused**: No telemetry, no background tracking, no accounts required.

---

## Quick Start

### 1. Prepare Environment (Linux)

Install all necessary build tools and system dependencies:

```bash
chmod +x prepare.sh
./prepare.sh
```

### 2. Build

Compile release binaries for GUI and CLI:

```bash
chmod +x build.sh
./build.sh --release
```

### 3. Install & Desktop Integration

Install binaries into `~/.local`, generate GNOME `.desktop` launcher, and configure icons:

```bash
chmod +x install.sh
./install.sh
```

Once installed, launch the editor directly from your terminal:

```bash
text-editor [path]
```

Or open **TextEditor** from your desktop application launcher.

---

## Build Options

The build script supports customizable flags:

```bash
./build.sh --release   # Optimized release build (default)
./build.sh --debug     # Debug build for development
./build.sh --tarball   # Package bundle into .tar.gz archive
./build.sh --clean     # Clean cargo build artifacts before compiling
```

---

## License

This project is open-source and released under the [GPLv3 License](./LICENSE.md).
