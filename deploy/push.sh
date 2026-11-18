#!/usr/bin/env bash
# Kirim kode dari laptop ke VM (untuk repo privat tanpa deploy key).
# Jalankan dari laptop: ./deploy/push.sh <ip-atau-host>
set -euo pipefail

HOST="${1:-}"
[[ -n "$HOST" ]] || { echo "Pemakaian: ./deploy/push.sh <ip-atau-host>" >&2; exit 1; }

SSH_USER="${SSH_USER:-$USER}"
APP_USER="${APP_USER:-capsee}"
APP_DIR="${APP_DIR:-/opt/capsee}"
REMOTE_TMP="/tmp/capsee-src"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

rsync -az --info=progress2 \
  --exclude '.git' \
  --exclude 'build' \
  --exclude '.dart_tool' \
  --exclude 'backend/venv' \
  --exclude 'backend/.env' \
  --exclude '__pycache__' \
  --exclude '*.pyc' \
  --exclude '*.log' \
  --exclude 'android/.gradle' \
  --exclude 'ios/Pods' \
  "$ROOT/" "$SSH_USER@$HOST:$REMOTE_TMP/"

ssh "$SSH_USER@$HOST" "sudo mkdir -p $APP_DIR && \
  sudo rsync -a --delete \
    --exclude 'backend/venv/' \
    --exclude 'backend/.env' \
    $REMOTE_TMP/ $APP_DIR/ && \
  sudo chown -R $APP_USER:$APP_USER $APP_DIR && \
  sudo systemctl restart capsee-backend && \
  sleep 2 && systemctl is-active capsee-backend"
