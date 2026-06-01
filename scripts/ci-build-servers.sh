#!/usr/bin/env bash
# Configure and build BaboViolentDedicated + BaboMasterServer for CI.
#
# Usage:
#   ./scripts/ci-build-servers.sh
#
# Optional:
#   BUILD=/path/to/build-dir   (default: build-linux-servers under repo root)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="${BUILD:-$ROOT/build-linux-servers}"

rm -rf "$BUILD"
mkdir -p "$BUILD"

CMAKE_ARGS=(
	-S "$ROOT"
	-B "$BUILD"
	-DCMAKE_BUILD_TYPE=Release
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5
)

echo "==> cmake configure (linux servers) -> $BUILD"
cmake "${CMAKE_ARGS[@]}"

echo "==> cmake build (BaboViolentDedicated BaboMasterServer)"
cmake --build "$BUILD" \
	--target BaboViolentDedicated BaboMasterServer \
	-j"$(nproc 2>/dev/null || echo 4)"

for bin in BaboViolentDedicated BaboMasterServer; do
	[[ -x "$BUILD/$bin" ]] || {
		echo "error: missing executable $BUILD/$bin" >&2
		exit 1
	}
done

echo "==> built:"
ls -la "$BUILD"/BaboViolentDedicated "$BUILD"/BaboMasterServer
