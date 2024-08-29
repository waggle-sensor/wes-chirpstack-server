# If you migrate to chirpstack=>4.7v, a migration needs to be done
#check this: https://www.chirpstack.io/docs/chirpstack/changelog.html#v470
FROM chirpstack/chirpstack:4.6

ENV DEVICE_TEMPLATES_REPO=https://github.com/waggle-sensor/wes-lorawan-device-templates
ENV TARGET_DIR=/opt/lorawan-devices

USER root

# Install packages
RUN apk update && apk add --no-cache git bash sudo

# add crond to be used with sudo by nobody user
RUN echo 'nobody ALL=(ALL) NOPASSWD: /usr/sbin/crond' > /etc/sudoers

# clone DEVICE_TEMPLATES_REPO 
RUN git clone ${DEVICE_TEMPLATES_REPO} -b master --single-branch ${TARGET_DIR}

# Copy script into the container
COPY device-templates.sh /usr/local/bin/device-templates.sh

RUN chown -R nobody:nogroup ${TARGET_DIR}

# Set permissions to be rwx for owner and rx for group/others
RUN chmod 755 /usr/local/bin/device-templates.sh

# Set permissions to be rwx for owner and rx for group/others
# TODO: do I need this once /opt/lorawan-devices is created? first try removing this completelly 
# RUN chmod 777 ${TARGET_DIR}

# Set up cron job
# RUN echo '*/30 * * * * /usr/local/bin/device-templates.sh' > /etc/crontabs/root
RUN echo '*/1 * * * * /usr/local/bin/device-templates.sh' > /etc/crontabs/root

# restore the running as `nobody` as is defined by chirpstack docker image
USER nobody:nogroup
