#!/usr/bin/env python3
"""
Clipboard Reset Tool

This script helps clear the clipboard and manage clipboard data
to prevent issues with large clipboard content.

Usage:
- Run the script directly from your downloads folder
- Select the appropriate option based on your operating system
"""

import os
import sys
import subprocess
import platform
import time

def clear_windows_clipboard():
    try:
        # Using PowerShell to clear clipboard
        subprocess.run(["powershell", "-command", "Set-Clipboard -Value ''"], check = True)
        print("Clipboard successfully cleared on Windows!")
    except Exception as e:
        print(f"Error clearing Windows clipboard: {e}")
        print("Alternative method: Try pressing Windows+V and clearing clipboard history")

def clear_mac_clipboard():
    try:
        # Using pbcopy to clear clipboard
        subprocess.run("pbcopy < /dev/null", shell = True, check = True)
        print("Clipboard successfully cleared on Mac!")
    except Exception as e:
        print(f"Error clearing Mac clipboard: {e}")
        print("Alternative method: Try using Command+Option+Shift+V to paste without formatting")

def clear_linux_clipboard():
    try:
        # Try xsel first
        try:
            subprocess.run(["xsel", "--clear"], check = True)
            print("Clipboard successfully cleared using xsel!")
            return
        except FileNotFoundError:
            pass

        # Try xclip if xsel not available
        try:
            subprocess.run(["xclip", "-selection", "clipboard", "-i", "/dev/null"], check = True)
            print("Clipboard successfully cleared using xclip!")
            return
        except FileNotFoundError:
            pass

        print("Could not find xsel or xclip. Please install one of these utilities.")
    except Exception as e:
        print(f"Error clearing Linux clipboard: {e}")

def limit_clipboard_size():
    os_type = platform.system().lower()

    if os_type == 'windows':
        try:
            # PowerShell script to get and limit clipboard text
            ps_script = """
            $text = Get-Clipboard -Format Text
            if ($text.Length -gt 5000) {
                Set-Clipboard -Value $text.Substring(0, 5000)
                "Clipboard content limited to 5000 characters"
            } else {
                "Clipboard content already within limits"
            }
            """
            result = subprocess.run(["powershell", "-command", ps_script],
                                   capture_output = True, text = True, check = True)
            print(result.stdout.strip())
        except Exception as e:
            print(f"Error limiting clipboard size on Windows: {e}")

    elif os_type == 'darwin':  # macOS
        try:
            # Get clipboard content via pbpaste, limit it, and set via pbcopy
            clipboard = subprocess.run(["pbpaste"], capture_output = True, text = True).stdout
            if len(clipboard) > 5000:
                limited_content = clipboard[:5000]
                subprocess.run(["pbcopy"], input = limited_content.encode(), check = True)
                print("Clipboard content limited to 5000 characters")
            else:
                print("Clipboard content already within limits")
        except Exception as e:
            print(f"Error limiting clipboard size on Mac: {e}")

    else:  # Linux
        print("Clipboard size limiting not implemented for Linux yet")
        print("Please use the clear clipboard option instead")

def monitor_clipboard():
    """Monitor clipboard size and alert if it gets too large"""
    print("Clipboard monitor started. Press Ctrl+C to stop.")
    print("This will check clipboard size every 5 seconds and alert if it exceeds 1MB")

    os_type = platform.system().lower()

    try:
        while True:
            size = 0
            if os_type == 'windows':
                # PowerShell to get clipboard size
                ps_script = "$text = Get-Clipboard -Format Text; if ($text) { $text.Length } else { 0 }"
                result = subprocess.run(["powershell", "-command", ps_script],
                                      capture_output = True, text = True, check = True)
                try:
                    size = int(result.stdout.strip())
                except ValueError:
                    size = 0

            elif os_type == 'darwin':  # macOS
                # Get clipboard content size via pbpaste
                result = subprocess.run(["pbpaste"], capture_output = True)
                size = len(result.stdout)

            elif os_type == 'linux':
                # Try xsel
                try:
                    result = subprocess.run(["xsel", "--clipboard", "--output"],
                                          capture_output = True)
                    size = len(result.stdout)
                except FileNotFoundError:
                    try:
                        result = subprocess.run(["xclip", "-selection", "clipboard", "-o"],
                                              capture_output = True)
                        size = len(result.stdout)
                    except FileNotFoundError:
                        print("Could not access clipboard. Install xsel or xclip.")
                        break

            # Alert if clipboard is large
            size_kb = size / 1024
            if size_kb > 1024:  # More than 1MB
                print(f"⚠️ WARNING: Clipboard is very large: {size_kb:.2f} KB!")
                print("Consider clearing the clipboard.")
            elif size_kb > 500:  # More than 500KB
                print(f"⚠️ Clipboard is getting large: {size_kb:.2f} KB")

            time.sleep(5)

    except KeyboardInterrupt:
        print("\nClipboard monitoring stopped")

def main():
    os_type = platform.system().lower()
    print(f"Detected operating system: {platform.system()}")

    while True:
        print("\nClipboard Management Tool")
        print("------------------------")
        print("1. Clear clipboard")
        print("2. Limit clipboard to 5000 characters")
        print("3. Monitor clipboard size")
        print("4. Exit")

        choice = input("\nEnter your choice (1-4): ")

        if choice == '1':
            if os_type == 'windows':
                clear_windows_clipboard()
            elif os_type == 'darwin':  # macOS
                clear_mac_clipboard()
            elif os_type == 'linux':
                clear_linux_clipboard()
            else:
                print(f"Unsupported operating system: {os_type}")

        elif choice == '2':
            limit_clipboard_size()

        elif choice == '3':
            monitor_clipboard()

        elif choice == '4':
            print("Exiting program. Goodbye!")
            break

        else:
            print("Invalid choice. Please select 1-4.")

        # Pause before returning to menu
        input("\nPress Enter to continue...")

if __name__ == "__main__":
    main()
