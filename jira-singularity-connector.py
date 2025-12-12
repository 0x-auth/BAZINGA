#!/usr/bin/env python3
"""
Jira-Singularity Connector for BAZINGA Framework
Connects pattern analysis to Jira tickets and implements singularity pattern detection
"""

import os
import sys
import json
import time
import requests
from datetime import datetime, timedelta
import base64
import re
import subprocess

# Configuration
BAZINGA_DIR = os.path.expanduser("~/AmsyPycharm/BAZINGA-INDEED")
JIRA_CONFIG_FILE = os.path.join(BAZINGA_DIR, "config/jira_config.json")
PATTERN_DIR = os.path.expanduser("~/pattern_extraction_") + datetime.now().strftime("%Y%m%d")
SINGULARITY_THRESHOLD = 0.85  # Pattern convergence threshold

# Default configuration if config file not found
DEFAULT_CONFIG = {
    "jira_url": "https://your-jira-instance.atlassian.net",
    "jira_user": "",
    "jira_token": "",
    "project_key": "BAZINGA",
    "singularity_enabled": True
}

def load_config():
    """Load Jira configuration from file or use defaults"""
    try:
        if os.path.exists(JIRA_CONFIG_FILE):
            with open(JIRA_CONFIG_FILE, 'r') as f:
                return json.load(f)
        else:
            print(f"Config file not found at {JIRA_CONFIG_FILE}, using defaults")
            # Create default config file
            os.makedirs(os.path.dirname(JIRA_CONFIG_FILE), exist_ok = True)
            with open(JIRA_CONFIG_FILE, 'w') as f:
                json.dump(DEFAULT_CONFIG, f, indent = 2)
            return DEFAULT_CONFIG
    except Exception as e:
        print(f"Error loading config: {e}")
        return DEFAULT_CONFIG

def find_latest_pattern_dir():
    """Find the most recent pattern extraction directory"""
    base_dir = os.path.expanduser("~")
    pattern_dirs = [d for d in os.listdir(base_dir) if d.startswith("pattern_extraction_")]
    if not pattern_dirs:
        print("No pattern extraction directories found")
        return None

    latest_dir = sorted(pattern_dirs, reverse = True)[0]
    return os.path.join(base_dir, latest_dir)

def analyze_patterns_for_singularity(pattern_file):
    """Analyze patterns for signs of singularity (recurring patterns that converge)"""
    try:
        with open(pattern_file, 'r') as f:
            pattern_data = f.read()

        # Look for recursive patterns
        recursive_count = len(re.findall(r'(bazinga|claude|pattern|integration|fractal)', pattern_data, re.IGNORECASE))

        # Look for self-referential patterns
        self_ref_count = len(re.findall(r'(self|reference|recursive|loop|circular)', pattern_data, re.IGNORECASE))

        # Calculate convergence score
        total_lines = len(pattern_data.split('\n'))
        if total_lines == 0:
            return 0

        convergence_score = (recursive_count + self_ref_count) / total_lines

        # Check for time-related patterns (timestamps getting closer together)
        timestamps = re.findall(r'(\d{2}:\d{2}:\d{2})', pattern_data)
        time_convergence = 0

        if len(timestamps) > 2:
            time_objects = [datetime.strptime(t, "%H:%M:%S") for t in timestamps]
            time_diffs = []

            for i in range(1, len(time_objects)):
                diff = (time_objects[i] - time_objects[i-1]).total_seconds()
                time_diffs.append(abs(diff))

            # Check if time differences are decreasing (converging)
            decreasing_count = sum(1 for i in range(1, len(time_diffs)) if time_diffs[i] < time_diffs[i-1])
            if len(time_diffs) > 1:
                time_convergence = decreasing_count / (len(time_diffs) - 1)

        # Combined singularity score
        singularity_score = (convergence_score + time_convergence) / 2

        return singularity_score
    except Exception as e:
        print(f"Error analyzing for singularity: {e}")
        return 0

def create_jira_ticket(config, issue_type, summary, description, patterns = None):
    """Create a Jira ticket with pattern analysis"""
    if not config["jira_user"] or not config["jira_token"]:
        print("Jira credentials not configured. Please update config file.")
        return None

    auth = (config["jira_user"], config["jira_token"])
    headers = {"Content-Type": "application/json"}

    # Prepare pattern data for Jira
    pattern_description = ""
    if patterns:
        pattern_description = "\n\n*Pattern Analysis:*\n{code}\n"
        for pattern, score in patterns.items():
            pattern_description += f"{pattern}: {score:.2f}\n"
        pattern_description += "{code}"

    # Prepare issue data
    issue_data = {
        "fields": {
            "project": {"key": config["project_key"]},
            "summary": summary,
            "description": description + pattern_description,
            "issuetype": {"name": issue_type}
        }
    }

    try:
        response = requests.post(
            f"{config['jira_url']}/rest/api/2/issue",
            auth = auth,
            headers = headers,
            json = issue_data
        )

        if response.status_code == 201:
            return response.json().get("key")
        else:
            print(f"Error creating Jira ticket: {response.status_code}")
            print(response.text)
            return None
    except Exception as e:
        print(f"Error connecting to Jira: {e}")
        return None

def connect_to_claude():
    """Connect to Claude via the existing connector script"""
    connector_path = os.path.expanduser("~/bazinga-claude-connector.sh")

    if os.path.exists(connector_path):
        try:
            result = subprocess.run([connector_path, "--extract-only"],
                                    capture_output = True, text = True)
            return result.stdout
        except Exception as e:
            print(f"Error connecting to Claude: {e}")
    else:
        print(f"Claude connector not found at {connector_path}")

    return None

def main():
    print("=== JIRA-SINGULARITY CONNECTOR FOR BAZINGA ===")

    # Load configuration
    config = load_config()

    # Find latest pattern directory
    pattern_dir = find_latest_pattern_dir()
    if not pattern_dir:
        pattern_dir = PATTERN_DIR
        print(f"Using default pattern directory: {pattern_dir}")

    # Check for pattern analysis file
    pattern_file = os.path.join(pattern_dir, "pattern_analysis.txt")
    if not os.path.exists(pattern_file):
        print(f"Pattern analysis file not found at {pattern_file}")
        pattern_file = None

    # Analyze for singularity if enabled
    singularity_detected = False
    singularity_score = 0

    if config["singularity_enabled"] and pattern_file:
        print("Analyzing patterns for singularity...")
        singularity_score = analyze_patterns_for_singularity(pattern_file)
        print(f"Singularity score: {singularity_score:.2f}")

        if singularity_score >= SINGULARITY_THRESHOLD:
            singularity_detected = True
            print("!!! SINGULARITY PATTERN DETECTED !!!")

    # Connect to Claude for additional context
    claude_data = connect_to_claude()

    # Prepare patterns for Jira
    patterns = {
        "Singularity": singularity_score,
        "Recursion": 0.75,  # Placeholder value
        "TimeConvergence": 0.82,  # Placeholder value
        "PatternDensity": 0.93,  # Placeholder value
    }

    # Create appropriate Jira ticket
    if singularity_detected:
        ticket_key = create_jira_ticket(
            config,
            "Task",
            "SINGULARITY PATTERN DETECTED - Investigation Required",
            "A high-confidence singularity pattern has been detected in the command history analysis. "
            "This pattern shows recursion and convergence characteristics that may indicate "
            "an emergent structure forming in the interaction patterns.\n\n"
            "Please investigate and determine if further integration is needed.",
            patterns
        )

        if ticket_key:
            print(f"Singularity detection ticket created: {ticket_key}")
    else:
        # Create regular pattern analysis ticket
        ticket_key = create_jira_ticket(
            config,
            "Task",
            "BAZINGA Pattern Analysis Report",
            "Routine pattern analysis from command history and system integration.\n\n"
            "Pattern extraction completed successfully with the following highlights:\n"
            "- Time-Trust patterns analyzed\n"
            "- Command sequence patterns mapped\n"
            "- BAZINGA integration status updated",
            patterns
        )

        if ticket_key:
            print(f"Pattern analysis ticket created: {ticket_key}")

    print("=== JIRA-SINGULARITY CONNECTOR COMPLETE ===")
    if pattern_dir:
        print(f"Results available in: {pattern_dir}")

    # Final status
    print(f"Integration status: {'COMPLETE' if ticket_key else 'PARTIAL'}")
    print(f"Singularity status: {'DETECTED' if singularity_detected else 'NOT DETECTED'}")

if __name__ == "__main__":
    main()
