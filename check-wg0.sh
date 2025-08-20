#!/bin/bash -l
set -euo pipefail

# Check if wg0 interface exists and is up
if ip link show wg0 > /dev/null 2>&1; then
    echo "[WIREGUARD] wg0 is up"
else
    echo "[WIREGUARD] wg0 does not exist or is down"
    exit 1
fi

# Get current time
CURRENT_TIME=$(date +%s)

# Get latest handshakes
if ! HANDSHAKES_RAW=$(wg show wg0 latest-handshakes 2>/dev/null); then
    echo "[WIREGUARD] Failed to get latest-handshakes from wg0"
    exit 1
fi

HANDSHAKES=$(echo "$HANDSHAKES_RAW" | awk '{print $2}')
HANDSHAKE_FOUND=0

for hs in $HANDSHAKES; do
    if [ "$hs" -gt 0 ]; then
        DIFF=$((CURRENT_TIME - hs))
        if [ "$DIFF" -lt 300 ]; then
            HANDSHAKE_FOUND=1
            echo "[WIREGUARD] Recent handshake detected ($DIFF seconds ago)"
            break
        fi
    fi
done

if [ "$HANDSHAKE_FOUND" -eq 1 ]; then
    echo "[WIREGUARD] wg0 has recent handshake(s)"
    exit 0
else
    echo "[WIREGUARD] No recent handshakes found on wg0"
    exit 1
fi
