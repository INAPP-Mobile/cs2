#!/bin/bash
set -e

# Railway volume is root-owned by default.
# Upstream runs as steam (uid 1000) — chown volume before dropping privileges.
if [ -d "/home/steam/cs2-dedicated" ]; then
    chown -R 1000:1000 /home/steam/cs2-dedicated
fi

# Drop to steam user and exec the upstream entrypoint
exec su -s /bin/bash -c 'exec bash entry.sh' steam
