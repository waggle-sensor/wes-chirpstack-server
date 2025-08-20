#!/bin/bash -l

# Clone or update the repository
if [ ! -d "$TARGET_DIR" ]; then
  echo "[DEVICE-TEMPLATES] Cloning repository $DEVICE_TEMPLATES_REPO to $TARGET_DIR"
  git clone "$DEVICE_TEMPLATES_REPO" -b master --single-branch "$TARGET_DIR"
else
  echo "[DEVICE-TEMPLATES] Updating repository in $TARGET_DIR"
  cd "$TARGET_DIR"
  git pull
fi

# Run the Chirpstack command to import device templates
echo "[DEVICE-TEMPLATES] Running Chirpstack import device-templates command"
chirpstack -c /etc/chirpstack-waggle import-legacy-lorawan-devices-repository -d "$TARGET_DIR"
