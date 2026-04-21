$ErrorActionPreference = "Stop"

# Navigate to project root relative to this script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location "$ScriptDir/.."

if (-not (Test-Path "lib/libgit2")) {
    Write-Host "lib/libgit2 submodule not found. Run 'git submodule update --init' first."
    exit 1
}

# Function to copy DLL to destinations
function Copy-Dlls($src, $arch) {
    Write-Host "Copying $src to redist and demo folders..."
    
    $redistDir = "lib/redist/$arch"
    if (-not (Test-Path $redistDir)) { mkdir $redistDir | Out-Null }
    Copy-Item $src "$redistDir/git2.dll" -Force
    
    $debugDir = "demo/$arch/Debug"
    if (-not (Test-Path $debugDir)) { mkdir $debugDir | Out-Null }
    Copy-Item $src "$debugDir/git2.dll" -Force
    
    $releaseDir = "demo/$arch/Release"
    if (-not (Test-Path $releaseDir)) { mkdir $releaseDir | Out-Null }
    Copy-Item $src "$releaseDir/git2.dll" -Force
}

# Build Win32
Write-Host "Building Win32 (x86) version of libgit2..."
mkdir -Force lib/libgit2/build32 | Out-Null
Set-Location lib/libgit2/build32
cmake .. -A Win32 -DBUILD_SHARED_LIBS=ON -DBUILD_TESTS=OFF -DBUILD_CLI=OFF
cmake --build . --config Release
if ($?) {
    $dllPath = "Release/git2.dll"
    if (-not (Test-Path $dllPath)) { $dllPath = "git2.dll" } # Fallback if cmake output changed
    Set-Location "$ScriptDir/.."
    Copy-Dlls "lib/libgit2/build32/$dllPath" "Win32"
}
Set-Location "$ScriptDir/.."

# Build Win64
Write-Host "Building Win64 (x64) version of libgit2..."
mkdir -Force lib/libgit2/build64 | Out-Null
Set-Location lib/libgit2/build64
cmake .. -A x64 -DBUILD_SHARED_LIBS=ON -DBUILD_TESTS=OFF -DBUILD_CLI=OFF
cmake --build . --config Release
if ($?) {
    $dllPath = "Release/git2.dll"
    if (-not (Test-Path $dllPath)) { $dllPath = "git2.dll" }
    Set-Location "$ScriptDir/.."
    Copy-Dlls "lib/libgit2/build64/$dllPath" "Win64"
}
Set-Location "$ScriptDir/.."

Write-Host "Build complete!"
