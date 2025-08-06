# If you migrate to chirpstack=>4.7v, a migration needs to be done
#check this: https://www.chirpstack.io/docs/chirpstack/changelog.html#v470
FROM chirpstack/chirpstack:4.6

ENV DEVICE_TEMPLATES_REPO=https://github.com/waggle-sensor/wes-lorawan-device-templates
ENV TARGET_DIR=/opt/lorawan-devices

USER root

# Install packages
RUN apk update && apk add --no-cache go git bash sudo wireguard-tools jq \
 && git clone https://git.zx2c4.com/wireguard-go \
 && cd wireguard-go \
 && make \
 && cp wireguard-go /usr/local/bin/wireguard-go \
 && cd .. && rm -rf wireguard-go

# clone DEVICE_TEMPLATES_REPO 
RUN git clone ${DEVICE_TEMPLATES_REPO} -b master --single-branch ${TARGET_DIR}

# Copy scripts into the container
COPY device-templates.sh /usr/local/bin/device-templates.sh
COPY init-wireguard.sh /usr/local/bin/init-wireguard.sh
COPY check-wg0.sh /usr/local/bin/check-wg0.sh

# add crond to be used with sudo by nobody user & 
# add global env vars to be used in cron & 
# Set permissions &
# Set up cron job
RUN echo 'nobody ALL=(ALL) NOPASSWD: /usr/sbin/crond' > /etc/sudoers && \
    printenv > /etc/environment && \
    chown -R nobody:nogroup ${TARGET_DIR} /etc/environment && \
    chmod 755 /usr/local/bin/device-templates.sh /usr/local/bin/init-wireguard.sh /usr/local/bin/check-wg0.sh && \
    echo '0 * * * * /usr/local/bin/device-templates.sh' > /etc/crontabs/root && \
    echo '*/5 * * * * /usr/local/bin/init-wireguard.sh' >> /etc/crontabs/root

# restore the running as `nobody` as is defined by chirpstack docker image
USER nobody:nogroup
