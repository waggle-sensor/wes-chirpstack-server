FROM chirpstack/chirpstack:4.6

ENV DEVICE_TEMPLATE_REPO=https://github.com/waggle-sensor/wes-lorawan-device-templates

USER root

RUN apk update && apk add --no-cache git

RUN git clone ${DEVICE_TEMPLATE_REPO} -b master --single-branch /opt/lorawan-devices ; \
    cd /opt/lorawan-devices ; \
    rm -rf .git

# restore the running as `nobody` as is defined by chirpstack docker image
USER nobody:nogroup
