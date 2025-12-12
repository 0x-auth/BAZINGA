#!/bin/bash
# Auto-start script for BAZINGA Dashboard
# Add to crontab with: crontab -e
# */30 * * * * /Users/abhissrivasta/AmsyPycharm/BAZINGA/bin/bazinga-dashboard-auto.sh > /dev/null 2>&1

# Run the dashboard script
/Users/abhissrivasta/AmsyPycharm/BAZINGA/bin/bazinga-dashboard.sh auto
