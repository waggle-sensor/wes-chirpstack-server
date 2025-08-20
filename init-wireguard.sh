#!/bin/bash -l

# Check if WG_GET_CONFIG_ENDPOINT is set
if [ -z "$WG_GET_CONFIG_ENDPOINT" ]; then
    echo "[WIREGUARD] WG_GET_CONFIG_ENDPOINT not set, exiting. Please set this environment variable to the GET WireGuard config endpoint."
    exit 0
fi

# check if AUTH_NODE_KEYWORD is set
if [ -z "$AUTH_NODE_KEYWORD" ]; then
    echo "[WIREGUARD] AUTH_NODE_KEYWORD not set, exiting. Please set this environment variable to the authorization keyword for the GET WireGuard config endpoint."
    exit 0
fi

# Check if wg0 is up and healthy
if /usr/local/bin/check-wg0.sh; then
    exit 0
else
    echo "[WIREGUARD] wg0 not up or stale handshake."
    ip link del wg0 2>/dev/null || true
fi

# Check for token
echo "[WIREGUARD] Looking for django token..."
if [ ! -f /mnt/token/token ]; then
    echo "[WIREGUARD] Token not found, exiting"
    exit 0
else
    NODE_TOKEN=$(cat /mnt/token/token)
    echo "[WIREGUARD] Token found!"
fi

# Fetch WireGuard config
echo "[WIREGUARD] Fetching WireGuard config from $WG_GET_CONFIG_ENDPOINT ..."
JSON=$(wget --quiet --header="Authorization: $AUTH_NODE_KEYWORD $NODE_TOKEN" \
             "$WG_GET_CONFIG_ENDPOINT" -O -)

if [ -z "$JSON" ]; then
    echo "[WIREGUARD] Failed to fetch WireGuard config or empty response. Exiting."
    exit 1
fi

# Parse and validate config fields
echo "[WIREGUARD] Parsing config..."
NODE_PUB_KEY=$(echo "$JSON" | jq -r '.[0].node_wg_pub_key')
NODE_PRIV_KEY=$(echo "$JSON" | jq -r '.[0].node_wg_priv_key')
NODE_WG_IP=$(echo "$JSON" | jq -r '.[0].node_wg_ip')
SERVER_PUB_KEY=$(echo "$JSON" | jq -r '.[0].server_pub_key')
SERVER_PUB_IP=$(echo "$JSON" | jq -r '.[0].server_pub_ip')
SERVER_PORT=$(echo "$JSON" | jq -r '.[0].server_wg_port')
SERVER_WG_IP=$(echo "$JSON" | jq -r '.[0].server_wg_ip')

# Validate required values
if [ -z "$NODE_PRIV_KEY" ] || [ -z "$NODE_WG_IP" ] || [ -z "$SERVER_PUB_KEY" ] || [ -z "$SERVER_PUB_IP" ] || [ -z "$SERVER_PORT" ] || [ -z "$SERVER_WG_IP" ]; then
    echo "[WIREGUARD] One or more required fields are missing in the config. Exiting."
    exit 1
fi

# Write config to file
mkdir -p /wireguard/config
IFACE=wg0
WG_CONFIG="/wireguard/config/$IFACE.conf"
echo "[WIREGUARD] Writing WireGuard config to $WG_CONFIG ..."
cat <<EOF > $WG_CONFIG
[Interface]
PrivateKey = $NODE_PRIV_KEY

[Peer]
PublicKey = $SERVER_PUB_KEY
Endpoint = $SERVER_PUB_IP:$SERVER_PORT
AllowedIPs = $SERVER_WG_IP/32
PersistentKeepalive = 25
EOF
chmod 600 $WG_CONFIG

# Start WireGuard in user space
echo "[WIREGUARD] Starting wireguard-go on interface $IFACE ..."
wireguard-go $IFACE &
WG_PID=$!
sleep 10

# Check if interface created
if ! ip link show $IFACE > /dev/null 2>&1; then
    echo "[WIREGUARD] Interface $IFACE not found. Killing wireguard-go. Exiting."
    kill $WG_PID
    exit 1
fi

# Assign IP
echo "[WIREGUARD] Assigning IP $NODE_WG_IP to $IFACE ..."
ip address add $NODE_WG_IP dev $IFACE
ip link set up dev $IFACE

# Apply the config
wg setconf $IFACE $WG_CONFIG
ip route add $SERVER_WG_IP/32 dev $IFACE

# Set up routing (container-only). TODO: Check if wg0 shows up outside the container
# ip route del default
# ip route add default dev $IFACE

echo "[WIREGUARD] WireGuard-go started successfully!"