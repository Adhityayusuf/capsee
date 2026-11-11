#!/usr/bin/env bash
# Ambil kode terbaru dan restart backend. Jalankan di VM: sudo bash /opt/capsee/deploy/update.sh
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/capsee}"
APP_USER="${APP_USER:-capsee}"
BRANCH="${BRANCH:-main}"

[[ $EUID -eq 0 ]] || { echo "Jalankan dengan sudo." >&2; exit 1; }

sudo -u "$APP_USER" git -C "$APP_DIR" fetch --quiet origin "$BRANCH"
sudo -u "$APP_USER" git -C "$APP_DIR" reset --hard "origin/$BRANCH"
sudo -u "$APP_USER" "$APP_DIR/backend/venv/bin/pip" install -q -r "$APP_DIR/backend/requirements.txt"
systemctl restart capsee-backend
sleep 2
systemctl is-active --quiet capsee-backend && echo "backend: ok" || {
  journalctl -u capsee-backend -n 40 --no-pager
  exit 1
}
