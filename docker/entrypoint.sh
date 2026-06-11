#!/bin/sh
set -e

# Resolve the public IP to announce to the master server.
# Inside Docker the detected interface IP is the container's internal 172.x address,
# which is unreachable by game clients. SV_IP overrides it with the real host IP.
if [ -z "${SV_IP:-}" ]; then
    SV_IP=$(curl -sf --max-time 5 https://api.ipify.org || true)
fi
export SV_IP

# --- Server identity ---
GAME_MODE="${GAME_MODE:-FFA}"
SERVER_NAME="${SERVER_NAME:-BaboViolent 2 Server}"
MAX_PLAYERS="${MAX_PLAYERS:-16}"
MAX_PLAYERS_IN_GAME="${MAX_PLAYERS_IN_GAME:-0}"
PORT="${PORT:-3334}"
PASSWORD="${PASSWORD:-}"
GAME_PUBLIC="${GAME_PUBLIC:-false}"
ADMIN_USER="${ADMIN_USER:-}"
ADMIN_PASS="${ADMIN_PASS:-}"

# --- Gametype rotation ---
GAMETYPE_LIST="${GAMETYPE_LIST:-}"

# --- Gameplay ---
FRIENDLY_FIRE="${FRIENDLY_FIRE:-false}"
REFLECTED_DAMAGE="${REFLECTED_DAMAGE:-false}"
RESPAWN_TIME="${RESPAWN_TIME:-5}"
FORCE_RESPAWN="${FORCE_RESPAWN:-false}"
ROUND_TIME_LIMIT="${ROUND_TIME_LIMIT:-360}"
GAME_TIME_LIMIT="${GAME_TIME_LIMIT:-900}"
SCORE_LIMIT="${SCORE_LIMIT:-50}"
WIN_LIMIT="${WIN_LIMIT:-7}"
BOMB_TIME="${BOMB_TIME:-60}"
SLIDE_ON_ICE="${SLIDE_ON_ICE:-false}"
SHOW_ENEMY_TAG="${SHOW_ENEMY_TAG:-false}"
AUTO_BALANCE="${AUTO_BALANCE:-false}"
AUTO_BALANCE_TIME="${AUTO_BALANCE_TIME:-4}"
ENABLE_VOTE="${ENABLE_VOTE:-true}"
SPAWN_IMMUNITY_TIME="${SPAWN_IMMUNITY_TIME:-2}"
MIN_TILES_PER_BABO="${MIN_TILES_PER_BABO:-55}"
MAX_TILES_PER_BABO="${MAX_TILES_PER_BABO:-80}"

# --- Server UX ---
SEND_JOIN_MESSAGE="${SEND_JOIN_MESSAGE:-true}"
JOIN_MESSAGE="${JOIN_MESSAGE:-Welcome to the server!}"
MAX_PING="${MAX_PING:-1000}"
SHOW_KILLS="${SHOW_KILLS:-false}"
MAX_UPLOAD_RATE="${MAX_UPLOAD_RATE:-8}"

# --- Weapon enables (in launch scripts) ---
ENABLE_SMG="${ENABLE_SMG:-true}"
ENABLE_SHOTGUN="${ENABLE_SHOTGUN:-true}"
ENABLE_SNIPER="${ENABLE_SNIPER:-true}"
ENABLE_DUAL_MG="${ENABLE_DUAL_MG:-true}"
ENABLE_CHAIN_GUN="${ENABLE_CHAIN_GUN:-true}"
ENABLE_BAZOOKA="${ENABLE_BAZOOKA:-true}"
ENABLE_SHOTGUN_RELOAD="${ENABLE_SHOTGUN_RELOAD:-true}"
ENABLE_SECONDARY="${ENABLE_SECONDARY:-true}"
ENABLE_KNIVES="${ENABLE_KNIVES:-true}"
ENABLE_MINIBOT="${ENABLE_MINIBOT:-false}"
ENABLE_NUCLEAR="${ENABLE_NUCLEAR:-false}"
ENABLE_PHOTON_RIFLE="${ENABLE_PHOTON_RIFLE:-true}"

# --- Weapon enables (bv2.cfg only) ---
ENABLE_FLAMETHROWER="${ENABLE_FLAMETHROWER:-true}"
ENABLE_MOLOTOV="${ENABLE_MOLOTOV:-true}"
ENABLE_SHIELD="${ENABLE_SHIELD:-true}"
EXPLODING_FT="${EXPLODING_FT:-false}"

# --- Weapon stats ---
ZOOKA_REMOTE_DET="${ZOOKA_REMOTE_DET:-true}"
SMG_DAMAGE="${SMG_DAMAGE:-0.1}"
DMG_DAMAGE="${DMG_DAMAGE:-0.14}"
CG_DAMAGE="${CG_DAMAGE:-0.16}"
SNIPER_DAMAGE="${SNIPER_DAMAGE:-0.34}"
SHOTTY_DAMAGE="${SHOTTY_DAMAGE:-0.21}"
SHOTTY_DROP_RADIUS="${SHOTTY_DROP_RADIUS:-0.35}"
SHOTTY_RANGE="${SHOTTY_RANGE:-6.75}"
ZOOKA_DAMAGE="${ZOOKA_DAMAGE:-0.85}"
ZOOKA_RADIUS="${ZOOKA_RADIUS:-2}"
NUKE_RADIUS="${NUKE_RADIUS:-6}"
NUKE_TIMER="${NUKE_TIMER:-3}"
NUKE_RELOAD="${NUKE_RELOAD:-12}"
FT_DAMAGE="${FT_DAMAGE:-0.065}"
FT_MAX_RANGE="${FT_MAX_RANGE:-8}"
FT_MIN_RANGE="${FT_MIN_RANGE:-1}"
FT_EXPIRATION_TIMER="${FT_EXPIRATION_TIMER:-1.5}"
PHOTON_DAMAGE_COEFF="${PHOTON_DAMAGE_COEFF:-0.65}"
PHOTON_DIST_MULT="${PHOTON_DIST_MULT:-0.65}"
PHOTON_VERTICAL_SHIFT="${PHOTON_VERTICAL_SHIFT:-0.5}"
PHOTON_HORIZONTAL_SHIFT="${PHOTON_HORIZONTAL_SHIFT:-2}"
PHOTON_TYPE="${PHOTON_TYPE:-1}"

TEMPLATE="/app/Content/main/LaunchScript/${GAME_MODE}.cfg"

if [ ! -f "$TEMPLATE" ]; then
    echo "Unknown GAME_MODE '${GAME_MODE}'. Valid values: FFA, CTF, TDM, Champion" >&2
    exit 1
fi

# Generate server.cfg from the chosen mode template
SCRIPT="/app/Content/main/LaunchScript/server.cfg"
cp "$TEMPLATE" "$SCRIPT"

# Patch launch script variables
sed -i "s|set sv_gameName .*|set sv_gameName \"${SERVER_NAME}\"|"                                  "$SCRIPT"
sed -i "s|set sv_maxPlayer .*|set sv_maxPlayer ${MAX_PLAYERS}|"                                    "$SCRIPT"
sed -i "s|set sv_port .*|set sv_port ${PORT}|"                                                     "$SCRIPT"
sed -i "s|set sv_password .*|set sv_password \"${PASSWORD}\"|"                                     "$SCRIPT"
sed -i "s|set sv_gamePublic .*|set sv_gamePublic ${GAME_PUBLIC}|"                                  "$SCRIPT"
sed -i "s|set zsv_adminUser .*|set zsv_adminUser \"${ADMIN_USER}\"|"                               "$SCRIPT"
sed -i "s|set zsv_adminPass .*|set zsv_adminPass \"${ADMIN_PASS}\"|"                               "$SCRIPT"
sed -i "s|set sv_friendlyFire .*|set sv_friendlyFire ${FRIENDLY_FIRE}|"                            "$SCRIPT"
sed -i "s|set sv_reflectedDamage .*|set sv_reflectedDamage ${REFLECTED_DAMAGE}|"                   "$SCRIPT"
sed -i "s|set sv_timeToSpawn .*|set sv_timeToSpawn ${RESPAWN_TIME}|"                               "$SCRIPT"
sed -i "s|set sv_forceRespawn .*|set sv_forceRespawn ${FORCE_RESPAWN}|"                            "$SCRIPT"
sed -i "s|set sv_roundTimeLimit .*|set sv_roundTimeLimit ${ROUND_TIME_LIMIT}|"                     "$SCRIPT"
sed -i "s|set sv_gameTimeLimit .*|set sv_gameTimeLimit ${GAME_TIME_LIMIT}|"                        "$SCRIPT"
sed -i "s|set sv_scoreLimit .*|set sv_scoreLimit ${SCORE_LIMIT}|"                                  "$SCRIPT"
sed -i "s|set sv_winLimit .*|set sv_winLimit ${WIN_LIMIT}|"                                        "$SCRIPT"
sed -i "s|set sv_bombTime .*|set sv_bombTime ${BOMB_TIME}|"                                        "$SCRIPT"
sed -i "s|set sv_slideOnIce .*|set sv_slideOnIce ${SLIDE_ON_ICE}|"                                 "$SCRIPT"
sed -i "s|set sv_showEnemyTag .*|set sv_showEnemyTag ${SHOW_ENEMY_TAG}|"                           "$SCRIPT"
sed -i "s|set sv_autoBalance .*|set sv_autoBalance ${AUTO_BALANCE}|"                               "$SCRIPT"
sed -i "s|set sv_autoBalanceTime .*|set sv_autoBalanceTime ${AUTO_BALANCE_TIME}|"                  "$SCRIPT"
sed -i "s|set sv_maxUploadRate .*|set sv_maxUploadRate ${MAX_UPLOAD_RATE}|"                        "$SCRIPT"
sed -i "s|set sv_enableVote .*|set sv_enableVote ${ENABLE_VOTE}|"                                  "$SCRIPT"
sed -i "s|set sv_enableSMG .*|set sv_enableSMG ${ENABLE_SMG}|"                                     "$SCRIPT"
sed -i "s|set sv_enableShotgun .*|set sv_enableShotgun ${ENABLE_SHOTGUN}|"                         "$SCRIPT"
sed -i "s|set sv_enableSniper .*|set sv_enableSniper ${ENABLE_SNIPER}|"                            "$SCRIPT"
sed -i "s|set sv_enableDualMachineGun .*|set sv_enableDualMachineGun ${ENABLE_DUAL_MG}|"          "$SCRIPT"
sed -i "s|set sv_enableChainGun .*|set sv_enableChainGun ${ENABLE_CHAIN_GUN}|"                     "$SCRIPT"
sed -i "s|set sv_enableBazooka .*|set sv_enableBazooka ${ENABLE_BAZOOKA}|"                         "$SCRIPT"
sed -i "s|set sv_enableShotgunReload .*|set sv_enableShotgunReload ${ENABLE_SHOTGUN_RELOAD}|"      "$SCRIPT"
sed -i "s|set sv_enableSecondary .*|set sv_enableSecondary ${ENABLE_SECONDARY}|"                   "$SCRIPT"
sed -i "s|set sv_enableKnives .*|set sv_enableKnives ${ENABLE_KNIVES}|"                            "$SCRIPT"
sed -i "s|set sv_enableMinibot .*|set sv_enableMinibot ${ENABLE_MINIBOT}|"                         "$SCRIPT"
sed -i "s|set sv_enableNuclear .*|set sv_enableNuclear ${ENABLE_NUCLEAR}|"                         "$SCRIPT"
sed -i "s|set sv_enablePhotonRifle .*|set sv_enablePhotonRifle ${ENABLE_PHOTON_RIFLE}|"            "$SCRIPT"

# Patch bv2.cfg for settings not in the launch script templates
BV2CFG="/app/Content/main/bv2.cfg"
sed -i "s|sv_maxPlayerInGame .*|sv_maxPlayerInGame ${MAX_PLAYERS_IN_GAME}|"                        "$BV2CFG"
sed -i "s|sv_sendJoinMessage .*|sv_sendJoinMessage ${SEND_JOIN_MESSAGE}|"                          "$BV2CFG"
sed -i "s|sv_joinMessage .*|sv_joinMessage \"${JOIN_MESSAGE}\"|"                                   "$BV2CFG"
sed -i "s|sv_maxPing .*|sv_maxPing ${MAX_PING}|"                                                   "$BV2CFG"
sed -i "s|sv_showKills .*|sv_showKills ${SHOW_KILLS}|"                                             "$BV2CFG"
sed -i "s|sv_minTilesPerBabo .*|sv_minTilesPerBabo ${MIN_TILES_PER_BABO}|"                        "$BV2CFG"
sed -i "s|sv_maxTilesPerBabo .*|sv_maxTilesPerBabo ${MAX_TILES_PER_BABO}|"                        "$BV2CFG"
sed -i "s|sv_spawnImmunityTime .*|sv_spawnImmunityTime ${SPAWN_IMMUNITY_TIME}|"                   "$BV2CFG"
sed -i "s|sv_enableFlameThrower .*|sv_enableFlameThrower ${ENABLE_FLAMETHROWER}|"                 "$BV2CFG"
sed -i "s|sv_enableMolotov .*|sv_enableMolotov ${ENABLE_MOLOTOV}|"                                "$BV2CFG"
sed -i "s|sv_enableShield .*|sv_enableShield ${ENABLE_SHIELD}|"                                   "$BV2CFG"
sed -i "s|sv_explodingFT .*|sv_explodingFT ${EXPLODING_FT}|"                                      "$BV2CFG"
sed -i "s|sv_zookaRemoteDet .*|sv_zookaRemoteDet ${ZOOKA_REMOTE_DET}|"                            "$BV2CFG"
# Weapon stats
sed -i "s|sv_smgDamage .*|sv_smgDamage ${SMG_DAMAGE}|"                                            "$BV2CFG"
sed -i "s|sv_dmgDamage .*|sv_dmgDamage ${DMG_DAMAGE}|"                                            "$BV2CFG"
sed -i "s|sv_cgDamage .*|sv_cgDamage ${CG_DAMAGE}|"                                               "$BV2CFG"
sed -i "s|sv_sniperDamage .*|sv_sniperDamage ${SNIPER_DAMAGE}|"                                   "$BV2CFG"
sed -i "s|sv_shottyDamage .*|sv_shottyDamage ${SHOTTY_DAMAGE}|"                                   "$BV2CFG"
sed -i "s|sv_shottyDropRadius .*|sv_shottyDropRadius ${SHOTTY_DROP_RADIUS}|"                      "$BV2CFG"
sed -i "s|sv_shottyRange .*|sv_shottyRange ${SHOTTY_RANGE}|"                                      "$BV2CFG"
sed -i "s|sv_zookaDamage .*|sv_zookaDamage ${ZOOKA_DAMAGE}|"                                      "$BV2CFG"
sed -i "s|sv_zookaRadius .*|sv_zookaRadius ${ZOOKA_RADIUS}|"                                      "$BV2CFG"
sed -i "s|sv_nukeRadius .*|sv_nukeRadius ${NUKE_RADIUS}|"                                         "$BV2CFG"
sed -i "s|sv_nukeTimer .*|sv_nukeTimer ${NUKE_TIMER}|"                                            "$BV2CFG"
sed -i "s|sv_nukeReload .*|sv_nukeReload ${NUKE_RELOAD}|"                                         "$BV2CFG"
sed -i "s|sv_ftDamage .*|sv_ftDamage ${FT_DAMAGE}|"                                               "$BV2CFG"
sed -i "s|sv_ftMaxRange .*|sv_ftMaxRange ${FT_MAX_RANGE}|"                                        "$BV2CFG"
sed -i "s|sv_ftMinRange .*|sv_ftMinRange ${FT_MIN_RANGE}|"                                        "$BV2CFG"
sed -i "s|sv_ftExpirationTimer .*|sv_ftExpirationTimer ${FT_EXPIRATION_TIMER}|"                   "$BV2CFG"
sed -i "s|sv_photonDamageCoefficient .*|sv_photonDamageCoefficient ${PHOTON_DAMAGE_COEFF}|"       "$BV2CFG"
sed -i "s|sv_photonDistMult .*|sv_photonDistMult ${PHOTON_DIST_MULT}|"                            "$BV2CFG"
sed -i "s|sv_photonVerticalShift .*|sv_photonVerticalShift ${PHOTON_VERTICAL_SHIFT}|"             "$BV2CFG"
sed -i "s|sv_photonHorizontalShift .*|sv_photonHorizontalShift ${PHOTON_HORIZONTAL_SHIFT}|"       "$BV2CFG"
sed -i "s|sv_photonType .*|sv_photonType ${PHOTON_TYPE}|"                                         "$BV2CFG"

# Inject gametype rotation before endscript if set
if [ -n "${GAMETYPE_LIST}" ]; then
    sed -i "s|endscript|set sv_gametypeList \"${GAMETYPE_LIST}\"\nendscript|" "$SCRIPT"
fi

exec /app/BaboViolentDedicated server
