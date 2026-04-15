#!/usr/bin/env bash
set -Eeuo pipefail

APP_ROOT="/var/www/next-aws"
RELEASES_DIR="$APP_ROOT/releases"
SHARED_DIR="$APP_ROOT/shared"
SCRIPTS_DIR="$APP_ROOT/scripts"
CURRENT_LINK="$APP_ROOT/current"
LOG_FILE="$APP_ROOT/deploy.log"

: "${RELEASE_ID:?RELEASE_ID is required}"

ARCHIVE_PATH="/tmp/next-aws-${RELEASE_ID}.tar.gz"
NEW_RELEASE_DIR="$RELEASES_DIR/$RELEASE_ID"

exec >> "$LOG_FILE" 2>&1

echo "==== DEPLOY START: $(date) / RELEASE_ID=$RELEASE_ID ===="

mkdir -p "$RELEASES_DIR" "$SHARED_DIR" "$SCRIPTS_DIR"

if [ ! -f "$ARCHIVE_PATH" ]; then
  echo "[error] archive not found: $ARCHIVE_PATH"
  exit 1
fi

echo "[1/6] extract release"
rm -rf "$NEW_RELEASE_DIR"
mkdir -p "$NEW_RELEASE_DIR"
tar -xzf "$ARCHIVE_PATH" -C "$NEW_RELEASE_DIR"

echo "[2/6] link shared env"
if [ -f "$SHARED_DIR/.env" ]; then
  ln -sfn "$SHARED_DIR/.env" "$NEW_RELEASE_DIR/.env"
else
  echo "[warn] $SHARED_DIR/.env not found"
fi

echo "[3/6] switch current symlink"
ln -sfn "$NEW_RELEASE_DIR" "$CURRENT_LINK"

echo "[4/6] load runtime env"
if [ -f "$SHARED_DIR/.env" ]; then
  set -a
  . "$SHARED_DIR/.env"
  set +a
fi

echo "[5/6] restart pm2"
pm2 startOrRestart "$CURRENT_LINK/ecosystem.config.cjs" --update-env
pm2 save

echo "[6/6] cleanup old releases"
find "$RELEASES_DIR" -mindepth 1 -maxdepth 1 -type d | sort | head -n -5 | xargs -r rm -rf
rm -f "$ARCHIVE_PATH"

echo "==== DEPLOY END: $(date) / RELEASE_ID=$RELEASE_ID ===="