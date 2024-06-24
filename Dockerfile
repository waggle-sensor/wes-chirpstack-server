FROM chirpstack/chirpstack:4.6

ENV TTN_REPO=https://github.com/TheThingsNetwork/lorawan-devices
ENV TTN_VERSION=277e69a79347ceba2593e1da08117d0e3329ecda

USER root

RUN apk update && apk add --no-cache git chirpstack-rest-api

RUN git clone ${TTN_REPO} -b master --single-branch /opt/lorawan-devices ; \
    cd /opt/lorawan-devices ; \
    git checkout ${TTN_VERSION} ; \
    rm -rf .git

# restore the running as `nobody` as is defined by chirpstack docker image
USER nobody:nogroup
