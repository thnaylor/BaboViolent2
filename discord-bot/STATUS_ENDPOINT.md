# Status JSON contract

This is what the bot expects `STATUS_URL` to return (`Content-Type: application/json`, plain `GET`, no auth). Implemented by the master server (`cStatusServer` in `src/MasterListingServer/`) on its own port — `STATUS_PORT` env var, default `10208` — separate from the game protocol's `10207`. Any request path gets the same response; there's no real routing.

```json
{
  "servers": [
    {
      "id": "string",
      "name": "BaboViolent 2 Server",
      "ip": "155.93.192.127",
      "port": 3334,
      "map": "somemap",
      "gameType": "FFA",
      "players": 3,
      "maxPlayers": 32,
      "passworded": false
    }
  ],
  "updatedAt": "2026-07-10T12:34:56Z"
}
```

Notes:
- `gameType` should be the resolved string (`FFA` | `TDM` | `CTF` | `Champion`), matching the values used for `GAME_MODE` in `docker-compose.yml`. The bot also accepts a numeric `gameType` (0=FFA, 1=TDM, 2=CTF, 3=Champion, per the `GAMETYPE_ROTATION` mapping) as a fallback and will resolve it itself.
- `servers` should be `[]` (not omitted) when nothing is online — the bot renders "No servers currently online." for that case.
- Data source: the master already collects everything in this shape per connected game server (`stBV2row` in `src/MasterListingServer/cMSstruct.h`) except player *names* — this endpoint only needs counts, which the master has today.
