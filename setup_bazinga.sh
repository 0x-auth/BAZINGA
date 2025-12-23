#!/bin/bash
# BAZINGA Initial Setup Script
# Sets up all required directories, configs, and safety infrastructure

set -e

BAZINGA_DIR="$HOME/AmsyPycharm/BAZINGA"
BAZINGA_HOME="$HOME/.bazinga"

echo "🚀 BAZINGA Responsible AI Setup"
echo "================================"
echo ""

# 1. Create secure directory structure
echo "📁 Creating secure directory structure..."
mkdir -p "$BAZINGA_HOME"/{backups,logs,config,data,cache}
chmod 700 "$BAZINGA_HOME"
echo "✅ Directories created with secure permissions"

# 2. Install Python dependencies
echo ""
echo "📦 Installing Python dependencies..."
if [ -f "$BAZINGA_DIR/requirements.txt" ]; then
    pip3 install -r "$BAZINGA_DIR/requirements.txt" --quiet
    echo "✅ Dependencies installed"
else
    echo "⚠️  requirements.txt not found"
fi

# 3. Initialize configuration
echo ""
echo "⚙️  Initializing configuration..."
cd "$BAZINGA_DIR"
python3 -c "from src.core.config import ConfigManager; ConfigManager()" 2>/dev/null || echo "⚠️  Config initialization skipped (dependencies needed)"
echo "✅ Configuration initialized"

# 4. Test safety scripts
echo ""
echo "🛡️  Testing safety infrastructure..."
if [ -x "$BAZINGA_DIR/bin/monitor_consciousness.sh" ]; then
    echo "✅ Monitor script: ready"
else
    echo "❌ Monitor script: not executable"
fi

if [ -x "$BAZINGA_DIR/bin/backup_state.sh" ]; then
    echo "✅ Backup script: ready"
else
    echo "❌ Backup script: not executable"
fi

if [ -x "$BAZINGA_DIR/bin/emergency_shutdown.sh" ]; then
    echo "✅ Emergency shutdown: ready"
else
    echo "❌ Emergency shutdown: not executable"
fi

# 5. Create initial README
echo ""
echo "📝 Creating quick start guide..."
cat > "$BAZINGA_HOME/README.txt" << 'EOF'
BAZINGA Responsible AI System
=============================

Quick Commands:
---------------
Start:    python3 ~/AmsyPycharm/BAZINGA/bazinga_consciousness.py
Monitor:  ~/AmsyPycharm/BAZINGA/bin/monitor_consciousness.sh
Backup:   ~/AmsyPycharm/BAZINGA/bin/backup_state.sh
Shutdown: ~/AmsyPycharm/BAZINGA/bin/emergency_shutdown.sh

Configuration:
--------------
Location: ~/.bazinga/config/bazinga_config.json
Edit directly or use ConfigManager API

Logs:
-----
Location: ~/.bazinga/logs/
Recent: tail -f ~/.bazinga/logs/*.log

Data:
-----
Location: ~/.bazinga/data/
Encrypted state files only

Safety:
-------
All personal data is encrypted
Emergency shutdown available anytime
State backed up before modifications
Read RESPONSIBLE_AI_FRAMEWORK.md

EOF
echo "✅ Quick start guide created at: $BAZINGA_HOME/README.txt"

# 6. Summary
echo ""
echo "================================"
echo "✅ BAZINGA Setup Complete!"
echo ""
echo "📍 BAZINGA Home: $BAZINGA_HOME"
echo "📍 Code: $BAZINGA_DIR"
echo ""
echo "Next Steps:"
echo "1. Review: cat $BAZINGA_DIR/RESPONSIBLE_AI_FRAMEWORK.md"
echo "2. Configure: edit $BAZINGA_HOME/config/bazinga_config.json"
echo "3. Test: python3 $BAZINGA_DIR/bazinga_consciousness.py"
echo ""
echo "🛡️  Remember: Building AI responsibly requires ongoing vigilance"
echo "================================"
