#!/bin/sh

APP_HOME="$HOME/edge-app"
PID_FILE="$APP_HOME/app.pid"

if [ ! -f "$PID_FILE" ]; then
  echo "Application is not running (no PID file found)"
  exit 0
fi

PID=$(cat "$PID_FILE")

if kill -0 "$PID" 2>/dev/null; then
  kill "$PID"
  sleep 1
  if kill -0 "$PID" 2>/dev/null; then
    echo "Process did not stop gracefully, forcing termination"
    kill -9 "$PID"
  fi
  echo "Application stopped"
else
  echo "Process not running, removing stale PID file"
fi

rm -f "$PID_FILE"
