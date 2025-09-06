#!/usr/bin/env bash
set -euo pipefail

# Mount helper for CIFS network share //192.168.1.18/config
# Usage: sudo ./scripts/mount_remote_config.sh [--fstab]
#
# This script creates /mnt/remote_config, creates a credentials file at
# /root/.smbcredentials (interactive), mounts the share, and optionally
# prints an /etc/fstab line for persistent mounts.

MOUNT_POINT="/mnt/remote_config"
REMOTE="//192.168.1.18/config"
CREDENTIALS_FILE="/root/.smbcredentials"

print_usage() {
  cat <<EOF
Usage: sudo $0 [--fstab]

Options:
  --fstab   Print an /etc/fstab line you can add for persistence

This script will prompt for username and password and store them in
${CREDENTIALS_FILE} with mode 600. Do NOT commit credentials into git.
EOF
}

if [[ "${1-}" == "--fstab" ]]; then
  FSTAB_ONLY=1
else
  FSTAB_ONLY=0
fi

if [[ $EUID -ne 0 && $FSTAB_ONLY -eq 0 ]]; then
  echo "This script must be run as root to perform mounts. Use sudo." >&2
  exit 1
fi

if [[ $FSTAB_ONLY -eq 1 ]]; then
  echo "${REMOTE} ${MOUNT_POINT} cifs credentials=${CREDENTIALS_FILE},uid=1000,gid=1000,file_mode=0644,dir_mode=0755 0 0"
  exit 0
fi

mkdir -p "$MOUNT_POINT"

if [[ ! -f "$CREDENTIALS_FILE" ]]; then
  echo "Creating credentials file at ${CREDENTIALS_FILE}"
  read -rp "SMB username: " SMB_USER
  read -rsp "SMB password: " SMB_PASS
  echo
  cat > "$CREDENTIALS_FILE" <<EOF
username=${SMB_USER}
password=${SMB_PASS}
EOF
  chmod 600 "$CREDENTIALS_FILE"
fi

echo "Mounting ${REMOTE} -> ${MOUNT_POINT}"
mount -t cifs "$REMOTE" "$MOUNT_POINT" -o credentials="$CREDENTIALS_FILE",uid=$(id -u 1000 2>/dev/null || echo 1000),gid=$(id -g 1000 2>/dev/null || echo 1000),file_mode=0644,dir_mode=0755

echo "Mounted. To make persistent, add the following line to /etc/fstab:"
echo
echo "${REMOTE} ${MOUNT_POINT} cifs credentials=${CREDENTIALS_FILE},uid=1000,gid=1000,file_mode=0644,dir_mode=0755 0 0"
