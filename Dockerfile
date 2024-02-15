FROM chirpstack/chirpstack:4.6

ENV TTN_REPO=https://github.com/TheThingsNetwork/lorawan-devices
ENV TTN_VERSION=6c3b4856ebe08de7ffb1642e0d9b5200ff0c4750

USER root

RUN apk update && apk add --no-cache git

RUN git clone ${TTN_REPO} -b master --single-branch /opt/lorawan-devices ; \
    cd /opt/lorawan-devices ; \
    git checkout ${TTN_VERSION} ; \
    rm -rf .git

# restore the running as `nobody` as is defined by chirpstack docker image
USER nobody:nogroup
