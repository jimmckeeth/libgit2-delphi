#!/bin/bash
set -e

# Navigate to project root relative to this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.."

if [ ! -d "lib/libgit2" ]; then
    echo "lib/libgit2 submodule not found. Run 'git submodule update --init' first."
    exit 1
fi

# Function to copy DLL to destinations
copy_dlls() {
    local src=$1
    local arch=$2 # Win32 or Win64
    
    echo "Copying $src to redist and demo folders..."
    mkdir -p "lib/redist/$arch"
    cp "$src" "lib/redist/$arch/git2.dll"
    
    mkdir -p "demo/$arch/Debug"
    cp "$src" "demo/$arch/Debug/git2.dll"
    
    mkdir -p "demo/$arch/Release"
    cp "$src" "demo/$arch/Release/git2.dll"
}

echo "Building Win32 (x86) version of libgit2..."
mkdir -p lib/libgit2/build32
cd lib/libgit2/build32
cmake .. -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_C_COMPILER=i686-w64-mingw32-gcc -DCMAKE_CXX_COMPILER=i686-w64-mingw32-g++ -DBUILD_SHARED_LIBS=ON -DBUILD_TESTS=OFF -DBUILD_CLI=OFF
cmake --build . --config Release
echo "Win32 DLL built successfully."
cd "$SCRIPT_DIR/.."
copy_dlls "lib/libgit2/build32/git2.dll" "Win32"

echo "Building Win64 (x64) version of libgit2..."
mkdir -p lib/libgit2/build64
cd lib/libgit2/build64
cmake .. -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_C_COMPILER=x86_64-w64-mingw32-gcc -DCMAKE_CXX_COMPILER=x86_64-w64-mingw32-g++ -DBUILD_SHARED_LIBS=ON -DBUILD_TESTS=OFF -DBUILD_CLI=OFF
cmake --build . --config Release
echo "Win64 DLL built successfully."
cd "$SCRIPT_DIR/.."
copy_dlls "lib/libgit2/build64/git2.dll" "Win64"

echo "Build complete!"
