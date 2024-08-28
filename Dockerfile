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

# clone repo 
# TODO: uncomment once done testing
# RUN git clone ${DEVICE_TEMPLATES_REPO} -b master --single-branch ${TARGET_DIR} ; \
#     cd ${TARGET_DIR} ; \
#     rm -rf .git

# Copy script into the container
COPY update-and-import.sh /usr/local/bin/update-and-import.sh

# Set permissions to be rwx for owner and rx for group/others
RUN chmod 755 /usr/local/bin/update-and-import.sh

# Set permissions to be rwx for owner and rx for group/others
# TODO: change /opt to ${TARGET_DIR}, do I need this once /opt/lorawan-devices is created? first try removing this completelly 
RUN chmod 777 /opt

# Set up cron job
# RUN echo '*/30 * * * * /usr/local/bin/update-and-import.sh' > /etc/crontabs/root
RUN echo '*/1 * * * * /usr/local/bin/update-and-import.sh >> /dev/stdout 2>> /dev/stderr' > /etc/crontabs/root

# restore the running as `nobody` as is defined by chirpstack docker image
USER nobody:nogroup
