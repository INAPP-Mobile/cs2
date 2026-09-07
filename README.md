# Deploy and Host

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy/-U7Su3)

Counter-Strike 2 Dedicated Server — one-click deploy with persistent volume, CSTV support, and zero-downtime updates. Powered by [joedwards32/CS2](https://github.com/joedwards32/CS2).

After deploying and completing the [playit.gg setup](#connecting-players-udp-via-playitgg), open CS2 → Play → Community Server Browser → Add Server: `<your-playit-allocation-address>` (the IP:port playit.gg assigns).

## System Requirements

- **Disk:** 30GB+ dedicated volume (CS2 base install ~20GB, grows with maps/workshop content)
- **Memory:** 2 GB RAM minimum (4 GB+ recommended for >10 players)
- **Network:** UDP port 27015 (game), TCP port 27020 (CSTV, optional)
- **Steam:** Valid Game Server Login Token required

## About Hosting

This template runs a CS2 dedicated server wrapped around the upstream Docker image. Game data persists on a Railway volume mounted at `/home/steam/cs2-dedicated` — configs, maps, and logs survive deploys and restarts.

The entrypoint runs as root on boot to chown the Railway volume (root-owned by default) to the `steam` user, then drops privileges before launching the server. Railway uses TCP port `27015` for healthchecks since the game port is UDP and Railway doesn't support UDP healthchecks.

**Prerequisites:**
- A Steam Game Server Login Token from [steamcommunity.com/dev/managegameservers](https://steamcommunity.com/dev/managegameservers)

Key environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `SRCDS_TOKEN` | *required* | Steam Game Server Login Token |
| `CS2_SERVERNAME` | `cs2 private server` | Server hostname |
| `CS2_MAXPLAYERS` | `10` | Max simultaneous players |
| `CS2_RCONPW` | `changeme` | RCON password |
| `CS2_STARTMAP` | `de_inferno` | Starting map |
| `CS2_MAPGROUP` | `mg_active` | Map group |
| `CS2_GAMETYPE` | `0` | Game type (0=Classic, 1=Arms Race, 2=Demolition) |
| `CS2_GAMEMODE` | `1` | Game mode (0=Casual, 1=Competitive, 2=Wingman) |
| `CS2_CHEATS` | `0` | Enable cheats (0=off, 1=on) |
| `TV_ENABLE` | `0` | Enable CSTV/SourceTV (0=off, 1=on) |
| `TV_PORT` | `27020` | CSTV port |

## Connecting Players (UDP via playit.gg)

Railway's public network only exposes TCP/HTTP — CS2's game traffic is UDP, so players connect through the bundled `playit` tunnel agent instead of the Railway domain.

The template deploys two services:

- **cs2** — the game server (UDP :27015 game, UDP :27020 CSTV, TCP :27015 RCON, persistent volume)
- **playit** — the [playit.gg](https://playit.gg) agent, which makes outbound connections to playit.gg's edge and tunnels player traffic over Railway's private network to `cs2.railway.internal:27015`

### One-time setup (after deploy)

1. Create a free account at [playit.gg](https://playit.gg)
2. Account → Agents → **Add Agent** → copy the **secret key**
3. In Railway, open the `playit` service → Variables → paste the key as `SECRET_KEY`
4. In playit.gg → Tunnels → **Add Tunnel**:
   - Type: **UDP**
   - Local address: `cs2.railway.internal`
   - Local port: `27015`
5. If you enabled CSTV (`TV_ENABLE=1`), add a second tunnel the same way with local port `27020`
6. Give players the allocation address playit.gg assigns — they add it in CS2 → Play → Community Server Browser → Add Server

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 27015 | UDP | Game port (via playit.gg tunnel) |
| 27015 | TCP | RCON (if enabled, via Railway TCP proxy) |
| 27020 | UDP | CSTV/SourceTV (via second playit.gg tunnel) |

## Why Deploy

- **Persistent game data**: configs, maps, and logs survive deploys via Railway volume
- **Zero-downtime updates**: redeploy without losing server state
- **SourceTV support**: broadcast matches with built-in CSTV
- **Full config control**: 32+ env vars for maps, gamemodes, logging, and more

## Common Use Cases

- Host a competitive CS2 server for ranked practice
- Run a private community server with custom maps and mods
- Set up a CSTV relay for tournament broadcasting
- Test custom configs and gamemodes without local Docker setup

## Dependencies for

### Deployment Dependencies

- A Railway account
- A Steam Game Server Login Token (free from steamcommunity.com)
- A free [playit.gg](https://playit.gg) account (for the UDP game tunnel — required for players to connect)
