# If you migrate to chirpstack=>4.7v, a migration needs to be done
#check this: https://www.chirpstack.io/docs/chirpstack/changelog.html#v470
FROM chirpstack/chirpstack:4.6

ENV DEVICE_TEMPLATES_REPO=https://github.com/TheThingsNetwork/lorawan-devices
ENV TARGET_DIR=/opt/lorawan-devices

USER root

# Install git
RUN apk update && apk add --no-cache git bash

# clone repo
RUN git clone ${DEVICE_TEMPLATES_REPO} -b master --single-branch ${TARGET_DIR} ; \
    cd ${TARGET_DIR} ; \
    rm -rf .git

# Copy your script into the container
COPY update-and-import.sh /usr/local/bin/update-and-import.sh
RUN chmod +x /usr/local/bin/update-and-import.sh

# Set up cron job
# RUN echo '0 * * * * /usr/local/bin/update-and-import.sh' > /etc/crontabs/root
RUN echo '*/15 * * * * /usr/local/bin/update-and-import.sh' > /etc/crontabs/root

# restore the running as `nobody` as is defined by chirpstack docker image
USER nobody:nogroup
