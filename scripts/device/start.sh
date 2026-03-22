#!/bin/bash

APP_DIR="/opt/app"
APP_NAME="app.sh"
LOG_DIR="$APP_DIR/logs"

cd "$APP_DIR"

echo "[INFO] Starting application..."

mkdir -p "$LOG_DIR"

nohup "./$APP_NAME" >> "$LOG_DIR/app.log" 2>&1 &
