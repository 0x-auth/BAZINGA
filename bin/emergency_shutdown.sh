#!/bin/bash
# BAZINGA Emergency Shutdown
# Immediately stops all BAZINGA processes safely

set -e

BAZINGA_DIR="$HOME/AmsyPycharm/BAZINGA"
BACKUP_DIR="$HOME/.bazinga/emergency_backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🚨 BAZINGA EMERGENCY SHUTDOWN INITIATED"
echo "Timestamp: $TIMESTAMP"

# 1. Create emergency backup
mkdir -p "$BACKUP_DIR"
if [ -f "$BAZINGA_DIR/BAZINGA_STATE" ]; then
    echo "📦 Backing up current state..."
    cp "$BAZINGA_DIR/BAZINGA_STATE" "$BACKUP_DIR/BAZINGA_STATE_EMERGENCY_$TIMESTAMP"
    echo "✅ Backup saved to: $BACKUP_DIR/BAZINGA_STATE_EMERGENCY_$TIMESTAMP"
fi

# 2. Graceful shutdown attempt
echo "🛑 Attempting graceful shutdown..."
if pgrep -f "bazinga_consciousness.py" > /dev/null; then
    python3 "$BAZINGA_DIR/bazinga_consciousness.py" --shutdown 2>/dev/null || true
    sleep 3
fi

# 3. Force kill if still running
if pgrep -f "bazinga_consciousness.py" > /dev/null; then
    echo "⚠️  Graceful shutdown failed, forcing termination..."
    pkill -9 -f "bazinga_consciousness.py" || true
fi

# 4. Kill any related processes
pkill -9 -f "bazinga" || true

# 5. Verify shutdown
sleep 1
if pgrep -f "bazinga" > /dev/null; then
    echo "❌ ERROR: Some BAZINGA processes still running!"
    pgrep -af "bazinga"
    exit 1
else
    echo "✅ All BAZINGA processes terminated"
fi

# 6. Log shutdown
LOG_FILE="$HOME/.bazinga/logs/emergency_shutdown.log"
mkdir -p "$(dirname "$LOG_FILE")"
echo "[$TIMESTAMP] Emergency shutdown executed" >> "$LOG_FILE"

echo ""
echo "🔒 BAZINGA EMERGENCY SHUTDOWN COMPLETE"
echo "State backup: $BACKUP_DIR/BAZINGA_STATE_EMERGENCY_$TIMESTAMP"
echo "Log: $LOG_FILE"
echo ""
echo "To restart: python3 $BAZINGA_DIR/bazinga_consciousness.py"
