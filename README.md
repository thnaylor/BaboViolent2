<div align="center">

```
  ____        _          __     ___       _            _   ____
 | __ )  __ _| |__   ___\ \   / (_) ___ | | ___ _ __ | |_|___ \
 |  _ \ / _` | '_ \ / _ \\ \ / /| |/ _ \| |/ _ \ '_ \| __| __) |
 | |_) | (_| | |_) | (_) |\ V / | | (_) | |  __/ | | | |_ / __/
 |____/ \__,_|_.__/ \___/  \_/  |_|\___/|_|\___|_| |_|\__|_____|
```

### The open-source revival of a cult-classic isometric multiplayer shooter.

[![CI](https://github.com/thnaylor/BaboViolent2/actions/workflows/ci.yml/badge.svg?branch=modern)](https://github.com/thnaylor/BaboViolent2/actions/workflows/ci.yml)
[![Docker](https://github.com/thnaylor/BaboViolent2/actions/workflows/docker.yml/badge.svg?branch=modern)](https://github.com/thnaylor/BaboViolent2/actions/workflows/docker.yml)
[![Latest release](https://img.shields.io/github/v/release/thnaylor/BaboViolent2?label=release&color=orange)](https://github.com/thnaylor/BaboViolent2/releases/latest)
[![License: GPLv3](https://img.shields.io/github/license/thnaylor/BaboViolent2?color=blue)](LICENSE.txt)

**[⬇ Download](https://github.com/thnaylor/BaboViolent2/releases/latest)** &nbsp;·&nbsp;
**[🎮 Game modes](#game-modes)** &nbsp;·&nbsp;
**[🖥 Self-host a server](#self-host-a-server)** &nbsp;·&nbsp;
**[🔨 Build from source](#build-from-source)**

</div>

---

## What is this?

**BaboViolent 2** is a fast, top-down isometric multiplayer arena shooter, originally a title by [RNDLabs](https://www.rndlabs.ca). This repository **is the original game's source code**, now open-sourced and kept building and running on modern toolchains — same engine, same art, not a clone or reimplementation: the graphical client, the dedicated game server, and the master/listing server that ties them together.

---

## Download

Grab the latest build from the **[Releases page](https://github.com/thnaylor/BaboViolent2/releases/latest)**. Each release ships several archives — pick what you need:

| Package | Contents | Launch |
|---|---|---|
| `BaboViolent2-linux-x86_64.zip` | Client + dedicated server (Linux) | `./play.sh` (client), `./server.sh [FFA\|CTF\|TDM\|Champion]` (dedicated) |
| `BaboViolent2-windows-x86_64.zip` | Client + dedicated server (Windows) | Double-click `BaboViolent.exe` or `BaboViolentDedicated.exe` |
| `BaboMasterServer-linux-x86_64.zip` / `-windows-x86_64.zip` | Master / listing server, standalone | `./run.sh` (Linux) / `run.bat` (Windows) |
| `BaboViolent2-server-<distro>-x86_64.tar.gz` | Headless dedicated server only, built per Linux distro (Debian 11/12/13, Fedora 43/44) | `./server.sh [FFA\|CTF\|TDM\|Champion]` |

Unpack an archive into an empty directory and run the launcher listed above from inside it.

---

## Game modes

| Mode | Script |
|---|---|
| Free-for-all | `main/LaunchScript/FFA.cfg` |
| Team Deathmatch | `main/LaunchScript/TDM.cfg` |
| Capture the Flag | `main/LaunchScript/CTF.cfg` |
| Champion | `main/LaunchScript/Champion.cfg` |

Launch a dedicated server straight into a mode:

```bash
cd Content
../BaboViolentDedicated CTF     # ≡ typing "execute CTF" at the console prompt
```

---

## Self-host a server

The easiest way to run your own dedicated server is **Docker** — prebuilt images are published to GHCR on every push to `modern`, and pinned per release:

```
ghcr.io/thnaylor/baboviolent2         # dedicated game server
ghcr.io/thnaylor/baboviolent2-master  # master / listing server
```

```bash
git clone https://github.com/thnaylor/BaboViolent2.git
cd BaboViolent2
docker compose -f docker/docker-compose.yml up -d
```

That brings up a master server on `10207/tcp` and a dedicated FFA server on `3334`, fully configured via environment variables (game mode, weapon tuning, admin creds, and more) — see [`docker/docker-compose.yml`](docker/docker-compose.yml) and [`docker/README.md`](docker/README.md) for the full variable reference.

> Running the master on Windows/macOS Docker Desktop? Published ports mask every peer as the bridge gateway, so game servers must self-report their public IP (`SV_IP`) rather than relying on auto-detection. A native Linux Docker host avoids this entirely.

Prefer running native binaries instead of containers? See [Build from source](#build-from-source) — the dedicated and master servers are plain console binaries with no GUI dependency.

> **Standalone alternative:** [thnaylor/baboviolent2-server-docker](https://github.com/thnaylor/baboviolent2-server-docker) is a separate, self-contained Docker packaging of the dedicated server (same environment-variable model as above) if you'd rather not clone this whole engine repo just to host a server.

---

## Build from source

<details>
<summary><b>Linux</b></summary>

**Prerequisites:** CMake ≥ 3.10, a C++11 compiler, OpenGL dev headers, pthread, OpenSSL (for curl). SQLite is bundled and compiled in-tree. For in-game audio, install `SDL2_mixer` + dev headers (e.g. `dnf install SDL2_mixer-devel`) — CMake links against the system `libSDL2`/`libSDL2_mixer` so the client matches the mixer ABI.

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --target BaboViolent BaboViolentDedicated BaboMasterServer -j"$(nproc)"
```

</details>

<details>
<summary><b>Windows</b></summary>

**Prerequisites:** Visual Studio 2022 (or newer BuildTools) + CMake.

```powershell
cmake -S . -B build-windows -G "Visual Studio 17 2022" -A x64
cmake --build build-windows --config Release --target BaboViolent BaboViolentDedicated
.\scripts\package-windows.ps1
```

> Only build the `BaboViolent` and `BaboViolentDedicated` targets on Windows — `BaboMasterServer` has a Winsock conflict on that toolchain and isn't buildable there yet; run the master on Linux/Docker instead.

</details>

| Target | Output |
|---|---|
| `BaboViolent` | Graphical client |
| `BaboViolentDedicated` | Dedicated server (headless console) |
| `BaboMasterServer` | TCP master / listing server |

Binaries load `main/bv2.cfg`, `main/LaunchScript/*.cfg`, and `./bv2.db` relative to the **current working directory** — run them from a directory containing a populated `Content/` tree (or symlink `main/` next to the binary).

### Pointing at your own master

By default, clients and dedicated servers phone home to the public masters (`babo.hostfrog.co.za`, `babo.soh.re`) via `bv2.db` in the working directory. To point at a self-hosted master instead:

```bash
./scripts/write-bv2-db.sh <your-master-ip>
```

An automated smoke test (spins up a master + dedicated server and checks the handshake, no GUI required) is available at `./scripts/automated-stack-test.sh`.

---

## CI & releases

- **CI** (`ci.yml`) builds the client + dedicated server for Linux and Windows, and the dedicated + master servers across five Linux distros, on every push and PR.
- **Releases** are driven by [release-please](https://github.com/googleapis/release-please) watching [Conventional Commits](https://www.conventionalcommits.org/) on `modern`/`main` — merging its release PR cuts a GitHub Release and triggers the full build/package/upload pipeline automatically.
- **Docker images** are rebuilt and pushed to GHCR on every push to `modern`/`main` (tag: `edge`) and on every published release (tag: matching semver + `latest`).

```text
fix: ...              → patch release
feat: ...             → minor release
feat!: ... /
BREAKING CHANGE: ...  → major release
```

---

## Credits

- Original **BaboViolent 2** by [RNDLabs](https://www.rndlabs.ca).
- Open-source engine maintained here by [@thnaylor](https://github.com/thnaylor), forked from [Jmainguy/BaboViolent2](https://github.com/Jmainguy/BaboViolent2).

Licensed under the [GNU GPLv3](LICENSE.txt).
