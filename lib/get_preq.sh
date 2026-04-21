#!/bin/bash
set -e

echo "Installing prerequisites for building libgit2 (cross-compilation for Windows)..."

# This script assumes a Debian-based system (Ubuntu, WSL, etc.)
if command -v apt-get >/dev/null; then
    sudo apt-get update
    sudo apt-get install -y \
        build-essential \
        cmake \
        gcc-mingw-w64 \
        g++-mingw-w64 \
        binutils-mingw-w64 \
        pkg-config
else
    echo "Error: apt-get not found. Please manually install: build-essential, cmake, gcc-mingw-w64, g++-mingw-w64, and pkg-config."
    exit 1
fi

echo "Prerequisites installed successfully!"
