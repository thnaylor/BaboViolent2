# BaboViolent 2 (open-source tree)

Headless **dedicated game server**, **master listing server**, and **graphical client** build from this repository. You still need the original **game assets** (maps, textures, sounds, etc.); see `Content/README.txt`.

---

## Prerequisites (Linux)

- **CMake** (≥ 3.10), **C++11** compiler, **OpenGL** development headers, **pthread**, **OpenSSL** (for curl), **SQLite** (bundled source is compiled in-tree).
- **Client with audio (optional):** `SDL2_mixer` + development package (e.g. Fedora: `dnf install SDL2_mixer-devel`). CMake then links **system** `libSDL2` + `libSDL2_mixer` so the client matches the mixer ABI.
- **Client without `SDL2_mixer`:** builds, but has no in-game audio on Linux.

---

## Build

```bash
cd /path/to/BaboViolent2
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --target BaboViolent BaboViolentDedicated BaboMasterServer -j"$(nproc)"
```

Artifacts (typical):

| Target | Output |
|--------|--------|
| `BaboViolent` | Graphical client |
| `BaboViolentDedicated` | Dedicated server (console, no SDL window) |
| `BaboMasterServer` | TCP master / listing server (`src/MasterListingServer`) |

---

## Working directory and assets

Binaries load paths such as **`main/bv2.cfg`**, **`main/LaunchScript/*.cfg`**, and **`./bv2.db`** relative to the **current working directory**.

Recommended layout:

1. Obtain or assemble a `Content/` tree that contains a `main/` folder (game data).
2. Run servers and client **with cwd = that tree** (often `…/BaboViolent2/Content`):

```bash
cd /path/to/BaboViolent2/Content
../build/BaboViolentDedicated          # dedicated
../build/BaboMasterServer                # master server
../build/BaboViolent                   # client
```

If you run from `build/`, paths like `main/bv2.cfg` will not resolve unless you symlink or copy `main` there.

---

## Dedicated server (`BaboViolentDedicated`)

### Startup

- Loads **`main/bv2.cfg`** (via `dksvar`), initializes **BaboNet**, then opens an interactive **stdin** console (type commands, Enter).
- **Join / TCP diagnostics:** with **`c_netlog true`** in `main/bv2.cfg` (repo default), the dedicated stdout console prints **`[net]`** lines for BaboNet handshake, map transfer, and disconnects. You can also force this on after the config load with **`BV2_NETLOG=1`** in the environment (`BV2_NETLOG=0` disables the override). The graphical client prints the same **`[net]`** lines to its in-game console when **`c_netlog`** is on.
- Optional **first argument** is treated as a script name passed to the console as  
  `execute <name>`  
  which loads **`main/LaunchScript/<name>.cfg`** (do **not** include `.cfg` in the argument).

Example:

```bash
cd /path/to/BaboViolent2/Content
../build/BaboViolentDedicated CTF
```

That runs the same sequence as typing `execute CTF` at the dedicated prompt (see `src/Source/main.cpp` and `Console.cpp`).

### Launch scripts

Scripts live under **`main/LaunchScript/`** (e.g. `Content/main/LaunchScript/CTF.cfg`). They are line-oriented config/console commands; the file must end with a line **`endscript`** (see `Console.cpp` `execute` handler).

Example snippet from `CTF.cfg`:

- `set sv_*` — server variables (port, game name, limits, weapons, etc.).
- `dedicate <map>` — start hosting on a map.
- `addmap <map>` — rotation entries.
- `voteon` / `novote` — voting.
- `set zsv_adminUser` / `set zsv_adminPass` — remote admin credentials (see comments in the `.cfg` files).

After editing variables, **`main/bv2.cfg`** is also rewritten on shutdown (registered `dksvar` values).

### Useful console commands

At the dedicated `help` / `?` prompt, the game lists topics (see `src/Source/Console.cpp`), including **`set`**, **`dedicate`**, **`execute`**, **`host`**, bans, kicks, etc.

---

## Master server (`BaboMasterServer`)

The **listing / master** binary is built from **`src/MasterListingServer/`**. It uses **BaboNet** and SQLite (compiled into the target).

- **Listen port (current source):** TCP **`10207`** — set in `src/MasterListingServer/cNetManager.cpp` (`SpawnServer(10207)`). If you change it there, rebuild and open that port in your firewall.
- Run it the same way as the dedicated server regarding **cwd** (directory containing whatever data paths it expects; typically the same `Content/` as the game so relative paths stay consistent if you add DB files beside the binaries).

There is **no interactive config file** in-tree for the master process; tuning is by editing those sources and rebuilding.

---

## Pointing clients and dedicated servers at *your* master

The client and dedicated code use **`CMaster::GetMasterInfos()`** (`src/Game/Master/CMaster.cpp`), which reads **`bv2.db`** in the **current working directory**:

- Table **`MasterServers`** (when present and with the expected column layout) supplies master **hostname/IP** and a **port column** interpreted as **`listenPort + 1000`** in code (`m_Port = atoi(portStr) - 1000`).
- If **`bv2.db`** is missing or the table does not match, defaults are **`babo.soh.re`** and TCP port **`10207`** (same as the in-repo `BaboMasterServer` listen port). The release builds also include **`babo.hostfrog.co.za`** as a fallback master.

**Local / self-hosted master:** insert or update **`MasterServers`** so `atoi(port) - 1000` equals your master’s listen port (e.g. for port **10207**, the stored port column should be **11207**). That overrides the public default for that install.

Release packages omit **`bv2.db`**, so a dedicated started with **`./run.sh CTF`** uses the public default. If that host is unreachable you may see **`connect() failed, errno = 101`**. Point the game at your master (same machine: **`127.0.0.1`**, LAN: your master host IP, e.g. **`192.168.x.x`**):

```bash
CONTENT_DIR="$HOME/bv2-ded/Content" ./scripts/write-bv2-db.sh 192.168.1.10
# or same host as master:
CONTENT_DIR="$HOME/bv2-ded/Content" ./scripts/write-bv2-db.sh 127.0.0.1
```

Also ensure **BaboNet** / protocol expectations match between all three binaries (the dedicated build checks BaboNet reports version **4.0**).

**Automated check (master + dedicated, no GUI):** `./scripts/automated-stack-test.sh` (frees TCP **10207**, starts a temp master, writes **127.0.0.1** into **Content/bv2.db**, runs the dedicated for a few seconds, and fails if the master drops the client immediately or **errno 101** appears).

---

## Graphical client (`BaboViolent`)

```bash
cd /path/to/BaboViolent2/Content
../build/BaboViolent
```

Same **cwd** rules; optional SDL2_mixer system libraries at runtime when built with mixer support.

---

## Quick reference

| Item | Location / notes |
|------|-------------------|
| User / server CVars | `main/bv2.cfg` (created/updated by `dksvar`) |
| Startup scripts | `main/LaunchScript/<name>.cfg`, invoked with `execute <name>` |
| Launcher / master DB hints | `./bv2.db` (SQLite; optional depending on feature) |
| Dedicated auto-script | `./BaboViolentDedicated CTF` → `execute CTF` |
| Master listen port (as shipped in sources) | TCP **10207** (`cNetManager.cpp`) |

For original commercial assets and historical context, see `Content/README.txt` and https://www.rndlabs.ca/ .

---

## CI and releases

**CI** (`.github/workflows/ci.yml`) builds all three targets on **`ubuntu-latest`** for **Linux** (native), **Windows** (MinGW-w64 cross-compile), and **macOS** (osxcross cross-compile). Each platform produces three archives uploaded as workflow artifacts:

| Package | Contents |
|---------|----------|
| `BaboViolent-client-<os>-<arch>.tar.gz` / `.zip` | Client binary, `Content/`, launcher |
| `BaboViolent-dedicated-<os>-<arch>.tar.gz` / `.zip` | Dedicated binary, `Content/`, launcher |
| `BaboMasterServer-<os>-<arch>.tar.gz` / `.zip` | Master binary, `master.db`, `web.db`, bootstrap SQL |

Linux and macOS ship **`.tar.gz`**; Windows ships **`.zip`**. Unpack into an empty directory and run `./run.sh` (or `run.bat` on Windows).

### Automated releases (release-please)

**[release-please](https://github.com/googleapis/release-please)** (`.github/workflows/release-please.yml`) watches **`modern`** and **`main`** for [Conventional Commits](https://www.conventionalcommits.org/):

| Commit prefix | Version bump |
|---------------|--------------|
| `fix:` | patch |
| `feat:` | minor |
| `feat!:` or `BREAKING CHANGE:` in body | major |

On each qualifying push it opens or updates a **Release PR** that bumps `.github/.release-please-manifest.json`, updates **`CHANGELOG.md`**, and prepares the next tag (e.g. `v0.1.0`).

**To ship a release:** merge the Release PR. release-please creates the GitHub Release and tag; **`.github/workflows/release.yml`** then builds all nine platform packages and uploads them to that release.

Example commit messages:

```text
feat: add FFA launch script
fix: ignore speed-hack kick on dedicated server
feat!: change default master listen port
```

**Local packaging** (native Linux build, or cross-build via `scripts/ci-build.sh`):

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --target BaboViolent BaboViolentDedicated BaboMasterServer -j
BV2_PLATFORM=linux ./scripts/package-release.sh    # dist/*.tar.gz

# Cross-compile from Linux (same as CI):
sudo apt-get install g++-mingw-w64-x86-64 mingw-w64-tools   # Windows
BV2_PLATFORM=windows BUILD=build-windows ./scripts/ci-build.sh
BV2_PLATFORM=windows BUILD=build-windows ./scripts/package-release.sh

# macOS cross requires osxcross (see mbround18/setup-osxcross); CI installs it automatically.
BV2_PLATFORM=macos BUILD=build-macos ./scripts/ci-build.sh
BV2_PLATFORM=macos BUILD=build-macos ./scripts/package-release.sh
```

Legacy Linux helper: `./scripts/package-linux-distributions.sh` (same as `BV2_PLATFORM=linux`).
