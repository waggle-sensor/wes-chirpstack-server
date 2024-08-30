# If you migrate to chirpstack=>4.7v, a migration needs to be done
#check this: https://www.chirpstack.io/docs/chirpstack/changelog.html#v470
FROM chirpstack/chirpstack:4.6

ENV DEVICE_TEMPLATES_REPO=https://github.com/waggle-sensor/wes-lorawan-device-templates
ENV TARGET_DIR=/opt/lorawan-devices

USER root

# Install packages
RUN apk update && apk add --no-cache git bash sudo

# clone DEVICE_TEMPLATES_REPO 
RUN git clone ${DEVICE_TEMPLATES_REPO} -b master --single-branch ${TARGET_DIR}

# Copy script into the container
COPY device-templates.sh /usr/local/bin/device-templates.sh

# add crond to be used with sudo by nobody user & 
# add global env vars to be used in cron & 
# Set permissions &
# Set up cron job
RUN echo 'nobody ALL=(ALL) NOPASSWD: /usr/sbin/crond' > /etc/sudoers && \
    printenv > /etc/environment && \
    chown -R nobody:nogroup ${TARGET_DIR} /etc/environment && \
    chmod 755 /usr/local/bin/device-templates.sh && \
    echo '*/1 * * * * /usr/local/bin/device-templates.sh' > /etc/crontabs/root
    #'*/30 * * * * /usr/local/bin/device-templates.sh' > /etc/crontabs/root

# restore the running as `nobody` as is defined by chirpstack docker image
USER nobody:nogroup
