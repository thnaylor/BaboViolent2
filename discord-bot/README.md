# BV2 Status Bot

Posts a single embed showing live BaboViolent 2 server status (map, mode, player count) into a Discord channel, and edits that same message every poll interval instead of spamming new ones.

One bot process can serve **any number of Discord servers** at once — there's no per-server config baked into the bot itself. Each server's admin invites it and runs `/setup` in whichever channel they want; the bot remembers each server's channel independently. So you only need to run this once, and anyone can add it to their own server without asking you for anything.

> **This bot needs a status JSON endpoint to poll.** The master server implements it at `GET /status.json` on `STATUS_PORT` (default `10208`, see [STATUS_ENDPOINT.md](STATUS_ENDPOINT.md) for the exact contract) — point `STATUS_URL` at e.g. `http://<your-master-host>:10208/status.json`. That port needs to be reachable from wherever this bot runs (open it in your firewall / publish it in Docker), separately from the game's TCP `10207` port.

## 1. Create the Discord bot

1. Go to the [Discord Developer Portal](https://discord.com/developers/applications) → **New Application** → name it (e.g. "BV2 Status").
2. Left sidebar → **Bot** → **Reset Token** → copy it. This is `DISCORD_TOKEN`. Keep it secret — anyone with it controls the bot.
3. Still on the **Bot** page, you don't need to enable any privileged gateway intents (Message Content / Presence / Server Members) — this bot only posts/edits its own messages and responds to slash commands.
4. Left sidebar → **OAuth2 → URL Generator**:
   - Scopes: `bot` **and** `applications.commands` (the second one is required for `/setup` to show up)
   - Bot Permissions: `View Channel`, `Send Messages`, `Embed Links`
5. Copy the generated URL at the bottom — this is the link anyone uses to add the bot to their own server (see [Adding it to a server](#adding-it-to-a-server) below). It's not secret; share it freely.

## 2. Configure

```
cd discord-bot
cp .env.example .env
```

Fill in `.env`:
- `DISCORD_TOKEN` — from step 1.2
- `STATUS_URL` — the master's status endpoint (see note above)

`CHANNEL_ID` is optional now — see `.env.example`.

## 3. Run it

**Locally (Node 18+):**
```
npm install
npm start
```

**Via Docker (prebuilt image):**

CI publishes this image to GHCR on every push to `modern`/`main` (tag `edge`) and on every release (tag `latest` + semver) — same pipeline as the game's client/dedicated/master images. Portainer, `docker run`, or a compose stack can all pull it directly:
```
docker run --env-file .env -v bv2-status-bot-data:/app/data ghcr.io/thnaylor/baboviolent2-bot:edge
```
Or add it as a service in `docker/docker-compose.yml` alongside the master, so `STATUS_URL` can just be `http://master:10208/status.json` over the compose network instead of a publicly published port.

**Via Docker (building it yourself):**
```
docker build -t bv2-status-bot .
docker run --env-file .env -v bv2-status-bot-data:/app/data bv2-status-bot
```

The volume keeps `state.json` (each server's channel + the message it's editing there) across restarts, so it doesn't post a new message every time the container restarts.

## Adding it to a server

Send whoever runs a Discord server the invite URL from step 1.5, and:

1. They open it, pick their server, click **Continue** → **Authorize**. (Needs "Manage Server" permission on that Discord.)
2. In whichever channel they want the status posts, they run **`/setup`** (optionally `/setup channel:#somewhere-else` to target a different channel). Also needs "Manage Server" permission — random members can't run it or hijack the channel.
3. That's it — no channel ID to look up, nothing to send back to you. `/status-stop` in the same server stops posting there.

First-time note: slash commands are registered globally, which Discord can take up to an hour to propagate on the very first run. Subsequent command updates are usually near-instant.

## Notes

- If the status endpoint is unreachable, the embed switches to a red "⚠️ Could not reach status endpoint" state rather than the bot crashing or going silent.
- Poll interval is `POLL_INTERVAL_SECONDS` in `.env` (default 60). Message edits aren't rate-limited nearly as tightly as channel renames, but there's no reason to go much below ~15s.
- Each registered server is polled/posted independently — one server's deleted channel or revoked permissions doesn't affect any other server.
