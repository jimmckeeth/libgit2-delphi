# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Delphi/Free Pascal bindings for [libgit2](https://www.libgit2.org/) v1.9.2. The project has two layers:

1. **Low-level bindings** (`src/libgit2.pas` + `src/git2/*.inc`) — direct translation of the libgit2 C headers into Pascal. Each `.inc` file mirrors one C header from the libgit2 source.
2. **High-level wrapper** (`src/libgit2_wrapper.pas`) — the `TLibGit2` class providing a Delphi-idiomatic API over the raw bindings.

The `lib/libgit2/` directory is a git submodule containing the official libgit2 C source.

## Building

### Building the libgit2 DLL (required before the Delphi project will run)

**From Linux/WSL (cross-compile for Windows):**

```bash
# Install prerequisites first (once):
./lib/get_preq.sh

# Build Win32 and Win64 DLLs:
./lib/build_libgit2.sh
```

This produces `git2.dll` in `lib/redist/Win32/` and `lib/redist/Win64/`, and also copies them to `demo/Win32/Debug|Release/` and `demo/Win64/Debug|Release/`.

**From Windows (PowerShell):**

```powershell
./lib/build_libgit2.ps1
```

**CMake flags used:** `-DBUILD_SHARED_LIBS=ON -DBUILD_TESTS=OFF -DBUILD_CLI=OFF -DUSE_HTTPS=WinHTTP -DUSE_SHA1=CollisionDetection`

### Building the Delphi project

Open `demo/libgit2_demo.dproj` in the Delphi IDE, or via MSBuild:

```
msbuild demo/libgit2_demo.dproj /t:Build /p:Config=Debug /p:Platform=Win32
```

### CI / Release automation

GitHub Actions (`.github/workflows/release-libgit2.yml`) triggers on release creation/publish and builds Win32/Win64 DLLs using MSVC CMake on `windows-latest`, then attaches `git2-win32.dll` and `git2-win64.dll` to the release assets.

## Running the Demo

```
libgit2_demo.exe [repo-url] [username] [password/token] [root-test-folder]
```

## Code Architecture

### Low-level layer (`src/libgit2.pas` + `src/git2/*.inc`)

- `libgit2.pas` is the single unit consumers add to their project's `uses` clause. It `{$I}`-includes all `.inc` files in order.
- All libgit2 C types are declared as Pascal records (opaque structs use empty `record end`), with `P`-prefixed pointer types and `PP`-prefixed double-pointer types following the convention `Pgit_foo = ^git_foo`.
- C integer typedefs (`uint32_t`, `size_t`, etc.) are mapped in `src/git2/stdint.inc`.
- All `external` function declarations use `cdecl` calling convention and link against `libgit2_dll` (the platform-appropriate constant: `git2.dll` / `libgit2.dylib` / `libgit2.so`).
- `{$DEFINE GIT_DEPRECATE_HARD}` is set to exclude deprecated API symbols at compile time.
- The unit exposes `InitLibgit2` / `ShutdownLibgit2` helpers that wrap `git_libgit2_init` / `git_libgit2_shutdown` with a guard flag.

### High-level layer (`src/libgit2_wrapper.pas`)

- `TLibGit2` is a plain class (not a component), manually `Create`/`Free`'d.
- Credentials are stored in `TLibGit2Properties` (`Props` property) — `Username` and `Password`.
- libgit2 callbacks must be plain `cdecl` functions; `TLibGit2` uses static wrapper functions (e.g. `Static_CredentialsCallback`) that cast the `payload: Pointer` back to `TLibGit2(payload)` and forward to the corresponding instance method.
- `LastErrorText` is populated by `SetLastErrorFromGit`, which reads `git_error_last()`.
- Boolean return convention: all public methods return `True` on success.

### Adding new libgit2 functionality

1. Translate the relevant C header to a new `src/git2/<name>.inc` following the existing style (opaque record types, `cdecl external libgit2_dll` functions).
2. Add a `{$I git2/<name>.inc}` line in `src/libgit2.pas` (maintain the rough dependency order already established).
3. Optionally expose it through a new method on `TLibGit2` in `src/libgit2_wrapper.pas`, using the static-callback pattern if callbacks are needed.

## Key Conventions

- **String passing:** Delphi `String` → `AnsiString` cast → `PAnsiChar` before passing to libgit2 functions.
- **Memory management:** Every `git_*_free` call must be paired with its allocation. `TLibGit2` calls `git_repository_free` at the end of each method that opens a repo, not in a destructor.
- **FPC compatibility:** `libgit2.pas` uses `{$IFDEF FPC}` / `{$DEFINE DOTTEDUNITS}` guards so the unit works with both Delphi and Free Pascal.
- **Delayed loading:** Opt-in `{$DEFINE LIBGIT2_DLL_DELAY_LOAD}` is available in `libgit2.pas` for Windows on-demand DLL loading.
