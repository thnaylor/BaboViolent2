#!/usr/bin/env python3
from pathlib import Path

maps_dir = Path(__file__).resolve().parents[1] / "Content/main/maps"
out_dir = Path(__file__).resolve().parents[1] / "Content/main/LaunchScript"


def maps_with_prefix(*prefixes):
    names = []
    for p in maps_dir.glob("*.bvm"):
        if any(p.stem.startswith(pref) for pref in prefixes):
            names.append(p.stem)
    return sorted(names)


def map_block(names):
    lines = [f"dedicate {names[0]}"]
    lines += [f"addmap {n}" for n in names[1:]]
    return "\n".join(lines)


COMMON_WEAPONS = """
set sv_enableSMG true
set sv_enableShotgun true
set sv_enableSniper true
set sv_enableDualMachineGun true
set sv_enableChainGun true
set sv_enableBazooka true
set sv_enableShotgunReload true
set sv_enableSecondary true
set sv_enableKnives true
set sv_enableMinibot false
set sv_enableNuclear false
set sv_enablePhotonRifle true"""

FOOTER = """
set sv_enableVote true
voteon changemap
voteon sv_gameType

set zsv_adminUser ""
set zsv_adminPass ""

endscript
"""

configs = [
    {
        "file": "CTF.cfg",
        "header": """///////////////////////////////
//--- babo.soh.re CTF server ---//
///////////////////////////////
// sv_gameType 2 = Capture The Flag. Port 3333.
""",
        "vars": """
set sv_friendlyFire false
set sv_reflectedDamage false
set sv_timeToSpawn 5
set sv_topView true
set sv_minSendInterval 2
set sv_forceRespawn false
set sv_roundTimeLimit 360
set sv_gameTimeLimit 900
set sv_scoreLimit 50
set sv_winLimit 7
set sv_gameType 2
set sv_bombTime 60
set sv_gameName "^6babo.soh.re ^4CTF"
set sv_port 3333
set sv_maxPlayer 16
set sv_password ""
set sv_gamePublic true
set sv_slideOnIce false
set sv_showEnemyTag false
set sv_autoBalance true
set sv_autoBalanceTime 4
set sv_maxUploadRate 8.0
set sv_serverType 0
"""
        + COMMON_WEAPONS,
        "maps": maps_with_prefix("CTF-"),
        "map_comment": "//--- Full CTF map rotation ---//",
    },
    {
        "file": "FFA.cfg",
        "header": """/////////////////////////////////
//--- babo.soh.re FFA server ---//
/////////////////////////////////
// sv_gameType 0 = Deathmatch / Babomatch. Port 3334.
""",
        "vars": """
set sv_friendlyFire false
set sv_reflectedDamage false
set sv_timeToSpawn 5
set sv_topView true
set sv_minSendInterval 2
set sv_forceRespawn false
set sv_roundTimeLimit 360
set sv_gameTimeLimit 900
set sv_scoreLimit 50
set sv_winLimit 7
set sv_gameType 0
set sv_bombTime 60
set sv_gameName "^6babo.soh.re ^3FFA"
set sv_port 3334
set sv_maxPlayer 16
set sv_password ""
set sv_gamePublic true
set sv_slideOnIce false
set sv_showEnemyTag false
set sv_autoBalance false
set sv_autoBalanceTime 4
set sv_maxUploadRate 8.0
set sv_serverType 0
"""
        + COMMON_WEAPONS,
        "maps": maps_with_prefix("DM-"),
        "map_comment": "//--- Full DM / FFA map rotation ---//",
    },
    {
        "file": "TDM.cfg",
        "header": """//////////////////////////////////////
//--- babo.soh.re Team Deathmatch ---//
//////////////////////////////////////
// sv_gameType 1 = Team Deathmatch. Port 3335.
""",
        "vars": """
set sv_friendlyFire false
set sv_reflectedDamage false
set sv_timeToSpawn 5
set sv_topView true
set sv_minSendInterval 2
set sv_forceRespawn false
set sv_roundTimeLimit 360
set sv_gameTimeLimit 900
set sv_scoreLimit 50
set sv_winLimit 7
set sv_gameType 1
set sv_bombTime 60
set sv_gameName "^6babo.soh.re ^5Team DM"
set sv_port 3335
set sv_maxPlayer 16
set sv_password ""
set sv_gamePublic true
set sv_slideOnIce false
set sv_showEnemyTag false
set sv_autoBalance true
set sv_autoBalanceTime 4
set sv_maxUploadRate 8.0
set sv_serverType 0
"""
        + COMMON_WEAPONS,
        "maps": maps_with_prefix("CTF-"),
        "map_comment": "//--- Full team-map rotation (CTF layouts, TDM rules) ---//",
    },
    {
        "file": "Sandbox.cfg",
        "header": """/////////////////////////////////
//--- babo.soh.re Sandbox server ---//
/////////////////////////////////
// sv_gameType 3 = Champion. Port 3336.
""",
        "vars": """
set sv_friendlyFire false
set sv_reflectedDamage false
set sv_timeToSpawn 5
set sv_topView true
set sv_minSendInterval 2
set sv_forceRespawn false
set sv_roundTimeLimit 360
set sv_gameTimeLimit 900
set sv_scoreLimit 50
set sv_winLimit 7
set sv_gameType 3
set sv_bombTime 60
set sv_gameName "^6babo.soh.re ^8Sandbox"
set sv_port 3336
set sv_maxPlayer 16
set sv_password ""
set sv_gamePublic true
set sv_slideOnIce false
set sv_showEnemyTag false
set sv_autoBalance true
set sv_autoBalanceTime 4
set sv_maxUploadRate 8.0
set sv_serverType 0
"""
        + COMMON_WEAPONS,
        "maps": maps_with_prefix("CHP-", "KOTH-"),
        "map_comment": "//--- CHP + KOTH sandbox / Champion rotation ---//",
    },
]

for cfg in configs:
    maps = cfg["maps"]
    if not maps:
        raise SystemExit(f"no maps for {cfg['file']}")
    body = (
        cfg["header"]
        + cfg["vars"]
        + "\n\n"
        + cfg["map_comment"]
        + "\n"
        + map_block(maps)
        + FOOTER
    )
    path = out_dir / cfg["file"]
    path.write_text(body)
    print(f"wrote {path.name}: {len(maps)} maps")
