#!/usr/bin/env bash
# Package BaboViolentDedicated + BaboMasterServer for a native Linux distro build.
#
# Usage:
#   BV2_DISTRO=debian-12-bookworm BUILD=/path/to/build ./scripts/package-linux-servers-release.sh
#
# Optional:
#   BV2_ARCH=x86_64|arm64
#   BV2_ARCHIVE=tar.gz|zip   (default: tar.gz)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export BV2_PLATFORM=linux
export BV2_SERVER_ONLY=1
export BV2_DISTRO="${BV2_DISTRO:?set BV2_DISTRO (e.g. debian-12-bookworm)}"
export BV2_ARCHIVE="${BV2_ARCHIVE:-tar.gz}"
export BUILD="${BUILD:-$ROOT/build-${BV2_DISTRO}}"

exec bash "$ROOT/scripts/package-release.sh"
