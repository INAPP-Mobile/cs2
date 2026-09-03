# Deploy and Host

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy/-U7Su3)

Counter-Strike 2 Dedicated Server — one-click deploy with persistent volume, CSTV support, and zero-downtime updates. Powered by [joedwards32/CS2](https://github.com/joedwards32/CS2).

After deploying, open CS2 → Play → Community Server Browser → Add Server: `:27015`

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

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 27015 | TCP/UDP | Game server |
| 27020 | UDP | CSTV/SourceTV |

## Storage

This template provisions a 30GB volume for game data. CS2 dedicated server requires ~20GB for the base install. Increase the volume size in `railway.json` if you plan to host custom maps or workshop content.

## Configuration

### Custom Config Bundle

Set `CS2_CFG_URL` to a `.zip`, `.tar.gz`, or `.tar` URL. The bundle is extracted into the game directory on startup.

### Workshop Maps (Experimental)

Set `CS2_HOST_WORKSHOP_COLLECTION` to a Workshop Collection ID. Maps can be selected via RCON:
```
ds_workshop_listmaps
ds_workshop_changelevel $map_name
```

## License

Counter-Strike is a trademark of Valve Corporation. This project is not affiliated with or endorsed by Valve.
