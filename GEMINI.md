# libgit2-delphi

## Project Overview

**libgit2-delphi** provides Delphi and Free Pascal bindings for the [libgit2](https://www.libgit2.org/) C library (v1.9.2). It allows Delphi developers to perform Git operations directly from their applications using a native Pascal interface.

The project consists of:
- **Low-level Bindings:** A direct translation of libgit2 C headers into Pascal, located in `src/git2/*.inc` and exposed through `src/libgit2.pas`.
- **High-level Wrapper:** A Delphi-friendly class-based wrapper (`TLibGit2`) in `src/libgit2_wrapper.pas` that simplifies common tasks like cloning, initializing repositories, and managing credentials.

### Technologies
- **Language:** Delphi (Object Pascal) / Free Pascal.
- **Target Library:** libgit2 v1.9.2 (as a Git submodule).
- **Platforms:** Windows (32/64-bit), with support for macOS and Linux via dynamic library loading.

## Building and Running

### Prerequisites
- **libgit2 Binary:** You must have the appropriate dynamic library for your platform:
  - Windows: `git2.dll`
  - Linux: `libgit2.so`
  - macOS: `libgit2.dylib`
- **Build Tools:** To build libgit2 yourself, use the scripts in the `lib/` folder.
  - Run `lib/get_preq.sh` on Linux/WSL to install build prerequisites.
- **Delphi/FPC:** A recent version of Delphi or Free Pascal.

### Key Commands
- **Building libgit2 (Windows DLLs from Linux/WSL):**
  - Run `./lib/build_libgit2.sh`
- **Building libgit2 (Windows DLLs from PowerShell):**
  - Run `./lib/build_libgit2.ps1`
- **Building the Demo:**
  - Open `demo/libgit2_demo.dproj` in the Delphi IDE and build.
  - Or use MSBuild: `msbuild demo/libgit2_demo.dproj /t:Build /p:Config=Debug /p:Platform=Win32`
- **Running the Demo:**
  - `demo/libgit2_demo [repo-url] [username] [password/token] [root-test-folder]`

## Development Conventions

### Project Structure
- `src/`: Core source files.
  - `libgit2.pas`: The main unit that includes all low-level headers.
  - `libgit2_wrapper.pas`: High-level `TLibGit2` component.
  - `git2/`: Directory containing `.inc` files, each corresponding to a libgit2 C header.
- `demo/`: A console application demonstrating the usage of the library.
- `lib/`:
  - `libgit2/`: Submodule for the official libgit2 source.
  - `build_libgit2.*`: Scripts for building libgit2.
  - `get_preq.sh`: Script to install build dependencies.

### Coding Standards
- **Naming:** Follows standard Delphi PascalCase conventions for types and classes.
- **External Calls:** Uses `cdecl` calling convention for all libgit2 functions and callbacks.
- **Header Translation:** Header files are kept as `.inc` files to mirror the original C library structure, making it easier to update when new libgit2 versions are released.
- **Types:** Standard C types (e.g., `uint32_t`, `size_t`) are mapped in `src/git2/stdint.inc` and `src/libgit2.pas`.

### Contribution Guidelines
- When adding new libgit2 features, translate the corresponding C header into a new `.inc` file in `src/git2/` and include it in `src/libgit2.pas`.
- Update the high-level wrapper in `src/libgit2_wrapper.pas` to expose the new functionality in a Pascal-idiomatic way.
- Ensure cross-platform compatibility where possible, especially regarding path separators and library naming.
- **Automated Releases:** A GitHub workflow is set up to automatically build and attach Win32/Win64 `git2.dll` binaries to new GitHub releases.
