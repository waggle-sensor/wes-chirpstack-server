# Waggle Edge Stack Chirpstack Application Server

This is an extension of the [Chirpstack Appliction Server (v4)](https://www.chirpstack.io/docs/chirpstack/changelog.html) adding [The Things Network LoRaWAN device profile templates](https://github.com/TheThingsNetwork/lorawan-devices).

This project simply...
- clones the The Things Network LoRaWAN github repository into the Chirpstack application server Docker image, allowing for the LoRaWAN device profiles to be imported.
- Adds python, pip, and libs to be able to run init scripts using python

> Note: the specific version chosen of the [The Things Network LoRaWAN device profile templates](https://github.com/TheThingsNetwork/lorawan-devices) was the last version that had `Apache License 2.0`. Newer version cannot be replicated. You are, however, permitted to reuse or extract information about an individual end device. 

References:
- https://www.chirpstack.io/docs/chirpstack/use/device-profile-templates.html
