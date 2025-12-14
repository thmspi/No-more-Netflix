#!/usr/bin/env bash
set -euo pipefail

# =========================
# User-configurable values
# =========================
NAS_IP="<NAS_IP>"
NAS_SHARE="plex-stack"

MOUNT_POINT="/mnt/plex_nas"

NAS_USER="<NAS_USER>"
NAS_PWD="<NAS_PWD>"

CREDS_FILE="/etc/samba/plex_nas.cred"

UID_TO_USE="1000"
GID_TO_USE="1000"

# =========================
# Script
# =========================
log() { printf "\n[%s] %s\n" "$(date +'%F %T')" "$*"; }

if [[ $EUID -eq 0 ]]; then
  echo "Run this script as a normal user, not root."
  exit 1
fi

log "Updating system packages"
sudo apt update -y
sudo apt upgrade -y

log "Installing packages"
sudo apt install -y \
  docker.io \
  docker-compose-plugin \
  tree \
  cifs-utils

log "Enabling and starting Docker"
sudo systemctl enable --now docker

log "Docker versions"
docker --version
docker compose version

log "Creating mount point: ${MOUNT_POINT}"
sudo mkdir -p "${MOUNT_POINT}"

log "Creating CIFS credentials file"
sudo mkdir -p "$(dirname "${CREDS_FILE}")"

sudo bash -c "cat > '${CREDS_FILE}' <<EOF
username=${NAS_USER}
password=${NAS_PWD}
EOF"

sudo chmod 600 "${CREDS_FILE}"

log "Credentials file created at ${CREDS_FILE} (permissions set to 600)"

REMOTE="//${NAS_IP}/${NAS_SHARE}"
CIFS_OPTS="credentials=${CREDS_FILE},iocharset=utf8,file_mode=0777,dir_mode=0777,uid=${UID_TO_USE},gid=${GID_TO_USE},nofail,_netdev"
FSTAB_LINE="${REMOTE} ${MOUNT_POINT} cifs ${CIFS_OPTS} 0 0"

log "Ensuring /etc/fstab contains NAS mount"
if ! grep -qsE "^${REMOTE}[[:space:]]+${MOUNT_POINT}[[:space:]]+cifs" /etc/fstab; then
  echo "${FSTAB_LINE}" | sudo tee -a /etc/fstab >/dev/null
  log "Added fstab entry"
else
  log "fstab entry already exists (skipping)"
fi

log "Mounting all filesystems"
sudo mount -a

log "Verifying mount"
if mountpoint -q "${MOUNT_POINT}"; then
  log "SUCCESS: ${MOUNT_POINT} is mounted"
  df -h | grep -F "${MOUNT_POINT}" || true
else
  log "ERROR: mount failed — check NAS IP, share name, or credentials"
  exit 1
fi

log "Setup complete"
