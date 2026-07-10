# BV2 Status Bot

Posts a single embed into a Discord channel showing live BaboViolent 2 server status (map, mode, player count), and edits that same message every 60 seconds instead of spamming new ones.

> **This bot needs a status JSON endpoint to poll.** The master server implements it at `GET /status.json` on `STATUS_PORT` (default `10208`, see [STATUS_ENDPOINT.md](STATUS_ENDPOINT.md) for the exact contract) — point `STATUS_URL` at e.g. `http://<your-master-host>:10208/status.json`. That port needs to be reachable from wherever this bot runs (open it in your firewall / publish it in Docker), separately from the game's TCP `10207` port.

## 1. Create the Discord bot

1. Go to the [Discord Developer Portal](https://discord.com/developers/applications) → **New Application** → name it (e.g. "BV2 Status").
2. Left sidebar → **Bot** → **Reset Token** → copy it. This is `DISCORD_TOKEN`. Keep it secret — anyone with it controls the bot.
3. Still on the **Bot** page, you don't need to enable any privileged gateway intents (Message Content / Presence / Server Members) — this bot only posts and edits its own messages.
4. Left sidebar → **OAuth2 → URL Generator**:
   - Scopes: `bot`
   - Bot Permissions: `View Channel`, `Send Messages`, `Embed Links`
5. Open the generated URL, pick your server, authorize. The bot now appears in your member list (offline until you run it).
6. In Discord, enable **Developer Mode** (User Settings → Advanced), then right-click the channel you want the status in → **Copy Channel ID**. This is `CHANNEL_ID`.

## 2. Configure

```
cd discord-bot
cp .env.example .env
```

Fill in `.env`:
- `DISCORD_TOKEN` — from step 1.2
- `CHANNEL_ID` — from step 1.6
- `STATUS_URL` — the master's status endpoint (see note above)

## 3. Run it

**Locally (Node 18+):**
```
npm install
npm start
```

**Via Docker:**
```
docker build -t bv2-status-bot .
docker run --env-file .env -v bv2-status-bot-data:/app/data bv2-status-bot
```

The volume keeps `state.json` (the ID of the message it's editing) across restarts, so it doesn't post a new message every time the container restarts.

## Notes

- If the status endpoint is unreachable, the embed switches to a red "⚠️ Could not reach status endpoint" state rather than the bot crashing or going silent.
- Poll interval is `POLL_INTERVAL_SECONDS` in `.env` (default 60). Message edits aren't rate-limited nearly as tightly as channel renames, but there's no reason to go much below ~15s.
