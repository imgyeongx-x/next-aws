#!/usr/bin/env bash
set -Eeuo pipefail

APP_DIR="/var/www/next-aws"
NVM_DIR="$HOME/.nvm"

echo "[1/6] load nvm"
export NVM_DIR
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

echo "[2/6] move to app dir"
cd "$APP_DIR"

echo "[3/6] versions"
node -v
npm -v

echo "[4/6] npm ci"
npm ci

echo "[5/6] build"
npm run build

echo "[6/6] restart pm2"
if pm2 describe next-aws >/dev/null 2>&1; then
  pm2 restart next-aws
else
  pm2 start npm --name "next-aws" -- start
fi

pm2 save
echo "[done] deploy finished"