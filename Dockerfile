# If you migrate to chirpstack=>4.7v, a migration needs to be done
#check this: https://www.chirpstack.io/docs/chirpstack/changelog.html#v470
FROM chirpstack/chirpstack:4.6

ENV DEVICE_TEMPLATES_REPO=https://github.com/waggle-sensor/wes-lorawan-device-templates
ENV TARGET_DIR=/opt/lorawan-devices

USER root

# Install git
RUN apk update && apk add --no-cache git bash

# clone repo 
# TODO: uncomment once done testing
# RUN git clone ${DEVICE_TEMPLATES_REPO} -b master --single-branch ${TARGET_DIR} ; \
#     cd ${TARGET_DIR} ; \
#     rm -rf .git

# Copy script into the container
COPY update-and-import.sh /usr/local/bin/update-and-import.sh

# Set permissions to be read and executable by the owner and others
RUN chmod 555 /usr/local/bin/update-and-import.sh

# Set permissions to allow rwx for owner/group/others
# TODO: change /opt to ${TARGET_DIR}
RUN chmod 777 /opt

# Set cron permissions to root and nobody so that the cronjobs can run under these users
RUN echo 'root' > /etc/cron.allow && echo 'nobody' >> /etc/cron.d/cron.allow

# Set up cron job
# RUN echo '*/30 * * * * /usr/local/bin/update-and-import.sh' > /etc/crontabs/root
RUN echo '*/1 * * * * /usr/local/bin/update-and-import.sh >> /proc/1/fd/1 2>> /proc/1/fd/2' > /etc/crontabs/nobody

# restore the running as `nobody` as is defined by chirpstack docker image
USER nobody:nogroup
