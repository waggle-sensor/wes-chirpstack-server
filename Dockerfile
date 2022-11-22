FROM chirpstack/chirpstack:4.0.4

ENV TTN_REPO=https://github.com/TheThingsNetwork/lorawan-devices
ENV TTN_VERSION=6c3b4856ebe08de7ffb1642e0d9b5200ff0c4750

USER root

RUN apt-get update && apt-get install --no-install-recommends -y \
    git

RUN git clone ${TTN_REPO} -b master --single-branch /opt/lorawan-devices ; \
    cd /opt/lorawan-devices ; \
    git checkout ${TTN_VERSION} ; \
    rm -rf .git

# restore the running as `nobody` as is defined by `chirpstack/chirpstack:4.0.3`
USER nobody:nogroup
# We want to leave the default ENTRYPOINT, as the postStart.py is started by a Kubernetes postStart command
