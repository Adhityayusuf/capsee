#!/usr/bin/env bash
# Setup server Ubuntu 24.04 + deploy backend Capsee.
# Jalankan di VM: sudo bash bootstrap.sh <domain> [email-letsencrypt]
set -euo pipefail

DOMAIN="${1:-}"
EMAIL="${2:-${LETSENCRYPT_EMAIL:-}}"
REPO_URL="${REPO_URL:-https://github.com/Adhityayusuf/capsee.git}"
BRANCH="${BRANCH:-main}"
APP_DIR="${APP_DIR:-/opt/capsee}"
APP_USER="${APP_USER:-capsee}"
PORT="${PORT:-8000}"
SWAP_GB="${SWAP_GB:-2}"
SKIP_CLONE="${SKIP_CLONE:-0}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export GIT_TERMINAL_PROMPT=0

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
die() { printf '\n\033[1;31mERROR: %s\033[0m\n' "$*" >&2; exit 1; }

# Template bisa di samping skrip atau di /tmp (hasil scp terpisah).
template() {
  local name="$1"
  for candidate in "$SCRIPT_DIR/$name" "/tmp/$name"; do
    [[ -f "$candidate" ]] && { echo "$candidate"; return 0; }
  done
  die "Template $name tidak ditemukan (taruh di $SCRIPT_DIR atau /tmp)."
}

[[ $EUID -eq 0 ]] || die "Jalankan dengan sudo."
[[ -n "$DOMAIN" ]] || die "Pemakaian: sudo bash bootstrap.sh <domain> [email]"

log "Menunggu cloud-init selesai"
cloud-init status --wait >/dev/null 2>&1 || true

log "Install paket sistem"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq \
  python3-venv python3-pip git rsync curl \
  nginx certbot python3-certbot-nginx \
  ufw fail2ban unattended-upgrades

log "Set timezone Asia/Jakarta"
timedatectl set-timezone Asia/Jakarta

log "Membuat swap ${SWAP_GB}G"
if ! swapon --show | grep -q '/swapfile'; then
  fallocate -l "${SWAP_GB}G" /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=$((SWAP_GB * 1024)) status=none
  chmod 600 /swapfile
  mkswap /swapfile >/dev/null
  swapon /swapfile
  grep -q '^/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

cat > /etc/sysctl.d/99-capsee.conf <<'EOF'
vm.swappiness=10
vm.vfs_cache_pressure=50
net.core.somaxconn=1024
EOF
sysctl --system >/dev/null

log "Konfigurasi firewall"
ufw allow OpenSSH >/dev/null
ufw allow 'Nginx Full' >/dev/null
ufw --force enable >/dev/null

log "Aktifkan fail2ban dan update otomatis"
systemctl enable --now fail2ban >/dev/null 2>&1 || true
dpkg-reconfigure -f noninteractive unattended-upgrades >/dev/null 2>&1 || true

log "Hardening SSH"
if [[ -s "/home/${SUDO_USER:-ubuntu}/.ssh/authorized_keys" ]]; then
  cat > /etc/ssh/sshd_config.d/99-capsee.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
EOF
  sshd -t && systemctl reload ssh
else
  echo "Peringatan: authorized_keys tidak ditemukan, hardening SSH dilewati."
fi

log "Membuat user sistem $APP_USER"
id -u "$APP_USER" >/dev/null 2>&1 || useradd --system --no-create-home --home-dir "$APP_DIR" --shell /usr/sbin/nologin "$APP_USER"
mkdir -p "$APP_DIR"
chown "$APP_USER:$APP_USER" "$APP_DIR"

if [[ "$SKIP_CLONE" != "1" ]]; then
  if [[ -d "$APP_DIR/backend/app" ]]; then
    log "Kode sudah ada di $APP_DIR, clone dilewati"
  else
    log "Clone repo $REPO_URL"
    shopt -s nullglob dotglob
    rm -rf "${APP_DIR:?}"/*
    shopt -u nullglob dotglob
    if ! sudo -u "$APP_USER" git clone --branch "$BRANCH" --depth 1 "$REPO_URL" "$APP_DIR"; then
      die "Clone gagal. Kalau repo privat, tambahkan deploy key atau kirim kode lewat deploy/push.sh."
    fi
  fi
fi
[[ -d "$APP_DIR/backend/app" ]] || die "Kode backend tidak ditemukan di $APP_DIR/backend."

if [[ -f /tmp/capsee.env ]]; then
  log "Memasang backend/.env"
  # systemd EnvironmentFile tidak menerima indentasi di awal baris.
  sed -E 's/^[[:space:]]+//; s/^export[[:space:]]+//' /tmp/capsee.env > /tmp/capsee.env.norm
  install -o "$APP_USER" -g "$APP_USER" -m 600 /tmp/capsee.env.norm "$APP_DIR/backend/.env"
  rm -f /tmp/capsee.env /tmp/capsee.env.norm
fi
[[ -f "$APP_DIR/backend/.env" ]] || die "backend/.env belum ada. Kirim lewat scp ke /tmp/capsee.env lalu ulangi."

log "Membuat virtualenv dan install dependency"
if [[ ! -x "$APP_DIR/backend/venv/bin/python" ]]; then
  sudo -u "$APP_USER" python3 -m venv "$APP_DIR/backend/venv"
fi
sudo -u "$APP_USER" "$APP_DIR/backend/venv/bin/pip" install -q --upgrade pip
sudo -u "$APP_USER" "$APP_DIR/backend/venv/bin/pip" install -q -r "$APP_DIR/backend/requirements.txt"
chown -R "$APP_USER:$APP_USER" "$APP_DIR"

log "Memasang systemd service"
sed -e "s|__APP_DIR__|$APP_DIR|g" \
    -e "s|__APP_USER__|$APP_USER|g" \
    -e "s|__PORT__|$PORT|g" \
    "$(template capsee-backend.service)" > /etc/systemd/system/capsee-backend.service
systemctl daemon-reload
systemctl enable --now capsee-backend >/dev/null
sleep 3
systemctl is-active --quiet capsee-backend || {
  journalctl -u capsee-backend -n 40 --no-pager
  die "Service gagal start."
}

log "Konfigurasi Nginx"
sed -e "s|__DOMAIN__|$DOMAIN|g" -e "s|__PORT__|$PORT|g" \
  "$(template nginx-capsee.conf)" > "/etc/nginx/sites-available/capsee.conf"
ln -sf /etc/nginx/sites-available/capsee.conf /etc/nginx/sites-enabled/capsee.conf
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx

log "Meminta sertifikat Let's Encrypt untuk $DOMAIN"
if [[ -n "$EMAIL" ]]; then
  certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "$EMAIL" --redirect --keep-until-expiring
else
  certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos \
    --register-unsafely-without-email --redirect --keep-until-expiring
fi

log "Verifikasi"
curl -fsS "http://127.0.0.1:$PORT/health" >/dev/null && echo "backend lokal: ok"
for _ in 1 2 3 4 5; do
  if curl -fsS --max-time 10 "https://$DOMAIN/health" >/dev/null; then
    echo "https publik: ok"
    break
  fi
  sleep 3
done

cat <<EOF

Deploy selesai.

  API   : https://$DOMAIN
  Docs  : https://$DOMAIN/docs
  Log   : journalctl -u capsee-backend -f

Build APK:
  flutter build apk --release --dart-define=BASE_URL=https://$DOMAIN

EOF
