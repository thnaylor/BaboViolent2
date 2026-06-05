# BaboViolent 2 — Claude Code instructions

## Windows build (MSVC 2022 + CMake 4.x)

The build-windows/ directory is not committed. After a fresh clone, or whenever it is missing, run the full configure + build sequence below.

### Configure (once per clone)

```powershell
cmake -S . -B build-windows -G "Visual Studio 17 2022" -A x64
```

Known gotchas already fixed in the repo:
- `SDL_SHARED OFF` is set in CMakeLists.txt before SDL's add_subdirectory — prevents an unfixable SDL2.dll linker error under MSVC.
- `cmake_minimum_required` bumped to 3.10 in thirdparty/SDL and thirdparty/libogg — required by CMake 4.x.

### Build

Always build only the two game targets. The `BaboMasterServer` target has a winsock header conflict and is not needed for releases.

```powershell
cmake --build build-windows --config Release --target BaboViolent BaboViolentDedicated
```

### Package (Windows release zip)

```powershell
.\scripts\package-windows.ps1
```

Outputs:
- `dist\BaboViolent2-windows-x86_64\` — ready-to-run folder
- `dist\BaboViolent2-windows-x86_64.zip` — distributable zip

### Incremental rebuilds

If only game source files changed (no CMake changes), just re-run the build step — no need to reconfigure.

If CMakeLists.txt changed, re-run configure first, then build.

## SDL notes

Bundled SDL version: **2.0.8**

- `SDL_HINT_WINDOWS_DPI_AWARENESS` does **not** exist in this version (added in 2.24). Don't add it.
- High-DPI: use `SDL_WINDOW_ALLOW_HIGHDPI` flag + `SDL_GL_GetDrawableSize` (already in dkw.cpp).
- Auto-detect resolution: pass `r_resolution 0 0` in bv2.cfg; dkwInit detects via `SDL_GetCurrentDisplayMode` and uses `SDL_WINDOW_FULLSCREEN_DESKTOP` to avoid mode-change scaling.
