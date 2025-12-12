#!/usr/bin/env python3
"""
Mac Bogus App Finder

This script helps identify potentially unwanted or suspicious applications
on your Mac by checking common locations and comparing against known patterns.

Usage:
- Run with: python3 mac-bogus-app-finder.py
"""

import os
import subprocess
import json
import re
import time
from datetime import datetime

class BogusAppFinder:
    def __init__(self):
        self.suspicious_apps = []
        self.suspicious_patterns = [
            r'(?i)adware',
            r'(?i)malware',
            r'(?i)clean.*mac',
            r'(?i)optimizer',
            r'(?i)speedup',
            r'(?i)boost.*mac',
            r'(?i)mac.*keeper',
            r'(?i)system.*optimizer',
            r'(?i)advanced.*mac.*cleaner',
            r'(?i)mac.*cleanup',
            r'(?i)mac.*doctor',
            r'(?i)mac.*boost',
            r'(?i)flash.*player.*update',
            r'(?i)mac.*protector',
            r'(?i)mac.*defender',
            r'(?i)cleanmy'
        ]
        self.common_bogus_apps = [
            "MacKeeper",
            "Advanced Mac Cleaner",
            "Mac Defender",
            "MacBooster",
            "CleanMyMac" # Note: Legitimate but sometimes unnecessary
        ]
        self.system_app_locations = [
            "/Applications",
            os.path.expanduser("~/Applications"),
            "/Library/Application Support",
            os.path.expanduser("~/Library/Application Support")
        ]
        self.extensions_locations = [
            os.path.expanduser("~/Library/Safari/Extensions"),
            os.path.expanduser("~/Library/Application Support/Google/Chrome/Default/Extensions"),
            os.path.expanduser("~/Library/Application Support/Firefox/Profiles")
        ]
        self.launch_agents_locations = [
            "/Library/LaunchAgents",
            os.path.expanduser("~/Library/LaunchAgents"),
            "/Library/LaunchDaemons"
        ]

    def check_app_signature(self, app_path):
        """Check if an app is properly signed by Apple or verified developer"""
        try:
            result = subprocess.run(
                ["codesign", "-dv", "--verbose = 2", app_path],
                capture_output = True,
                text = True,
                check = False
            )

            # Check for signature issues
            if "code object is not signed at all" in result.stderr:
                return "Not signed", "High"
            elif "failed to satisfy" in result.stderr:
                return "Signature problem", "High"
            elif "Apple Development" in result.stderr:
                return "Development signature", "Medium"
            elif "Apple Distribution" in result.stderr or "Developer ID Application" in result.stderr:
                return "Valid developer signature", "Low"
            elif "Apple Root CA" in result.stderr:
                return "Apple signed", "Low"
            else:
                return "Unknown signature", "Medium"
        except Exception as e:
            return f"Error checking signature: {str(e)}", "Medium"

    def get_app_info(self, app_path):
        """Get basic info about an application"""
        try:
            # Get creation and modification times
            stat_info = os.stat(app_path)
            created = datetime.fromtimestamp(stat_info.st_ctime).strftime('%Y-%m-%d %H:%M:%S')
            modified = datetime.fromtimestamp(stat_info.st_mtime).strftime('%Y-%m-%d %H:%M:%S')

            # Get app name
            app_name = os.path.basename(app_path)
            if app_name.endswith('.app'):
                app_name = app_name[:-4]

            # Get app version
            version = "Unknown"
            try:
                plist_path = os.path.join(app_path, "Contents", "Info.plist")
                if os.path.exists(plist_path):
                    result = subprocess.run(
                        ["defaults", "read", plist_path, "CFBundleShortVersionString"],
                        capture_output = True,
                        text = True,
                        check = False
                    )
                    if result.stdout.strip():
                        version = result.stdout.strip()
            except:
                pass

            # Check app signature
            signature_status, risk_level = self.check_app_signature(app_path)

            return {
                "name": app_name,
                "path": app_path,
                "version": version,
                "created": created,
                "modified": modified,
                "signature": signature_status,
                "risk_level": risk_level
            }
        except Exception as e:
            return {
                "name": os.path.basename(app_path),
                "path": app_path,
                "error": str(e),
                "risk_level": "Unknown"
            }

    def is_suspicious_name(self, app_name):
        """Check if app name matches suspicious patterns"""
        # Check against common bogus app names
        if any(bogus_app.lower() in app_name.lower() for bogus_app in self.common_bogus_apps):
            return True

        # Check against suspicious patterns
        return any(re.search(pattern, app_name) for pattern in self.suspicious_patterns)

    def get_apps_from_location(self, location):
        """Get all applications from a specific location"""
        apps = []
        if not os.path.exists(location):
            return apps

        try:
            items = os.listdir(location)
            for item in items:
                full_path = os.path.join(location, item)
                if item.endswith('.app') and os.path.isdir(full_path):
                    apps.append(full_path)
        except Exception as e:
            print(f"Error accessing {location}: {str(e)}")

        return apps

    def check_recently_installed_apps(self, days = 30):
        """Find applications installed in the last 30 days"""
        recent_apps = []
        now = time.time()
        thirty_days_ago = now - (days * 24 * 60 * 60)

        for location in self.system_app_locations:
            if not os.path.exists(location):
                continue

            try:
                for item in os.listdir(location):
                    if item.endswith('.app'):
                        app_path = os.path.join(location, item)
                        if os.path.isdir(app_path):
                            created_time = os.stat(app_path).st_ctime
                            if created_time > thirty_days_ago:
                                app_info = self.get_app_info(app_path)
                                app_info["reason"] = f"Recently installed (within {days} days)"
                                recent_apps.append(app_info)
            except Exception as e:
                print(f"Error checking recent apps in {location}: {str(e)}")

        return recent_apps

    def check_launch_agents(self):
        """Check for suspicious launch agents and daemons"""
        suspicious_agents = []

        for location in self.launch_agents_locations:
            if not os.path.exists(location):
                continue

            try:
                for item in os.listdir(location):
                    if item.endswith('.plist'):
                        agent_path = os.path.join(location, item)
                        # Check if name matches suspicious patterns
                        if any(re.search(pattern, item) for pattern in self.suspicious_patterns):
                            suspicious_agents.append({
                                "name": item,
                                "path": agent_path,
                                "type": "Launch Agent/Daemon",
                                "reason": "Suspicious name pattern",
                                "risk_level": "Medium"
                            })
            except Exception as e:
                print(f"Error checking launch agents in {location}: {str(e)}")

        return suspicious_agents

    def scan_system(self):
        """Main method to scan the system for suspicious apps"""
        print("Starting scan for suspicious applications...")
        results = []

        # Scan all application directories
        print("Scanning application directories...")
        for location in self.system_app_locations:
            apps = self.get_apps_from_location(location)
            for app_path in apps:
                app_name = os.path.basename(app_path)
                if self.is_suspicious_name(app_name):
                    app_info = self.get_app_info(app_path)
                    app_info["reason"] = "Suspicious name pattern"
                    results.append(app_info)

        # Check for recently installed apps
        print("Checking recently installed applications...")
        recent_apps = self.check_recently_installed_apps()
        for app in recent_apps:
            if not any(r["path"] == app["path"] for r in results):
                results.append(app)

        # Check for launch agents and daemons
        print("Checking launch agents and daemons...")
        launch_agents = self.check_launch_agents()
        results.extend(launch_agents)

        # Check for unsigned applications
        print("Checking for unsigned applications...")
        for location in self.system_app_locations:
            apps = self.get_apps_from_location(location)
            for app_path in apps:
                if not any(r["path"] == app_path for r in results):
                    signature_status, risk_level = self.check_app_signature(app_path)
                    if risk_level == "High":
                        app_info = self.get_app_info(app_path)
                        app_info["reason"] = f"Signature issue: {signature_status}"
                        results.append(app_info)

        return results

def main():
    finder = BogusAppFinder()
    print("Mac Bogus App Finder")
    print("====================")
    print("Scanning your Mac for suspicious applications...")
    print("This may take a few minutes...")
    print()

    results = finder.scan_system()

    if not results:
        print("\nNo suspicious applications found on your system!")
        return

    print(f"\nFound {len(results)} potentially suspicious items:")
    print("==================================================")

    # Group by risk level
    high_risk = [app for app in results if app.get("risk_level") == "High"]
    medium_risk = [app for app in results if app.get("risk_level") == "Medium"]
    low_risk = [app for app in results if app.get("risk_level") == "Low"]
    unknown_risk = [app for app in results if app.get("risk_level") not in ["High", "Medium", "Low"]]

    # Print high risk items
    if high_risk:
        print("\n🔴 HIGH RISK ITEMS:")
        for app in high_risk:
            print(f"  • {app.get('name', 'Unknown')}")
            print(f"    Path: {app.get('path', 'Unknown')}")
            print(f"    Reason: {app.get('reason', 'Unknown')}")
            if 'signature' in app:
                print(f"    Signature: {app['signature']}")
            print()

    # Print medium risk items
    if medium_risk:
        print("\n🟠 MEDIUM RISK ITEMS:")
        for app in medium_risk:
            print(f"  • {app.get('name', 'Unknown')}")
            print(f"    Path: {app.get('path', 'Unknown')}")
            print(f"    Reason: {app.get('reason', 'Unknown')}")
            if 'signature' in app:
                print(f"    Signature: {app['signature']}")
            print()

    # Print low risk items
    if low_risk:
        print("\n🟡 LOW RISK ITEMS:")
        for app in low_risk:
            print(f"  • {app.get('name', 'Unknown')}")
            print(f"    Path: {app.get('path', 'Unknown')}")
            print(f"    Reason: {app.get('reason', 'Unknown')}")
            print()

    # Print unknown risk items
    if unknown_risk:
        print("\n⚪ UNKNOWN RISK ITEMS:")
        for app in unknown_risk:
            print(f"  • {app.get('name', 'Unknown')}")
            print(f"    Path: {app.get('path', 'Unknown')}")
            print(f"    Reason: {app.get('reason', 'Unknown')}")
            print()

    print("\nRECOMMENDATIONS:")
    print("1. Research each application before removing it")
    print("2. For high-risk items, consider removal if you don't recognize them")
    print("3. For unsigned applications, verify they're from trusted sources")
    print("4. Use macOS System Settings > Privacy & Security to check authorized apps")

    print("\nTo remove an application, drag it to the Trash and empty the Trash")
    print("For Launch Agents/Daemons, you may need to restart your Mac after removal")

if __name__ == "__main__":
    main()
