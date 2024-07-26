# Waggle Edge Stack Chirpstack Application Server

This is an extension of the [Chirpstack Appliction Server (v4)](https://www.chirpstack.io/docs/chirpstack/changelog.html) adding [Waggle's LoRaWAN device profile templates](https://github.com/waggle-sensor/wes-lorawan-device-templates).

This project periodically clones our LoRaWAN device profile templates into the Chirpstack application server Docker image, allowing for the LoRaWAN device profiles to be periodically imported.

References:
- https://www.chirpstack.io/docs/chirpstack/use/device-profile-templates.html
