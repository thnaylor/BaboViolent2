#!/usr/bin/env bash
# Write Content/bv2.db so client/dedicated use your master (not the public default).
#
# MasterServers.Port in the DB must be TCP_listen + 1000 (e.g. 11207 for 10207).
# Multiple masters can be listed; the game tries them in score order (lowest first).
# The first argument gets Score=0, each additional host gets Score+1.
#
# Usage (from repo root):
#   ./scripts/write-bv2-db.sh
#   ./scripts/write-bv2-db.sh 192.168.86.40
#   ./scripts/write-bv2-db.sh 127.0.0.1 10207
#   ./scripts/write-bv2-db.sh host1.example.com host2.example.com host3.example.com
#   ./scripts/write-bv2-db.sh host1.example.com 10207 host2.example.com 10208
#
# Argument parsing: if an arg looks like a port number it is used as the port for
# the preceding host; otherwise it is treated as a new host at the default port.
#
# Packaged tree (run.sh cwd is Content/; db lives next to main/):
#   CONTENT_DIR="$HOME/bv2-ded/Content" ./scripts/write-bv2-db.sh 192.168.86.40
#
# Env overrides: MASTER_TCP (default port), CONTENT_DIR, ACCOUNT_URL

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEFAULT_TCP="${MASTER_TCP:-10207}"
CONTENT_DIR="${CONTENT_DIR:-$ROOT/Content}"
ACCOUNT_URL="${ACCOUNT_URL:-http://127.0.0.1/}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 1; }; }
need sqlite3

# Parse positional arguments into parallel arrays of hosts and ports.
declare -a HOSTS=()
declare -a PORTS=()

if [ $# -eq 0 ]; then
    HOSTS=("127.0.0.1")
    PORTS=("$DEFAULT_TCP")
else
    pending_host=""
    for arg in "$@"; do
        if [[ "$arg" =~ ^[0-9]+$ ]]; then
            # Looks like a port number — apply it to the pending host (or default if none).
            if [ -n "$pending_host" ]; then
                HOSTS+=("$pending_host")
                PORTS+=("$arg")
                pending_host=""
            else
                # Port with no preceding host: update default for next host-only arg.
                DEFAULT_TCP="$arg"
            fi
        else
            # It's a hostname/IP.
            if [ -n "$pending_host" ]; then
                # Previous host had no explicit port; use default.
                HOSTS+=("$pending_host")
                PORTS+=("$DEFAULT_TCP")
            fi
            pending_host="$arg"
        fi
    done
    # Flush last pending host.
    if [ -n "$pending_host" ]; then
        HOSTS+=("$pending_host")
        PORTS+=("$DEFAULT_TCP")
    fi
fi

mkdir -p "$CONTENT_DIR"
db="$CONTENT_DIR/bv2.db"
rm -f "$db"

# Build the SQL dynamically.
SQL="CREATE TABLE MasterServers (
  Score INTEGER,
  Id INTEGER,
  IP TEXT,
  Location TEXT,
  Port INTEGER
);
"
for idx in "${!HOSTS[@]}"; do
    host="${HOSTS[$idx]}"
    tcp="${PORTS[$idx]}"
    db_port=$((tcp + 1000))
    SQL+="INSERT INTO MasterServers VALUES (${idx}, $((idx + 1)), '${host}', 'custom', ${db_port});
"
done

SQL+="
CREATE TABLE LauncherSettings (
  Name TEXT,
  Value TEXT
);
INSERT INTO LauncherSettings VALUES ('Version', '4.0');
INSERT INTO LauncherSettings VALUES ('DBVersion', '0');
INSERT INTO LauncherSettings VALUES ('AccountURL', '${ACCOUNT_URL}');
INSERT INTO LauncherSettings VALUES ('DidSurvey', '0');
"

sqlite3 "$db" <<< "$SQL"

echo "Wrote $db with ${#HOSTS[@]} master(s):"
for idx in "${!HOSTS[@]}"; do
    echo "  [${idx}] ${HOSTS[$idx]}:${PORTS[$idx]} (Score=${idx})"
done
