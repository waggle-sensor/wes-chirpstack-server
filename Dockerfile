FROM chirpstack/chirpstack:4.0.3

# only necessary to enable permissions for the install of additional packages
USER root

RUN apt-get update && apt-get install --no-install-recommends -y \
    python3 \
    python3-psycopg2

COPY postStart.py .

# restore the running as `nobody` as is defined by `chirpstack/chirpstack:4.0.3`
USER nobody:nogroup
# We want to leave the default ENTRYPOINT, as the postStart.py is started by a Kubernetes postStart command