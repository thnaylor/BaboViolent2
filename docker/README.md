# BaboViolent 2 — Dedicated Server Docker Image

Runs a BaboViolent 2 dedicated server in a container. All server settings are configured via environment variables.

## Prerequisites

- Docker
- A Linux build of the dedicated server binary at `build-linux/BaboViolentDedicated` (see [Building](#building) below)

## Building

Build the Linux binary first (requires a Linux host or WSL):

```sh
cmake -S . -B build-linux -DCMAKE_BUILD_TYPE=Release
cmake --build build-linux --target BaboViolentDedicated
```

Then build the image from the **repo root**:

```sh
docker build -f docker/Dockerfile -t baboviolent2 .
```

## Running

### docker compose (recommended)

Edit the variables in `docker/docker-compose.yml`, then from the repo root:

```sh
docker compose -f docker/docker-compose.yml up
```

### docker run

```sh
docker run -d \
  --name babo-ffa \
  -p 3333:3333/tcp \
  -p 3333:3333/udp \
  -e SERVER_NAME="My Server" \
  -e GAME_MODE=FFA \
  -e MAX_PLAYERS=16 \
  baboviolent2
```

## Environment variables

> **Note:** `SERVER_NAME` and `JOIN_MESSAGE` must not contain the `|` character.

### Server identity

| Variable | Default | Description |
|---|---|---|
| `GAME_MODE` | `FFA` | Game mode: `FFA`, `CTF`, `TDM`, or `Champion` |
| `SERVER_NAME` | `BaboViolent 2 Server` | Name shown in the server browser |
| `MAX_PLAYERS` | `16` | Maximum number of connected players |
| `MAX_PLAYERS_IN_GAME` | `0` | Max players actively in-game; extras spectate. `0` = no limit |
| `PORT` | `3333` | UDP/TCP port the server listens on |
| `PASSWORD` | _(none)_ | Server password — leave empty for no password |
| `GAME_PUBLIC` | `false` | Set to `true` to register on the master server |
| `ADMIN_USER` | _(none)_ | Admin username |
| `ADMIN_PASS` | _(none)_ | Admin password |

### Server UX

| Variable | Default | Description |
|---|---|---|
| `SEND_JOIN_MESSAGE` | `true` | Whether to show the join message at all |
| `JOIN_MESSAGE` | `Welcome to the server!` | Message shown to each player on connect |
| `MAX_PING` | `1000` | Kick players above this ping; `1000` = effectively disabled |
| `SHOW_KILLS` | `false` | Show kill feed |
| `MAX_UPLOAD_RATE` | `8` | Server upload rate cap in KB/s per client |

### Gameplay

| Variable | Default | Description |
|---|---|---|
| `FRIENDLY_FIRE` | `false` | Enable friendly fire |
| `REFLECTED_DAMAGE` | `false` | Damage reflected back to shooter |
| `RESPAWN_TIME` | `5` | Seconds before respawn |
| `FORCE_RESPAWN` | `false` | Skip death camera, respawn immediately |
| `ROUND_TIME_LIMIT` | `360` | Round length in seconds |
| `GAME_TIME_LIMIT` | `900` | Total game length in seconds |
| `SCORE_LIMIT` | `50` | Score/kill limit to end the game |
| `WIN_LIMIT` | `7` | Rounds needed to win |
| `BOMB_TIME` | `60` | Bomb timer duration in seconds (CTF/bomb modes) |
| `SLIDE_ON_ICE` | `false` | Enable ice physics |
| `SHOW_ENEMY_TAG` | `false` | Show enemy player name tags |
| `AUTO_BALANCE` | `false` | Auto-balance teams — recommended `true` for CTF/TDM |
| `AUTO_BALANCE_TIME` | `4` | Seconds before unbalanced teams are rebalanced |
| `ENABLE_VOTE` | `true` | Allow players to vote on map/mode changes |
| `SPAWN_IMMUNITY_TIME` | `2` | Invincibility seconds after spawning |
| `MIN_TILES_PER_BABO` | `55` | Minimum map size filter (tiles per player) |
| `MAX_TILES_PER_BABO` | `80` | Maximum map size filter (tiles per player) |

### Weapon enables

| Variable | Default | Description |
|---|---|---|
| `ENABLE_SMG` | `true` | Sub-machine gun |
| `ENABLE_SHOTGUN` | `true` | Shotgun |
| `ENABLE_SNIPER` | `true` | Sniper rifle |
| `ENABLE_DUAL_MG` | `true` | Dual machine guns |
| `ENABLE_CHAIN_GUN` | `true` | Chain gun |
| `ENABLE_BAZOOKA` | `true` | Bazooka |
| `ENABLE_SHOTGUN_RELOAD` | `true` | Shotgun reload mechanic |
| `ENABLE_FLAMETHROWER` | `true` | Flamethrower |
| `ENABLE_PHOTON_RIFLE` | `true` | Photon rifle |
| `ENABLE_SECONDARY` | `true` | Secondary weapons |
| `ENABLE_KNIVES` | `true` | Knives |
| `ENABLE_MOLOTOV` | `true` | Molotov cocktail |
| `ENABLE_SHIELD` | `true` | Shield |
| `ENABLE_MINIBOT` | `false` | Minibot |
| `ENABLE_NUCLEAR` | `false` | Nuclear weapon |
| `EXPLODING_FT` | `false` | Flamethrower projectiles explode on impact |

### Weapon stats

All values are floats. Defaults match vanilla bv2.cfg.

| Variable | Default | Description |
|---|---|---|
| `ZOOKA_REMOTE_DET` | `true` | Remote detonation for bazooka rockets |
| `SMG_DAMAGE` | `0.1` | SMG damage per bullet |
| `DMG_DAMAGE` | `0.14` | Dual MG damage per bullet |
| `CG_DAMAGE` | `0.16` | Chain gun damage per bullet |
| `SNIPER_DAMAGE` | `0.34` | Sniper damage per shot |
| `SHOTTY_DAMAGE` | `0.21` | Shotgun damage per pellet |
| `SHOTTY_DROP_RADIUS` | `0.35` | Shotgun pellet spread radius |
| `SHOTTY_RANGE` | `6.75` | Shotgun effective range |
| `ZOOKA_DAMAGE` | `0.85` | Bazooka direct-hit damage |
| `ZOOKA_RADIUS` | `2` | Bazooka splash radius |
| `NUKE_RADIUS` | `6` | Nuclear blast radius |
| `NUKE_TIMER` | `3` | Seconds before nuke detonates |
| `NUKE_RELOAD` | `12` | Nuke reload time in seconds |
| `FT_DAMAGE` | `0.065` | Flamethrower damage per tick |
| `FT_MAX_RANGE` | `8` | Flamethrower maximum range |
| `FT_MIN_RANGE` | `1` | Flamethrower minimum range |
| `FT_EXPIRATION_TIMER` | `1.5` | Flamethrower flame lifetime in seconds |
| `PHOTON_DAMAGE_COEFF` | `0.65` | Photon rifle damage coefficient |
| `PHOTON_DIST_MULT` | `0.65` | Photon rifle damage falloff over distance |
| `PHOTON_VERTICAL_SHIFT` | `0.5` | Photon rifle vertical aim shift |
| `PHOTON_HORIZONTAL_SHIFT` | `2` | Photon rifle horizontal aim shift |
| `PHOTON_TYPE` | `1` | Photon rifle projectile type |

## Ports

The default port is **3333** (TCP + UDP). If you change `PORT`, update the `ports` mapping in `docker-compose.yml` to match.
