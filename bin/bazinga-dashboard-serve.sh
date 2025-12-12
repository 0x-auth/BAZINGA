#!/bin/bash
# Server script for BAZINGA Dashboard
# Usage: /Users/abhissrivasta/AmsyPycharm/BAZINGA/bin/bazinga-dashboard-serve.sh [port]

PORT="${1:-8080}"
DASHBOARD_DIR="/Users/abhissrivasta/AmsyPycharm/BAZINGA/dashboard"

# Check if Python is available
if command -v python3 &>/dev/null; then
  echo "Starting server on http://localhost:${PORT}"
  echo "Press Ctrl+C to stop"
  cd "${DASHBOARD_DIR}" && python3 -m http.server "${PORT}"
elif command -v python &>/dev/null; then
  echo "Starting server on http://localhost:${PORT}"
  echo "Press Ctrl+C to stop"
  cd "${DASHBOARD_DIR}" && python -m SimpleHTTPServer "${PORT}"
else
  echo "Python not found, cannot start server"
  exit 1
fi
