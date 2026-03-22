#!/bin/bash

set -e

APP_DIR="/opt/app"
APP_NAME="app.sh"
LOG_DIR="$APP_DIR/logs"

echo "===== Starting deployment ====="

cd "$APP_DIR"

echo "[INFO] Preparing application..."

# TODO: replace with real download
# wget http://xxx/app.sh -O "$APP_NAME"

chmod +x "$APP_NAME"

echo "[INFO] Stopping existing application..."

pkill -f "$APP_NAME" || true

sleep 1

echo "[INFO] Starting application..."

./start.sh

echo "[SUCCESS] Deployment completed successfully."
