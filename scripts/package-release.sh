#!/usr/bin/env bash
# Package BaboViolent 2 release archives.
#
# Usage (from repo root):
#   BV2_PLATFORM=linux|macos|windows ./scripts/package-release.sh
#   BUILD=/path/to/build BV2_PLATFORM=linux ./scripts/package-release.sh
#
# Optional:
#   BV2_ARCH=x86_64|arm64|aarch64   (default: detected)
#   BV2_ARCHIVE=tar.gz|zip          (default: tar.gz on unix, zip on windows)
#   BV2_DISTRO=debian-12-bookworm   (optional label for native Linux distro builds)
#   BV2_SERVER_ONLY=1               (package dedicated + master only; skip client)
#
# Output (examples):
#   dist/BaboViolent2-windows-x86_64.zip          (game + server, flat layout)
#   dist/BaboViolent2-linux-x86_64.tar.gz         (game + server)
#   dist/BaboMasterServer-linux-x86_64.tar.gz
#   dist/BaboViolent2-server-debian-12-bookworm-x86_64.tar.gz
#   dist/BaboMasterServer-fedora-44-x86_64.tar.gz

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
STAGE="$DIST/.staging-$$"

BV2_PLATFORM="${BV2_PLATFORM:-}"
if [[ -z "$BV2_PLATFORM" ]]; then
	case "$(uname -s)" in
		Linux) BV2_PLATFORM=linux ;;
		Darwin) BV2_PLATFORM=macos ;;
		MINGW*|MSYS*|CYGWIN*) BV2_PLATFORM=windows ;;
		*) echo "error: set BV2_PLATFORM=linux|macos|windows" >&2; exit 1 ;;
	esac
fi

BUILD="${BUILD:-$ROOT/build-${BV2_PLATFORM}}"

BV2_ARCH="${BV2_ARCH:-$(uname -m)}"
case "$BV2_ARCH" in
	x86_64|amd64) BV2_ARCH=x86_64 ;;
	aarch64|arm64) BV2_ARCH=arm64 ;;
esac

BV2_ARCHIVE="${BV2_ARCHIVE:-}"
if [[ -z "$BV2_ARCHIVE" ]]; then
	[[ "$BV2_PLATFORM" == windows ]] && BV2_ARCHIVE=zip || BV2_ARCHIVE=tar.gz
fi

BV2_SERVER_ONLY="${BV2_SERVER_ONLY:-0}"
BV2_RELEASE_LABEL="${BV2_DISTRO:-$BV2_PLATFORM}"

die() { echo "error: $*" >&2; exit 1; }

exe_name() {
	local base="$1"
	if [[ "$BV2_PLATFORM" == windows ]]; then
		echo "${base}.exe"
	else
		echo "$base"
	fi
}

# MSVC multi-config generators put Release binaries in BUILD/Release/ (MinGW does not).
resolve_windows_build_dir() {
	local b="$1"
	if [[ "$BV2_PLATFORM" != windows ]]; then
		echo "$b"
		return
	fi
	if [[ -f "$b/Release/$(exe_name BaboViolent)" ]]; then
		echo "$b/Release"
	elif [[ -f "$b/$(exe_name BaboViolent)" ]]; then
		echo "$b"
	else
		echo "$b"
	fi
}
BUILD="$(resolve_windows_build_dir "$BUILD")"

bin_exists() {
	[[ -f "$1" ]] || return 1
	if [[ "$BV2_PLATFORM" == windows ]]; then
		return 0
	fi
	[[ -x "$1" ]]
}

MASTER_BIN="$BUILD/$(exe_name BaboMasterServer)"
DED_BIN="$BUILD/$(exe_name BaboViolentDedicated)"
CLI_BIN="$BUILD/$(exe_name BaboViolent)"

mkdir -p "$DIST"
bash "$ROOT/scripts/ensure-master-databases.sh"

# If a release tag is available in the environment (GitHub Actions) or via git,
# update src/Version.h BV2_RELEASE_STRING so packaged binaries contain the
# correct release string. This does not commit — packaging uses the modified file.
get_release_tag() {
	# explicit env override
	if [[ -n "${BV2_VERSION:-}" ]]; then
		echo "$BV2_VERSION"
		return
	fi
	# GitHub Actions sets GITHUB_REF=refs/tags/<tag>
	if [[ -n "${GITHUB_REF:-}" && "${GITHUB_REF#refs/tags/}" != "$GITHUB_REF" ]]; then
		echo "${GITHUB_REF#refs/tags/}"
		return
	fi
	# try git exact tag
	git describe --tags --exact-match 2>/dev/null || true
}

RELEASE_TAG=$(get_release_tag || true)
if [[ -n "$RELEASE_TAG" ]]; then
	# normalize v prefix
	NORM=${RELEASE_TAG#v}
	echo "Updating src/Version.h to release $NORM"
	perl -0777 -pe "s/#define BV2_RELEASE_STRING \".*?\"/#define BV2_RELEASE_STRING \"${NORM}\"/s" -i "$ROOT/src/Version.h"
fi

need_client=1
[[ "$BV2_SERVER_ONLY" == 1 ]] && need_client=0

if ! bin_exists "$MASTER_BIN" || ! bin_exists "$DED_BIN" || { [[ "$need_client" == 1 ]] && ! bin_exists "$CLI_BIN"; }; then
	if [[ "$BV2_SERVER_ONLY" == 1 ]]; then
		echo "Binaries missing; running scripts/ci-build-servers.sh..."
		export BUILD
		bash "$ROOT/scripts/ci-build-servers.sh"
	else
		echo "Binaries missing; running scripts/ci-build.sh..."
		export BV2_PLATFORM BUILD
		bash "$ROOT/scripts/ci-build.sh"
	fi
	BUILD="$(resolve_windows_build_dir "${BUILD:-$ROOT/build-${BV2_PLATFORM}}")"
	MASTER_BIN="$BUILD/$(exe_name BaboMasterServer)"
	DED_BIN="$BUILD/$(exe_name BaboViolentDedicated)"
	CLI_BIN="$BUILD/$(exe_name BaboViolent)"
fi
bin_exists "$MASTER_BIN" || die "no executable: $MASTER_BIN"
bin_exists "$DED_BIN" || die "no executable: $DED_BIN"
if [[ "$need_client" == 1 ]]; then
	bin_exists "$CLI_BIN" || die "no executable: $CLI_BIN"
fi

# --- Linux: ldd closure into lib/ ---
collect_linux_libs() {
	local dest_libdir="$1"
	shift
	mkdir -p "$dest_libdir"
	declare -A scanned
	declare -A copied_realpath
	local -a stack=("$@")
	local f libpath bn realp

	is_skipped() {
		case "$1" in
			*/libc.so.6|*/libm.so.6|*/libpthread.so.0|*/libdl.so.2|*/librt.so.1|*/ld-linux-x86-64.so.2|*/ld-linux.so.2|*/ld-linux-aarch64.so.1) return 0 ;;
		esac
		return 1
	}

	while ((${#stack[@]})); do
		f="${stack[0]}"
		stack=("${stack[@]:1}")
		[[ -f "$f" ]] || continue
		realp=$(readlink -f "$f" 2>/dev/null || echo "$f")
		[[ ${scanned[$realp]+x} ]] && continue
		scanned[$realp]=1

		while IFS= read -r libpath; do
			[[ -f "$libpath" ]] || continue
			is_skipped "$libpath" && continue
			realp=$(readlink -f "$libpath" 2>/dev/null || echo "$libpath")
			[[ ${copied_realpath[$realp]+x} ]] && continue
			bn=$(basename "$libpath")
			cp -L "$libpath" "$dest_libdir/$bn"
			chmod a+r "$dest_libdir/$bn"
			copied_realpath[$realp]=1
			stack+=("$dest_libdir/$bn")
		done < <(ldd "$f" 2>/dev/null | awk '$3 ~ /^\// {print $3}')
	done
}

# --- macOS: otool closure into lib/ (native otool or osxcross *-otool on Linux CI) ---
macos_otool() {
	if command -v otool >/dev/null 2>&1; then
		echo otool
		return
	fi
	local d="${OSXCROSS_TARGET:-}/bin"
	if [[ -d "$d" ]]; then
		local t
		t=$(find "$d" -maxdepth 1 -name '*-otool' -print -quit 2>/dev/null || true)
		[[ -n "$t" ]] && { echo "$t"; return; }
	fi
	echo otool
}

collect_macos_libs() {
	local dest_libdir="$1"
	shift
	mkdir -p "$dest_libdir"
	declare -A copied
	local -a stack=("$@")
	local f lib resolved bn otool_cmd
	otool_cmd=$(macos_otool)

	while ((${#stack[@]})); do
		f="${stack[0]}"
		stack=("${stack[@]:1}")
		[[ -f "$f" ]] || continue
		while IFS= read -r lib; do
			[[ -n "$lib" ]] || continue
			case "$lib" in
				/usr/lib/*|/System/*|/Library/*|@executable_path/*|@loader_path/*) continue ;;
			esac
			resolved="$lib"
			if [[ "$lib" == @rpath/* ]]; then
				continue
			fi
			[[ ${copied[$resolved]+x} ]] && continue
			[[ -f "$resolved" ]] || continue
			bn=$(basename "$resolved")
			cp -L "$resolved" "$dest_libdir/$bn"
			chmod a+r "$dest_libdir/$bn"
			copied[$resolved]=1
			stack+=("$dest_libdir/$bn")
		done < <("$otool_cmd" -L "$f" 2>/dev/null | awk 'NR>1 {print $1}')
	done
}

# --- Windows (MinGW): bundle compiler/runtime DLLs next to the .exe ---
collect_mingw_libs() {
	local dest_libdir="$1"
	shift
	mkdir -p "$dest_libdir"
	local gxx dll bn
	gxx=$(command -v x86_64-w64-mingw32-g++ 2>/dev/null || true)
	[[ -n "$gxx" ]] || return 0
	for dll in libstdc++-6.dll libgcc_s_seh-1.dll libgcc_s_dw2-1.dll libwinpthread-1.dll; do
		dll=$("$gxx" -print-file-name="$dll" 2>/dev/null || true)
		[[ -f "$dll" ]] || continue
		bn=$(basename "$dll")
		cp -L "$dll" "$dest_libdir/$bn"
		chmod a+r "$dest_libdir/$bn"
	done
}

collect_libs() {
	local dest_libdir="$1"
	shift
	case "$BV2_PLATFORM" in
		linux) collect_linux_libs "$dest_libdir" "$@" ;;
		macos) collect_macos_libs "$dest_libdir" "$@" ;;
		windows) collect_mingw_libs "$dest_libdir" "$@" ;;
	esac
}

write_readme_master() {
	local d="$1"
	cat >"$d/README.txt" <<EOF
BaboMasterServer (${BV2_PLATFORM} ${BV2_ARCH})
-------------------------------------------
Unpack anywhere. From this directory run:

  $( [[ "$BV2_PLATFORM" == windows ]] && echo run.bat || echo ./run.sh )

Uses master.db and web.db in this directory. If they are empty/corrupt, run:
  $( [[ "$BV2_PLATFORM" == windows ]] && echo bootstrap-databases.bat || echo ./bootstrap-databases.sh )
(SQL sources are included next to it.) TCP listen port is 10207
(source: src/MasterListingServer/cNetManager.cpp).

Game servers / clients elsewhere should point bv2.db MasterServers at this host
with Port = listen_tcp + 1000 (e.g. 11207 for 10207).

Also serves a read-only JSON status endpoint (GET /status.json) on port 10208
for external tools (e.g. discord-bot/). Set STATUS_PORT in the environment to
change it, or STATUS_PORT=0 to disable it.
EOF
}

write_readme_game() {
	local d="$1"
	local server_only="${2:-0}"
	if [[ "$BV2_PLATFORM" == windows ]]; then
		if [[ "$server_only" == 1 ]]; then
			cat >"$d/README.txt" <<EOF
BaboViolent 2 Dedicated Server (${BV2_PLATFORM} ${BV2_ARCH})
-------------------------------------------------------------
Double-click BaboViolentDedicated.exe to start an FFA server.
Pass a game mode as the first argument for a different mode:
  BaboViolentDedicated.exe CTF
  BaboViolentDedicated.exe TDM

Game data (main/, LaunchScript/, etc.) is in the same folder as the .exe.
EOF
		else
			cat >"$d/README.txt" <<EOF
BaboViolent 2 (${BV2_PLATFORM} ${BV2_ARCH})
--------------------------------------------
PLAY:   Double-click BaboViolent.exe
HOST:   Double-click BaboViolentDedicated.exe  (starts FFA by default)
        Or run from a command prompt:
          BaboViolentDedicated.exe CTF
          BaboViolentDedicated.exe TDM

This package includes a default bv2.db with:
  - Master host babo.soh.re
  - Launcher profile default name "Unamed Babo"

To use a local master, edit bv2.db MasterServers to your host.
EOF
		fi
	else
		if [[ "$server_only" == 1 ]]; then
			cat >"$d/README.txt" <<EOF
BaboViolent 2 Dedicated Server (${BV2_RELEASE_LABEL} ${BV2_ARCH})
------------------------------------------------------------------
Unpack anywhere, then:
  ./server.sh [FFA|CTF|TDM|...]   (default: FFA)

This package includes a default Content/bv2.db pointing at babo.soh.re.
EOF
		else
			cat >"$d/README.txt" <<EOF
BaboViolent 2 (${BV2_RELEASE_LABEL} ${BV2_ARCH})
-------------------------------------------------
Unpack anywhere, then:
  ./play.sh                        (launch game client)
  ./server.sh [FFA|CTF|TDM|...]   (launch dedicated server; default: FFA)

This package includes a default Content/bv2.db with:
  - Master host babo.soh.re
  - Launcher profile default name "Unamed Babo"

To use a local master, edit Content/bv2.db MasterServers to your host.
EOF
		fi
	fi
}

write_default_game_bv2_db() {
	local content_dir="$1"
	local db="$content_dir/bv2.db"
	command -v sqlite3 >/dev/null || die "sqlite3 is required to generate default Content/bv2.db"
	rm -f "$db"
	sqlite3 "$db" <<'SQL'
CREATE TABLE MasterServers (
  Score INTEGER,
  Id INTEGER,
  IP TEXT,
  Location TEXT,
  Port INTEGER
);
INSERT INTO MasterServers VALUES (0, 1, 'babo.hostfrog.co.za', 'default', 11207);
INSERT INTO MasterServers VALUES (1, 2, 'babo.soh.re', 'default', 11207);

CREATE TABLE LauncherSettings (
  Name TEXT,
  Value TEXT
);
INSERT INTO LauncherSettings VALUES ('Version', '4.0');
INSERT INTO LauncherSettings VALUES ('DBVersion', '0');
INSERT INTO LauncherSettings VALUES ('AccountURL', 'https://babo.soh.re/');
INSERT INTO LauncherSettings VALUES ('DidSurvey', '0');
INSERT INTO LauncherSettings VALUES ('ProfileName', 'Unamed Babo');
SQL
}

write_run_master_unix() {
	local d="$1"
	cat >"$d/run.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
# Prefer system runtime libs for compatibility. Only fall back to bundled libs
# when ldd reports missing dependencies, or when explicitly requested.
if [[ "${BV2_FORCE_BUNDLED_LIBS:-0}" == "1" ]] || ldd "$DIR/bin/BaboMasterServer" 2>/dev/null | grep -q "not found"; then
	export LD_LIBRARY_PATH="$DIR/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
	export DYLD_LIBRARY_PATH="$DIR/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
fi
exec "$DIR/bin/BaboMasterServer" "$@"
EOF
	chmod +x "$d/run.sh"
}

write_run_master_windows() {
	local d="$1"
	cat >"$d/run.bat" <<'EOF'
@echo off
setlocal
cd /d "%~dp0"
set "PATH=%~dp0lib;%PATH%"
"%~dp0bin\BaboMasterServer.exe" %*
EOF
}

write_run_unix() {
	local script="$1"   # output filename, e.g. play.sh or server.sh
	local exe="$2"      # binary name inside bin/
	local d="$3"
	local default_arg="${4:-}"
	cat >"$d/$script" <<EOF
#!/usr/bin/env bash
set -euo pipefail
DIR="\$(cd "\$(dirname "\$0")" && pwd)"
if [[ "\${BV2_FORCE_BUNDLED_LIBS:-0}" == "1" ]] || ldd "\$DIR/bin/$exe" 2>/dev/null | grep -q "not found"; then
	export LD_LIBRARY_PATH="\$DIR/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
	export DYLD_LIBRARY_PATH="\$DIR/lib\${DYLD_LIBRARY_PATH:+:\$DYLD_LIBRARY_PATH}"
fi
cd "\$DIR/Content" || { echo "missing Content/ next to $script" >&2; exit 1; }
exec "\$DIR/bin/$exe" \${@:-$default_arg}
EOF
	chmod +x "$d/$script"
}

write_bootstrap_unix() {
	local d="$1"
	cat >"$d/bootstrap-databases.sh" <<'BOOT'
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
command -v sqlite3 >/dev/null || { echo "install sqlite3" >&2; exit 1; }
sqlite3 master.db <master-bootstrap.sql
sqlite3 web.db <web-bootstrap.sql
echo "OK: rewrote master.db and web.db in $(pwd)"
BOOT
	chmod +x "$d/bootstrap-databases.sh"
}

write_bootstrap_windows() {
	local d="$1"
	cat >"$d/bootstrap-databases.bat" <<'BOOT'
@echo off
setlocal
cd /d "%~dp0"
where sqlite3 >nul 2>&1 || (echo install sqlite3 & exit /b 1)
sqlite3 master.db <master-bootstrap.sql
sqlite3 web.db <web-bootstrap.sql
echo OK: rewrote master.db and web.db in %CD%
BOOT
}

stage_master_content() {
	local d="$1"
	[[ -s "$ROOT/Content/master.db" ]] || die "master.db missing or empty after ensure-master-databases.sh"
	[[ -s "$ROOT/Content/web.db" ]] || die "web.db missing or empty after ensure-master-databases.sh"
	cp -a "$ROOT/Content/master.db" "$d/"
	cp -a "$ROOT/Content/web.db" "$d/"
	cp -a "$ROOT/packaging/master-bootstrap.sql" "$d/"
	cp -a "$ROOT/packaging/web-bootstrap.sql" "$d/"
	if [[ "$BV2_PLATFORM" == windows ]]; then
		write_bootstrap_windows "$d"
		write_run_master_windows "$d"
	else
		write_bootstrap_unix "$d"
		write_run_master_unix "$d"
	fi
	write_readme_master "$d"
}

# Stage a combined game + server package.
#
# Windows: flat layout — exes and DLLs sit alongside Content/ so users can
#   double-click the .exe without any wrapper script or SmartScreen-triggering .bat.
#   The exe itself calls bv2_relocate_to_content() at startup.
#
# Linux/macOS: bin/ + lib/ layout with play.sh and server.sh launcher scripts.
#
# server_only=1 omits the game client and produces server.sh only.
stage_combined_game() {
	local d="$1"
	local server_only="${2:-0}"

	if [[ "$BV2_PLATFORM" == windows ]]; then
		# Flat layout for Windows: strip Content/ wrapper so main/ sits next to
		# the exe, matching the output of scripts/package-windows.ps1.
		cp -a "$ROOT/Content/." "$d/"
		local content_dir="$d"
	else
		cp -a "$ROOT/Content" "$d/Content"
		local content_dir="$d/Content"
	fi
	write_default_game_bv2_db "$content_dir"

	if [[ "$BV2_PLATFORM" == windows ]]; then
		cp -a "$DED_BIN" "$d/$(exe_name BaboViolentDedicated)"
		collect_libs "$d" "$d/$(exe_name BaboViolentDedicated)"
		if [[ "$server_only" != 1 ]] && bin_exists "$CLI_BIN"; then
			cp -a "$CLI_BIN" "$d/$(exe_name BaboViolent)"
			collect_libs "$d" "$d/$(exe_name BaboViolent)"
		fi
	else
		mkdir -p "$d/bin" "$d/lib"
		cp -a "$DED_BIN" "$d/bin/BaboViolentDedicated"
		chmod +x "$d/bin/BaboViolentDedicated"
		collect_libs "$d/lib" "$d/bin/BaboViolentDedicated"
		write_run_unix "server.sh" "BaboViolentDedicated" "$d" "FFA"
		if [[ "$server_only" != 1 ]] && bin_exists "$CLI_BIN"; then
			cp -a "$CLI_BIN" "$d/bin/BaboViolent"
			chmod +x "$d/bin/BaboViolent"
			collect_libs "$d/lib" "$d/bin/BaboViolent"
			write_run_unix "play.sh" "BaboViolent" "$d"
		fi
	fi

	write_readme_game "$d" "$server_only"
}

archive_dir() {
	local label="$1"
	local stagedir="$2"
	local out="$DIST/${label}-${BV2_RELEASE_LABEL}-${BV2_ARCH}.${BV2_ARCHIVE}"
	local payload_root="BaboViolent2"
	local wrapper
	rm -f "$out"
	wrapper="$STAGE/.archive-wrap-${label}"
	rm -rf "$wrapper"
	mkdir -p "$wrapper/$payload_root"
	cp -a "$stagedir"/. "$wrapper/$payload_root"/
	case "$BV2_ARCHIVE" in
		tar.gz)
			tar -C "$wrapper" -czf "$out" "$payload_root"
			;;
		zip)
			command -v zip >/dev/null || die "install zip"
			(
				cd "$wrapper" && zip -qr "$out" "$payload_root"
			)
			;;
		*) die "unsupported BV2_ARCHIVE=$BV2_ARCHIVE (use tar.gz or zip)" ;;
	esac
	echo "Wrote $out"
}

cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT

rm -f \
	"$DIST"/BaboViolent2-"${BV2_RELEASE_LABEL}"-"${BV2_ARCH}".* \
	"$DIST"/BaboViolent2-server-"${BV2_RELEASE_LABEL}"-"${BV2_ARCH}".* \
	"$DIST"/BaboMasterServer-"${BV2_RELEASE_LABEL}"-"${BV2_ARCH}".* \
	"$DIST"/BaboMasterServer-linux.zip "$DIST"/BaboViolentDedicated-linux.zip "$DIST"/BaboViolent-linux.zip \
	"$DIST"/BaboViolent-client-"${BV2_RELEASE_LABEL}"-"${BV2_ARCH}".* \
	"$DIST"/BaboViolent-dedicated-"${BV2_RELEASE_LABEL}"-"${BV2_ARCH}".* \
	2>/dev/null || true

# --- Master ---
M="$STAGE/master"
mkdir -p "$M/bin" "$M/lib"
cp -a "$MASTER_BIN" "$M/bin/$(exe_name BaboMasterServer)"
chmod +x "$M/bin/$(exe_name BaboMasterServer)" 2>/dev/null || true
collect_libs "$M/lib" "$M/bin/$(exe_name BaboMasterServer)"
stage_master_content "$M"
archive_dir "BaboMasterServer" "$M"

# --- Game + server (combined) ---
G="$STAGE/game"
mkdir -p "$G"
if [[ "$need_client" == 1 ]]; then
	stage_combined_game "$G" 0
	archive_dir "BaboViolent2" "$G"
	echo "Done. BaboViolent2 + BaboMasterServer archives for ${BV2_RELEASE_LABEL}/${BV2_ARCH} are in $DIST/"
else
	stage_combined_game "$G" 1
	archive_dir "BaboViolent2-server" "$G"
	echo "Done. BaboViolent2-server + BaboMasterServer archives for ${BV2_RELEASE_LABEL}/${BV2_ARCH} are in $DIST/"
fi
