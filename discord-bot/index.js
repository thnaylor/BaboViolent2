import 'dotenv/config';
import { readFile, writeFile } from 'node:fs/promises';
import { Client, GatewayIntentBits, EmbedBuilder } from 'discord.js';

const { DISCORD_TOKEN, CHANNEL_ID, STATUS_URL } = process.env;
const POLL_INTERVAL_MS = Number(process.env.POLL_INTERVAL_SECONDS ?? 60) * 1000;
const STATE_FILE = process.env.STATE_FILE ?? './state.json';

for (const [name, value] of Object.entries({ DISCORD_TOKEN, CHANNEL_ID, STATUS_URL })) {
  if (!value) {
    console.error(`Missing required env var ${name} (see .env.example)`);
    process.exit(1);
  }
}

const GAME_TYPE_NAMES = { 0: 'FFA', 1: 'TDM', 2: 'CTF', 3: 'Champion' };

async function loadMessageId() {
  try {
    const raw = await readFile(STATE_FILE, 'utf8');
    return JSON.parse(raw).messageId ?? null;
  } catch {
    return null;
  }
}

async function saveMessageId(messageId) {
  await writeFile(STATE_FILE, JSON.stringify({ messageId }));
}

async function fetchStatus() {
  const res = await fetch(STATUS_URL, { signal: AbortSignal.timeout(10_000) });
  if (!res.ok) throw new Error(`status endpoint returned ${res.status}`);
  return res.json();
}

function buildEmbed(status) {
  const embed = new EmbedBuilder()
    .setTitle('BaboViolent 2 — Server Status')
    .setColor(0x2ecc71)
    .setTimestamp();

  if (!status.servers?.length) {
    embed.setDescription('No servers currently online.');
    return embed;
  }

  for (const server of status.servers) {
    const gameType =
      typeof server.gameType === 'number'
        ? (GAME_TYPE_NAMES[server.gameType] ?? `Type ${server.gameType}`)
        : server.gameType;
    const lock = server.passworded ? ' 🔒' : '';

    embed.addFields({
      name: `${server.name}${lock}`,
      value: [
        `Map: **${server.map}** (${gameType})`,
        `Players: **${server.players}/${server.maxPlayers}**`,
        `Connect: \`${server.ip}:${server.port}\``,
      ].join('\n'),
    });
  }

  return embed;
}

function buildErrorEmbed(err) {
  return new EmbedBuilder()
    .setTitle('BaboViolent 2 — Server Status')
    .setColor(0xe74c3c)
    .setDescription(`⚠️ Could not reach status endpoint: ${err.message}`)
    .setTimestamp();
}

const client = new Client({ intents: [GatewayIntentBits.Guilds] });

client.once('clientReady', async () => {
  console.log(`Logged in as ${client.user.tag}`);

  const channel = await client.channels.fetch(CHANNEL_ID);
  let message = null;

  const savedId = await loadMessageId();
  if (savedId) {
    message = await channel.messages.fetch(savedId).catch(() => null);
  }

  async function tick() {
    const embed = await fetchStatus().then(buildEmbed).catch(buildErrorEmbed);

    if (message) {
      await message.edit({ embeds: [embed] }).catch(async () => {
        message = await channel.send({ embeds: [embed] });
        await saveMessageId(message.id);
      });
    } else {
      message = await channel.send({ embeds: [embed] });
      await saveMessageId(message.id);
    }
  }

  await tick();
  setInterval(tick, POLL_INTERVAL_MS);
});

client.login(DISCORD_TOKEN);
