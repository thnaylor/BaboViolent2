import 'dotenv/config';
import { readFile, writeFile } from 'node:fs/promises';
import {
  Client,
  GatewayIntentBits,
  EmbedBuilder,
  SlashCommandBuilder,
  PermissionFlagsBits,
  ChannelType,
} from 'discord.js';

const { DISCORD_TOKEN, STATUS_URL, CHANNEL_ID } = process.env;
const POLL_INTERVAL_MS = Number(process.env.POLL_INTERVAL_SECONDS ?? 60) * 1000;
const STATE_FILE = process.env.STATE_FILE ?? './state.json';

for (const [name, value] of Object.entries({ DISCORD_TOKEN, STATUS_URL })) {
  if (!value) {
    console.error(`Missing required env var ${name} (see .env.example)`);
    process.exit(1);
  }
}

const GAME_TYPE_NAMES = { 0: 'FFA', 1: 'TDM', 2: 'CTF', 3: 'Champion' };

// registrations: { [guildId]: { channelId, messageId } } -- one entry per
// server that's run /setup, so this single bot process can serve any number
// of Discord servers instead of just the one baked into CHANNEL_ID.
async function loadRegistrations() {
  try {
    const raw = JSON.parse(await readFile(STATE_FILE, 'utf8'));
    // The old single-server format was just { messageId }, which has no
    // guild ID to key off of -- nothing useful to carry forward from it.
    if (raw && typeof raw === 'object' && !('messageId' in raw)) return raw;
  } catch {
    // no state file yet; start fresh below
  }
  return {};
}

async function saveRegistrations(registrations) {
  await writeFile(STATE_FILE, JSON.stringify(registrations));
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

const setupCommand = new SlashCommandBuilder()
  .setName('setup')
  .setDescription('Start posting live BaboViolent 2 server status in this server')
  .addChannelOption((opt) =>
    opt
      .setName('channel')
      .setDescription('Channel to post in (defaults to this channel)')
      .addChannelTypes(ChannelType.GuildText)
      .setRequired(false),
  )
  .setDefaultMemberPermissions(PermissionFlagsBits.ManageGuild);

const stopCommand = new SlashCommandBuilder()
  .setName('status-stop')
  .setDescription('Stop posting BaboViolent 2 server status in this server')
  .setDefaultMemberPermissions(PermissionFlagsBits.ManageGuild);

const client = new Client({ intents: [GatewayIntentBits.Guilds] });
let registrations = {};

async function postOrEdit(guildId) {
  const reg = registrations[guildId];
  if (!reg) return;

  const channel = await client.channels.fetch(reg.channelId).catch(() => null);
  if (!channel) {
    // Channel was deleted or the bot lost access to it -- forget this
    // registration rather than fail forever every tick.
    delete registrations[guildId];
    await saveRegistrations(registrations);
    return;
  }

  const embed = await fetchStatus().then(buildEmbed).catch(buildErrorEmbed);

  let message = reg.messageId
    ? await channel.messages.fetch(reg.messageId).catch(() => null)
    : null;

  if (message) {
    message = await message.edit({ embeds: [embed] }).catch(() => null);
  }
  if (!message) {
    message = await channel.send({ embeds: [embed] }).catch(() => null);
    if (!message) return; // no perms right now; leave registration, retry next tick
    reg.messageId = message.id;
    await saveRegistrations(registrations);
  }
}

async function tickAll() {
  for (const guildId of Object.keys(registrations)) {
    await postOrEdit(guildId).catch((err) =>
      console.error(`tick failed for guild ${guildId}:`, err),
    );
  }
}

client.on('interactionCreate', async (interaction) => {
  if (!interaction.isChatInputCommand()) return;

  if (interaction.commandName === 'setup') {
    const channelOption = interaction.options.getChannel('channel');
    const channel = channelOption
      ? await client.channels.fetch(channelOption.id)
      : interaction.channel;

    const perms = channel.permissionsFor(client.user);
    if (!perms?.has(['ViewChannel', 'SendMessages', 'EmbedLinks'])) {
      await interaction.reply({
        content: `I need View Channel, Send Messages, and Embed Links permissions in ${channel}.`,
        ephemeral: true,
      });
      return;
    }

    registrations[interaction.guildId] = { channelId: channel.id, messageId: null };
    await saveRegistrations(registrations);
    await interaction.reply({ content: `Status will now post in ${channel}.`, ephemeral: true });
    await postOrEdit(interaction.guildId);
    return;
  }

  if (interaction.commandName === 'status-stop') {
    delete registrations[interaction.guildId];
    await saveRegistrations(registrations);
    await interaction.reply({ content: 'Stopped posting status here.', ephemeral: true });
  }
});

client.once('clientReady', async () => {
  console.log(`Logged in as ${client.user.tag}`);

  registrations = await loadRegistrations();

  // One-time bootstrap: fold CHANNEL_ID's guild into the registrations if
  // it's not there already, so an existing single-channel deployment keeps
  // working across the upgrade without needing /setup re-run.
  if (CHANNEL_ID) {
    const channel = await client.channels.fetch(CHANNEL_ID).catch(() => null);
    if (channel?.guildId && !registrations[channel.guildId]) {
      registrations[channel.guildId] = { channelId: CHANNEL_ID, messageId: null };
      await saveRegistrations(registrations);
    }
  }

  await client.application.commands.set([setupCommand, stopCommand]);

  await tickAll();
  setInterval(tickAll, POLL_INTERVAL_MS);
});

client.login(DISCORD_TOKEN);
