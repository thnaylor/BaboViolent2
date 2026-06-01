#!/usr/bin/env bash
# Install native Linux build dependencies for CI (Debian/Ubuntu or Fedora).
#
# Usage (as root in a container):
#   ./scripts/ci-install-linux-deps.sh

set -euo pipefail

if [[ -f /etc/os-release ]]; then
	# shellcheck disable=SC1091
	. /etc/os-release
else
	echo "error: /etc/os-release not found" >&2
	exit 1
fi

case "${ID:-}" in
	debian|ubuntu)
		export DEBIAN_FRONTEND=noninteractive
		apt-get update
		apt-get install -y --no-install-recommends \
			ca-certificates \
			cmake \
			g++ \
			git \
			make \
			pkg-config \
			libgl1-mesa-dev \
			libglu1-mesa-dev \
			libsdl2-mixer-dev \
			sqlite3
		;;
	fedora)
		dnf install -y \
			ca-certificates \
			cmake \
			gcc-c++ \
			git \
			make \
			pkgconfig \
			mesa-libGL-devel \
			mesa-libGLU-devel \
			SDL2_mixer-devel \
			sqlite
		;;
	*)
		echo "error: unsupported Linux distro ID=${ID:-unknown}" >&2
		exit 1
		;;
esac

echo "==> toolchain"
g++ --version | head -1
cmake --version | head -1
