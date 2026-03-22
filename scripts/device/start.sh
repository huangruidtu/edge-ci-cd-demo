#!/bin/sh

APP_HOME="$HOME/edge-app"
APP_BIN="$APP_HOME/current/edge-app"
LOG_FILE="$APP_HOME/logs/app.log"
PID_FILE="$APP_HOME/app.pid"

if [ ! -f "$APP_BIN" ]; then
  echo "ERROR: application binary not found: $APP_BIN"
  exit 1
fi

if [ -f "$PID_FILE" ]; then
  PID=$(cat "$PID_FILE")
  if kill -0 "$PID" 2>/dev/null; then
    echo "Application is already running with PID $PID"
    exit 0
  else
    echo "Stale PID file found, removing it"
    rm -f "$PID_FILE"
  fi
fi

nohup "$APP_BIN" >> "$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"

echo "Application started with PID $(cat "$PID_FILE")"
