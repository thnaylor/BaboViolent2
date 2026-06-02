#!/usr/bin/env bash
# Build BaboViolentDedicated + BaboMasterServer inside a distro container so
# binaries link against that distro's glibc (safe to deploy on matching release).
#
# Usage:
#   ./scripts/ci-build-servers-container.sh debian-12-bookworm
#   BV2_DISTRO=debian-12-bookworm ./scripts/ci-build-servers-container.sh
#   PACKAGE=1 ./scripts/ci-build-servers-container.sh debian-12-bookworm
#
# Requires podman or docker.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BV2_DISTRO="${1:-${BV2_DISTRO:-debian-12-bookworm}}"
PACKAGE="${PACKAGE:-0}"

image_for_distro() {
	case "$1" in
		debian-13-trixie) echo debian:trixie-slim ;;
		debian-12-bookworm) echo debian:bookworm-slim ;;
		debian-11-bullseye) echo debian:bullseye-slim ;;
		fedora-44) echo fedora:44 ;;
		fedora-43) echo fedora:43 ;;
		*) echo "error: unknown BV2_DISTRO=$1" >&2; return 1 ;;
	esac
}

CONTAINER_ENGINE=""
if command -v podman >/dev/null 2>&1; then
	CONTAINER_ENGINE=podman
elif command -v docker >/dev/null 2>&1; then
	CONTAINER_ENGINE=docker
else
	echo "error: install podman or docker" >&2
	exit 1
fi

IMAGE="$(image_for_distro "$BV2_DISTRO")"
BUILD_DIR="build-${BV2_DISTRO}"

echo "==> $CONTAINER_ENGINE run $IMAGE (BV2_DISTRO=$BV2_DISTRO)"

run_in_container() {
	"$CONTAINER_ENGINE" run --rm \
		-v "$ROOT:/src:Z" \
		-w /src \
		-e BUILD="/src/$BUILD_DIR" \
		-e BV2_DISTRO="$BV2_DISTRO" \
		"$IMAGE" \
		bash -lc "$1"
}

run_in_container '
	set -euo pipefail
	if command -v apt-get >/dev/null; then
		export DEBIAN_FRONTEND=noninteractive
		apt-get update
		apt-get install -y --no-install-recommends ca-certificates git
	fi
	bash ./scripts/ci-install-linux-deps.sh
	bash ./scripts/ci-build-servers.sh
'

if [[ "$PACKAGE" == 1 ]]; then
	run_in_container "
		set -euo pipefail
		command -v sqlite3 >/dev/null || {
			if command -v apt-get >/dev/null; then
				export DEBIAN_FRONTEND=noninteractive
				apt-get update
				apt-get install -y --no-install-recommends sqlite3
			else
				dnf install -y sqlite
			fi
		}
		BV2_DISTRO=$BV2_DISTRO BUILD=/src/$BUILD_DIR bash ./scripts/package-linux-servers-release.sh
	"
fi

echo "==> built in container:"
ls -la "$ROOT/$BUILD_DIR"/BaboMasterServer "$ROOT/$BUILD_DIR"/BaboViolentDedicated
