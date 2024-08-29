#!/bin/sh
DEVICE_TEMPLATES_REPO=https://github.com/waggle-sensor/wes-lorawan-device-templates
TARGET_DIR=/opt/lorawan-devices

# Clone or update the repository
{
  if [ ! -d "$TARGET_DIR" ]; then
    echo "Cloning repository $DEVICE_TEMPLATES_REPO to $TARGET_DIR"
    git clone "$DEVICE_TEMPLATES_REPO" -b master --single-branch "$TARGET_DIR"
  else
    echo "Updating repository in $TARGET_DIR"
    cd "$TARGET_DIR"
    git pull
  fi

  # Run the Chirpstack command to import device templates
  echo "Running Chirpstack import command"
  chirpstack -c /etc/chirpstack-waggle import-legacy-lorawan-devices-repository -d "$TARGET_DIR"
} >> /proc/1/fd/1 2>> /proc/1/fd/2
