#!/usr/bin/env bash
# Run on the Azure Ubuntu/Debian VM:  sudo bash deploy/deploy.sh   (from the folder containing site/ and deploy/)
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
WEB=/var/www/digimarketing
echo "==> Installing nginx"
apt-get update -y && apt-get install -y nginx
echo "==> Copying website to $WEB"
mkdir -p "$WEB"; rm -rf "${WEB:?}"/*
cp -r "$HERE/site/." "$WEB/"
chown -R www-data:www-data "$WEB"
find "$WEB" -type d -exec chmod 755 {} \; ; find "$WEB" -type f -exec chmod 644 {} \;
echo "==> Configuring nginx"
cp "$HERE/deploy/nginx-dms.conf" /etc/nginx/sites-available/digimarketing
ln -sf /etc/nginx/sites-available/digimarketing /etc/nginx/sites-enabled/digimarketing
rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/lumio
nginx -t
systemctl enable nginx; systemctl restart nginx
if command -v ufw >/dev/null 2>&1; then ufw allow 'Nginx Full' || true; ufw allow OpenSSH || true; fi
IP=$(curl -s -m 3 -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2021-02-01&format=text" || true)
echo "==> Done. Open http://${IP:-<your-VM-public-IP>}/"
echo "    Allow inbound port 80 in the Azure Network Security Group."
