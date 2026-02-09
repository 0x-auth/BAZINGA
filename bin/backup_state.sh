#!/bin/bash
# BAZINGA State Backup Script
# Creates timestamped backups of BAZINGA state

set -e

BAZINGA_DIR="$HOME/AmsyPycharm/BAZINGA"
BACKUP_DIR="$HOME/.bazinga/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

echo "📦 BAZINGA State Backup"
echo "======================="

# Backup BAZINGA_STATE
if [ -f "$BAZINGA_DIR/BAZINGA_STATE" ]; then
    cp "$BAZINGA_DIR/BAZINGA_STATE" "$BACKUP_DIR/BAZINGA_STATE_$TIMESTAMP"
    echo "✅ State backed up: BAZINGA_STATE_$TIMESTAMP"

    # Get size
    SIZE=$(du -h "$BACKUP_DIR/BAZINGA_STATE_$TIMESTAMP" | cut -f1)
    echo "   Size: $SIZE"
else
    echo "⚠️  No BAZINGA_STATE file found"
fi

# Backup configuration if exists
if [ -f "$HOME/.bazinga/config.json" ]; then
    cp "$HOME/.bazinga/config.json" "$BACKUP_DIR/config_$TIMESTAMP.json"
    echo "✅ Config backed up: config_$TIMESTAMP.json"
fi

# Keep only last 10 backups
cd "$BACKUP_DIR"
ls -t BAZINGA_STATE_* 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true

echo ""
echo "Backup location: $BACKUP_DIR"
echo "Total backups: $(ls -1 BAZINGA_STATE_* 2>/dev/null | wc -l)"
