#!/usr/bin/env bash
# Run on the Azure Ubuntu/Debian VM:  sudo bash deploy/deploy.sh   (from the folder that contains site/, server/, deploy/)
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Please run with sudo"; exit 1; }
HERE="$(cd "$(dirname "$0")/.." && pwd)"
WEB=/var/www/digimarketing; APP=/opt/digimarketing; ENVF=/etc/digimarketing.env

echo "==> Installing nginx and curl"
apt-get update -y && apt-get install -y nginx curl ca-certificates

echo "==> Checking Node.js (needs 18+)"
need=1
if command -v node >/dev/null 2>&1; then [ "$(node -p 'process.versions.node.split(".")[0]')" -ge 18 ] && need=0; fi
if [ "$need" = 1 ]; then curl -fsSL https://deb.nodesource.com/setup_20.x | bash - ; apt-get install -y nodejs; fi

echo "==> Copying website to $WEB"
mkdir -p "$WEB"; rm -rf "${WEB:?}"/*
cp -r "$HERE/site/." "$WEB/"
chown -R www-data:www-data "$WEB"
find "$WEB" -type d -exec chmod 755 {} \; ; find "$WEB" -type f -exec chmod 644 {} \;

echo "==> Installing chatbot API"
mkdir -p "$APP"; cp "$HERE/server/server.js" "$APP/server.js"
if [ ! -f "$ENVF" ]; then
  echo
  echo "The AI chatbot needs an Anthropic API key (create one at https://console.anthropic.com)."
  echo "Press Enter to skip. AI replies will remain unavailable until an API key is configured."
  KEY=""; read -r -s -p "Anthropic API key: " KEY < /dev/tty || true; echo
  printf 'ANTHROPIC_API_KEY=%s\nCHAT_MODEL=claude-haiku-5-5\n' "$KEY" > "$ENVF"
  chmod 600 "$ENVF"
fi
sed "s|/usr/bin/node|$(command -v node)|" "$HERE/deploy/digimarketing-chat.service" > /etc/systemd/system/digimarketing-chat.service
systemctl daemon-reload; systemctl enable digimarketing-chat; systemctl restart digimarketing-chat

echo "==> Configuring nginx"
cp "$HERE/deploy/nginx-dms.conf" /etc/nginx/sites-available/digimarketing
ln -sf /etc/nginx/sites-available/digimarketing /etc/nginx/sites-enabled/digimarketing
rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/lumio
nginx -t
systemctl enable nginx; systemctl restart nginx
if command -v ufw >/dev/null 2>&1; then ufw allow 'Nginx Full' || true; ufw allow OpenSSH || true; fi

sleep 1; echo "==> API status: $(curl -s -m 5 http://127.0.0.1/api/health || echo 'not reachable')"
IP=$(curl -s -m 3 -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2021-02-01&format=text" || true)
echo "==> Done. Open http://${IP:-<your-VM-public-IP>}/"
echo "    Allow inbound port 80 in the Azure Network Security Group."
echo "    Enquiry backup file: /var/lib/digimarketing/enquiries.jsonl"
