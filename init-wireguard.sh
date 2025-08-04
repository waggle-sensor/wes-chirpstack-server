#!/bin/sh

# Check if WG_GET_CONFIG_ENDPOINT is set
if [ -z "$WG_GET_CONFIG_ENDPOINT" ]; then
    echo "[WIREGUARD] WG_GET_CONFIG_ENDPOINT not set, exiting. Please set this environment variable to the endpoint to get the WireGuard config."
    exit 0
fi

# Check if wg0 is up
if /usr/local/bin/check-wg0.sh; then
    exit 0
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
echo "[WIREGUARD] Fetching WireGuard config..."
JSON=$(curl -s -H "Authorization: node_auth $NODE_TOKEN" $ENDPOINT)
echo "[WIREGUARD] Parsing config and writing wg0.conf..."
mkdir -p /wireguard/config
NODE_PUB_KEY=$(echo $JSON | jq -r '.[0].node_wg_pub_key')
NODE_PRIV_KEY=$(echo $JSON | jq -r '.[0].node_wg_priv_key')
NODE_WG_IP=$(echo $JSON | jq -r '.[0].node_wg_ip')
SERVER_PUB_KEY=$(echo $JSON | jq -r '.[0].server_pub_key')
SERVER_PUB_IP=$(echo $JSON | jq -r '.[0].server_pub_ip')
SERVER_PORT=$(echo $JSON | jq -r '.[0].server_wg_port')
SERVER_WG_IP=$(echo $JSON | jq -r '.[0].server_wg_ip')

# Write wg0.conf
cat <<EOF > /wireguard/config/wg0.conf
[Interface]
PrivateKey = $NODE_PRIV_KEY
Address = $NODE_WG_IP

[Peer]
PublicKey = $SERVER_PUB_KEY
Endpoint = $SERVER_PUB_IP:$SERVER_PORT
AllowedIPs = $SERVER_WG_IP/32
PersistentKeepalive = 25
EOF

# Start WireGuard
echo "[WIREGUARD] WireGuard config written to /wireguard/config/wg0.conf"
echo "[WIREGUARD] Starting WireGuard..."
wg-quick up /wireguard/config/wg0.conf
echo "[WIREGUARD] WireGuard started!"
