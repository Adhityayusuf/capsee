#!/usr/bin/env bash
# Provision VM Azure untuk backend Capsee.
# Jalankan dari laptop: ./deploy/provision.sh
set -euo pipefail

RG="${RG:-capsee-rg}"
VM="${VM:-capsee-vm}"
LOCATION="${LOCATION:-indonesiacentral}"
# Seri B lama (B1s/B1ms/B2s) diblokir untuk subscription Azure for Students,
# jadi pakai seri v2. B2als_v2 = 2 vCPU / 4 GB, cukup untuk Pillow + uvicorn.
SIZE="${SIZE:-Standard_B2als_v2}"
FALLBACK_SIZES="${FALLBACK_SIZES:-Standard_B2ats_v2 Standard_B2ts_v2}"
ADMIN_USER="${ADMIN_USER:-$USER}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_ed25519.pub}"
DISK_GB="${DISK_GB:-64}"
IMAGE="${IMAGE:-Ubuntu2404}"
BUDGET_AMOUNT="${BUDGET_AMOUNT:-}"
BUDGET_EMAIL="${BUDGET_EMAIL:-}"

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
die() { printf '\n\033[1;31mERROR: %s\033[0m\n' "$*" >&2; exit 1; }

# Buat VM, coba size utama lalu fallback bila Azure menolak kapasitas.
create_vm() {
  local size out
  for size in $SIZE $FALLBACK_SIZES; do
    log "Mencoba size $size"
    out="$(mktemp)"
    if az vm create \
      --location "$LOCATION" \
      --resource-group "$RG" \
      --name "$VM" \
      --image "$IMAGE" \
      --size "$size" \
      --admin-username "$ADMIN_USER" \
      --ssh-key-values "$SSH_KEY" \
      --public-ip-sku Standard \
      --public-ip-address-allocation Static \
      --os-disk-size-gb "$DISK_GB" \
      --storage-sku StandardSSD_LRS \
      --nsg-rule SSH \
      --output none >"$out" 2>&1; then
      rm -f "$out"
      CREATED_SIZE="$size"
      return 0
    fi

    if grep -qiE 'SkuNotAvailable|Capacity Restrictions' "$out"; then
      echo "Size $size tidak tersedia di $LOCATION, mencoba kandidat berikutnya."
      rm -f "$out"
      continue
    fi

    echo "az vm create gagal:" >&2
    tail -20 "$out" >&2
    rm -f "$out"
    die "Provisioning VM gagal (size $size)."
  done

  die "Tidak ada size yang tersedia di $LOCATION. Coba LOCATION=eastasia atau SIZE=<size lain>."
}

command -v az >/dev/null 2>&1 || die "Azure CLI belum terpasang."
az account show >/dev/null 2>&1 || die "Belum login. Jalankan: az login"
[[ -f "$SSH_KEY" ]] || die "SSH public key tidak ditemukan: $SSH_KEY"

log "Subscription: $(az account show --query name -o tsv)"
log "Resource group: $RG ($LOCATION)"
az group create --name "$RG" --location "$LOCATION" --output none

CREATED_SIZE=""
if az vm show -g "$RG" -n "$VM" >/dev/null 2>&1; then
  log "VM $VM sudah ada, provisioning dilewati"
  CREATED_SIZE="$(az vm show -g "$RG" -n "$VM" --query hardwareProfile.vmSize -o tsv)"
else
  log "Membuat VM $VM (image $IMAGE, lokasi $LOCATION)"
  create_vm

  log "Membuka port 80 dan 443"
  az vm open-port -g "$RG" -n "$VM" --port 80 --priority 1010 --output none
  az vm open-port -g "$RG" -n "$VM" --port 443 --priority 1020 --output none
fi

IP="$(az vm show -d -g "$RG" -n "$VM" --query publicIps -o tsv)"
[[ -n "$IP" ]] || die "Public IP belum tersedia, coba lagi beberapa detik."
DOMAIN="${IP//./-}.sslip.io"

if [[ -n "$BUDGET_AMOUNT" && -n "$BUDGET_EMAIL" ]]; then
  log "Membuat budget alert \$$BUDGET_AMOUNT/bulan"
  SUB_ID="$(az account show --query id -o tsv)"
  START="$(date -u +%Y-%m-01T00:00:00Z)"
  END="$(date -u -d '+1 year' +%Y-%m-01T00:00:00Z)"
  BODY="$(cat <<JSON
{
  "properties": {
    "category": "Cost",
    "amount": $BUDGET_AMOUNT,
    "timeGrain": "Monthly",
    "timePeriod": { "startDate": "$START", "endDate": "$END" },
    "notifications": {
      "actual_80": {
        "enabled": true,
        "operator": "GreaterThan",
        "threshold": 80,
        "thresholdType": "Actual",
        "contactEmails": ["$BUDGET_EMAIL"]
      }
    }
  }
}
JSON
)"
  az rest --method put \
    --url "https://management.azure.com/subscriptions/$SUB_ID/providers/Microsoft.Consumption/budgets/capsee-monthly?api-version=2023-11-01" \
    --body "$BODY" --output none \
    || echo "Peringatan: budget gagal dibuat, atur manual di Portal (Cost Management > Budgets)."
fi

cat <<EOF

Provisioning selesai.

  IP publik : $IP
  Size VM   : ${CREATED_SIZE:-$SIZE}
  Domain    : https://$DOMAIN
  SSH       : ssh $ADMIN_USER@$IP

Langkah berikutnya:

  scp backend/.env $ADMIN_USER@$IP:/tmp/capsee.env
  scp -r deploy $ADMIN_USER@$IP:/tmp/capsee-deploy
  ssh $ADMIN_USER@$IP 'sudo bash /tmp/capsee-deploy/bootstrap.sh $DOMAIN email@kamu.com'

EOF
