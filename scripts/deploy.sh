#!/usr/bin/env bash
set -Eeuo pipefail

APP_DIR="/var/www/next-aws"
NVM_DIR="$HOME/.nvm"

export NVM_DIR
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

cd "$APP_DIR"

npm ci
npm run build

if pm2 describe next-aws >/dev/null 2>&1; then
  pm2 restart next-aws
else
  pm2 start npm --name "next-aws" -- start
fi

pm2 save