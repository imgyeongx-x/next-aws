#!/usr/bin/env bash
set -Eeuo pipefail

APP_DIR="/var/www/next-aws"
NVM_DIR="$HOME/.nvm"
LOG_FILE="/var/www/next-aws/deploy.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "==== DEPLOY START: $(date) ===="

export NVM_DIR
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

cd "$APP_DIR"

echo "[1/5] node/npm version"
node -v
npm -v

echo "[2/5] npm ci"
npm ci

echo "[3/5] next build"
npm run build

echo "[4/5] restart pm2"
if pm2 describe next-aws >/dev/null 2>&1; then
  pm2 restart next-aws
else
  pm2 start npm --name "next-aws" -- start
fi

echo "[5/5] save pm2"
pm2 save

echo "==== DEPLOY END: $(date) ===="