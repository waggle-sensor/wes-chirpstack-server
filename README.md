# Waggle Edge Stack Chirpstack Application Server

This is an extension of the [Chirpstack Appliction Server (v4)](https://www.chirpstack.io/docs/chirpstack/changelog.html) adding [Waggle's LoRaWAN device profile templates](https://github.com/waggle-sensor/wes-lorawan-device-templates) and support for WireGuard VPN.

## LoRaWAN Device Profile Templates
This project clones our [LoRaWAN device profile templates](https://github.com/waggle-sensor/wes-lorawan-device-templates) via a cron job into the Chirpstack server, allowing for the LoRaWAN device profiles to be periodically pulled and imported to chirpstack.
- The `device-templates.sh` script is used to clone and import the LoRaWAN device profile templates into the Chirpstack server.
- The cron job is scheduled to run every hour.

## WireGuard VPN Integration
Our project also includes a WireGuard VPN connection to [waggle-auth-app](https://github.com/waggle-sensor/waggle-auth-app), which is required for our Cloud infrastructure to have access to the gRPC endpoint in our Chirpstack servers sitting in our nodes.
- The WireGuard configuration is managed through the `init-wireguard.sh` script, which handles the setup and management of the VPN connection.
    - The WireGuard configuration is fetched from a specified endpoint, which requires authentication using a token and keyword.
    - The required variables for the script to run include `WG_GET_CONFIG_ENDPOINT`, `AUTH_NODE_KEYWORD`, and `django-token` secret in `/mnt/token`.
- The `check-wg0.sh` script checks if the WireGuard interface is up and has recent handshakes, ensuring a stable VPN connection.
- The cron job is scheduled to run every 5 minutes to ensure the WireGuard connection is active.

## Versioning
The version of the `wes-chirpstack-server` is aligned with the version of the `chirpstack/chirpstack` image, but the patch version can differ.

For example, if the `chirpstack/chirpstack` image is at version 4.14, the `wes-chirpstack-server` is at version 4.14. But if a patch version is needed, the `wes-chirpstack-server` can be at version 4.14.1 even if the `chirpstack/chirpstack` image is at version 4.14.0.

References:
- https://www.chirpstack.io/docs/chirpstack/use/device-profile-templates.html
- https://www.wireguard.com
