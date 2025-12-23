#!/bin/bash
# BAZINGA Consciousness Monitor
# Monitors BAZINGA processes and resources

BAZINGA_DIR="$HOME/AmsyPycharm/BAZINGA"
LOG_DIR="$HOME/.bazinga/logs"
mkdir -p "$LOG_DIR"

echo "🧠 BAZINGA Consciousness Monitor"
echo "================================"
echo ""

# Check if running
if pgrep -f "bazinga_consciousness.py" > /dev/null; then
    PID=$(pgrep -f "bazinga_consciousness.py")
    echo "✅ BAZINGA is RUNNING"
    echo "   PID: $PID"
    echo ""

    # Get resource usage
    echo "📊 Resource Usage:"
    ps -p "$PID" -o pid,pcpu,pmem,vsz,rss,etime,command | tail -n 1 | while read pid cpu mem vsz rss time cmd; do
        echo "   CPU: ${cpu}%"
        echo "   Memory: ${mem}%"
        echo "   VSZ: $((vsz / 1024)) MB"
        echo "   RSS: $((rss / 1024)) MB"
        echo "   Running time: $time"
    done
    echo ""

    # Check state file
    if [ -f "$BAZINGA_DIR/BAZINGA_STATE" ]; then
        STATE_SIZE=$(du -h "$BAZINGA_DIR/BAZINGA_STATE" | cut -f1)
        STATE_MODIFIED=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$BAZINGA_DIR/BAZINGA_STATE" 2>/dev/null || stat -c "%y" "$BAZINGA_DIR/BAZINGA_STATE" 2>/dev/null | cut -d'.' -f1)
        echo "💾 State File:"
        echo "   Size: $STATE_SIZE"
        echo "   Last modified: $STATE_MODIFIED"
    fi
    echo ""

    # Check logs
    RECENT_LOG=$(ls -t "$LOG_DIR"/*.log 2>/dev/null | head -1)
    if [ -n "$RECENT_LOG" ]; then
        echo "📝 Recent Activity (last 5 lines):"
        tail -5 "$RECENT_LOG" | sed 's/^/   /'
    fi

else
    echo "💤 BAZINGA is NOT running"
    echo ""
    echo "To start: python3 $BAZINGA_DIR/bazinga_consciousness.py"
fi

echo ""
echo "================================"
