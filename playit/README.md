# playit — UDP Tunnel Agent Service

Companion service in the CS2 template. Runs the official
[`ghcr.io/playit-cloud/playit-agent`](https://github.com/playit-cloud/playit-agent)
image (pinned `1.0.8`) as a **direct image source**. No Dockerfile: the upstream
image is deployed as-is with one variable.

## Why this service exists

Railway's public network is TCP/HTTP only — CS2's game traffic (UDP :27015 game,
UDP :27020 CSTV) cannot be exposed directly. The playit agent makes **outbound**
connections to playit.gg's edge and tunnels player UDP traffic back over
Railway's private network to `cs2.railway.internal:27015`.

Note: RCON (TCP 27015) is unaffected — TCP can be exposed natively on Railway
(e.g. via a TCP proxy). Only the UDP ports need the tunnel.

## Variable

`SECRET_KEY` — the agent secret from your playit.gg account (required).

The upstream entrypoint runs: `playitd --secret $SECRET_KEY --platform-docker`.
Until a valid key is set, the agent exits with an auth error and restarts
(non-fatal to the cs2 service).

## Post-deploy setup (manual, in playit.gg dashboard)

1. Create a free account at https://playit.gg
2. Account → Agents → **Add Agent** → copy the **secret key**
3. In Railway, set `SECRET_KEY` on the `playit` service
4. In playit.gg → Tunnels → **Add Tunnel**:
   - Type: **UDP**
   - Local address: `cs2.railway.internal`
   - Local port: `27015`
5. If you enabled CSTV (`TV_ENABLE=1`), add a **second tunnel**: UDP,
   local address `cs2.railway.internal`, local port `27020`
6. Give players the allocation address playit.gg assigns

Cross-service private networking resolves `cs2.railway.internal` automatically
within the same Railway project.