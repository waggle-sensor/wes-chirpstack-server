FROM chirpstack/chirpstack:4.6

USER root

# Install cron and git
RUN apk update && apk add --no-cache cron git bash

# Copy your script into the container
COPY update-and-import.sh /usr/local/bin/update-and-import.sh
RUN chmod +x /usr/local/bin/update-and-import.sh

# Set up cron job
RUN echo '0 * * * * /usr/local/bin/update-and-import.sh' > /etc/crontabs/root

# restore the running as `nobody` as is defined by chirpstack docker image
USER nobody:nogroup

# Start cron and then ChirpStack
CMD ["sh", "-c", "crond && chirpstack -c /etc/chirpstack-waggle"]