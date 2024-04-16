FROM chirpstack/chirpstack:4.6

ENV TTN_REPO=https://github.com/TheThingsNetwork/lorawan-devices
ENV TTN_VERSION=277e69a79347ceba2593e1da08117d0e3329ecda

USER root

COPY requirements.txt /tmp

RUN apk update && \
    apk add --no-cache git python3 py3-pip py3-grpcio build-base linux-headers g++ && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    pip3 install --upgrade pip && \
    pip3 install --no-cache-dir -r /tmp/requirements.txt && \
    #clean up
    rm /tmp/requirements.txt && \
    apk del \
    g++ \
    linux-headers \
    build-base

RUN git clone ${TTN_REPO} -b master --single-branch /opt/lorawan-devices ; \
    cd /opt/lorawan-devices ; \
    git checkout ${TTN_VERSION} ; \
    rm -rf .git

# restore the running as `nobody` as is defined by chirpstack docker image
USER nobody:nogroup
