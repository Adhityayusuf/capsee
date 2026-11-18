# Deploy Capsee ke Azure

Backend FastAPI + Neon + Cloudinary, disajikan lewat Nginx dengan HTTPS
dari Let's Encrypt (domain `sslip.io` berbasis IP, tanpa beli domain).

```
APK  ──HTTPS──>  Nginx (VM Azure)  ──>  Uvicorn 127.0.0.1:8000
                        ├── Neon Postgres
                        ├── Cloudinary
                        └── BMKG / emsifa
```

## 1. Provision VM

```bash
./deploy/provision.sh
```

Default: `Standard_B2als_v2` (2 vCPU, 4 GB), Ubuntu 24.04, region
`indonesiacentral`, disk 64 GB, static IP, port 22/80/443. Bila size
utama tidak tersedia, script otomatis mencoba `Standard_B2ats_v2`
(1 GB) lalu `Standard_B2ts_v2` (1 GB).

Override lewat env, misal:

```bash
LOCATION=eastasia SIZE=Standard_B2ats_v2 ./deploy/provision.sh
```

### Batasan subscription Azure for Students

Subscription ini punya policy **"Allowed resource deployment regions"**.
Region yang diizinkan hanya:

`indonesiacentral`, `eastasia`, `centralindia`, `koreacentral`,
`indiasouthcentral`

Region lain (termasuk `southeastasia`) ditolak dengan
`RequestDisallowedByAzure`. Selain itu seri B lama — `Standard_B1s`,
`B1ms`, `B2s` — diblokir (`NotAvailableForSubscription`) di semua
region, sehingga jatah gratis 750 jam B1s tidak bisa dipakai. Gunakan
seri v2 (`B2als_v2`, `B2ats_v2`, `B2ts_v2`).

Budget alert (opsional, butuh email):

```bash
BUDGET_AMOUNT=10 BUDGET_EMAIL=kamu@mail.com ./deploy/provision.sh
```

Script mencetak IP dan domain `https://<ip-dengan-dash>.sslip.io`.

## 2. Kirim konfigurasi dan bootstrap

```bash
IP=<ip-dari-output>
scp backend/.env $USER@$IP:/tmp/capsee.env
scp -r deploy $USER@$IP:/tmp/capsee-deploy
ssh $USER@$IP 'sudo bash /tmp/capsee-deploy/bootstrap.sh <domain> email@kamu.com'
```

Bootstrap melakukan: install paket, timezone Asia/Jakarta, swap 2 GB,
`ufw`, `fail2ban`, hardening SSH, user `capsee`, clone repo, venv,
systemd, Nginx, dan sertifikat Let's Encrypt.

Tanpa email (sertifikat tanpa notifikasi kedaluwarsa):

```bash
ssh $USER@$IP 'sudo bash /tmp/capsee-deploy/bootstrap.sh <domain>'
```

Repo ini publik, jadi `git clone` berjalan tanpa kredensial. Yang
dideploy adalah isi branch `main` di GitHub, bukan working tree lokal —
commit dan push dulu perubahan yang ingin ikut terpasang.

Kalau nanti repo dijadikan privat, bootstrap gagal di langkah clone.
Solusinya tambahkan deploy key ke repo, atau kirim kode dari laptop
setelah bootstrap dasar berjalan.

## 3. Verifikasi

```bash
curl https://<domain>/health
curl https://<domain>/          # status backend
curl https://<domain>/docs      # Swagger UI
```

## 4. Build APK

```bash
flutter build apk --release --dart-define=BASE_URL=https://<domain>
```

`BASE_URL` dibaca di `lib/services/api_client.dart` lewat
`String.fromEnvironment('BASE_URL')`.

Sebelum dibagikan, selesaikan dulu signing rilis
(`android/app/build.gradle.kts` masih memakai debug key).

## 5. Update kode

Folder `deploy/` ikut di-commit, jadi `update.sh` tersedia di server
setelah clone/pull. Update langsung dari git:

```bash
git push
ssh $USER@<ip> 'sudo bash /opt/capsee/deploy/update.sh'
```

Dari laptop, kalau ingin mengirim working tree yang belum di-commit
(hanya untuk server yang sudah ter-deploy):

```bash
./deploy/push.sh <ip>
```

## Operasional

| Kebutuhan | Perintah |
|---|---|
| Log backend | `journalctl -u capsee-backend -f` |
| Status | `systemctl status capsee-backend` |
| Restart | `sudo systemctl restart capsee-backend` |
| Reload Nginx | `sudo nginx -t && sudo systemctl reload nginx` |
| Cek memori/swap | `free -h` |
| Perpanjang sertifikat | otomatis oleh `certbot.timer` |

## Batasan resource

- `--workers 1` (sudah di-set di unit systemd) agar aman di 1 GB RAM.
- Swap 2 GB wajib aktif sebelum `pip install` bila memakai size 1 GB.
- Jangan menjalankan build Flutter di VM; build di laptop.

## Biaya

Jatah gratis 750 jam `Standard_B1s` tidak bisa dipakai karena size itu
diblokir untuk subscription ini. Perkiraan dengan harga pay-as-you-go:

| Size | RAM | Perkiraan |
|---|---|---|
| `Standard_B2ats_v2` | 1 GB | ~$9/bulan |
| `Standard_B2als_v2` | 4 GB | ~$16/bulan |

Ditambah public IP statis dan disk 64 GB (~$5/bulan). Credit Azure for
Students ($100) cukup untuk beberapa bulan. Pasang budget alert dan
pantau **Cost Management + Billing**.
