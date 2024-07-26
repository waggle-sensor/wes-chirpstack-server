#!/bin/sh

# Define repository
REPO_URL="https://github.com/waggle-sensor/wes-lorawan-device-templates"
TARGET_DIR="/opt/lorawan-devices"

# Clone or update the repository
if [ ! -d "$TARGET_DIR" ]; then
  git clone "$REPO_URL" -b master --single-branch "$TARGET_DIR"
else
  cd "$TARGET_DIR"
  git pull
fi

# Run the Chirpstack command to import device templates
chirpstack -c /etc/chirpstack-waggle import-legacy-lorawan-devices-repository -d "$TARGET_DIR"
