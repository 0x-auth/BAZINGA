#!/usr/bin/env python3
"""
Improved Clipboard Fix Tool

This script helps manage the clipboard without breaking copy/paste functionality.
It provides options to clear the clipboard and safely restore copy/paste.

Usage:
- Run the script directly from your downloads folder
"""

import os
import sys
import subprocess
import platform
import time

def clear_mac_clipboard():
    """Clear clipboard on Mac without breaking functionality"""
    try:
        # Using empty string instead of /dev/null to be safer
        subprocess.run(["pbcopy"], input = b"", check = True)
        print("Clipboard successfully cleared on Mac!")
        print("Copy/paste functionality should still work normally.")
    except Exception as e:
        print(f"Error clearing Mac clipboard: {e}")

def clear_windows_clipboard():
    """Clear clipboard on Windows without breaking functionality"""
    try:
        subprocess.run(["powershell", "-command", "Set-Clipboard -Value ''"], check = True)
        print("Clipboard successfully cleared on Windows!")
        print("Copy/paste functionality should still work normally.")
    except Exception as e:
        print(f"Error clearing Windows clipboard: {e}")

def clear_linux_clipboard():
    """Clear clipboard on Linux without breaking functionality"""
    try:
        # Try xsel first with an empty string
        try:
            subprocess.run(["xsel", "-b", "-i"], input = b"", check = True)
            print("Clipboard successfully cleared using xsel!")
            return
        except FileNotFoundError:
            pass

        # Try xclip if xsel not available
        try:
            subprocess.run(["xclip", "-selection", "clipboard", "-i"], input = b"", check = True)
            print("Clipboard successfully cleared using xclip!")
            return
        except FileNotFoundError:
            pass

        print("Could not find xsel or xclip. Please install one of these utilities.")
    except Exception as e:
        print(f"Error clearing Linux clipboard: {e}")

def check_clipboard_size():
    """Check the current clipboard size without altering it"""
    os_type = platform.system().lower()
    size = 0

    try:
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
                    return 0

        size_kb = size / 1024
        print(f"Current clipboard size: {size_kb:.2f} KB")

        if size_kb > 1024:
            print("⚠️ WARNING: Clipboard is very large (>1MB)!")
        elif size_kb > 500:
            print("⚠️ Clipboard is getting large (>500KB)")
        else:
            print("Clipboard size is normal")

        return size

    except Exception as e:
        print(f"Error checking clipboard size: {e}")
        return 0

def trim_clipboard(max_chars = 5000):
    """Trim clipboard content to a maximum number of characters"""
    os_type = platform.system().lower()

    try:
        if os_type == 'windows':
            # PowerShell script to get and trim clipboard text
            ps_script = f"""
            $text = Get-Clipboard -Format Text
            if ($text -and $text.Length -gt {max_chars}) {{
                Set-Clipboard -Value $text.Substring(0, {max_chars})
                "Clipboard content trimmed to {max_chars} characters"
            }} else {{
                "Clipboard content already within limits or empty"
            }}
            """
            result = subprocess.run(["powershell", "-command", ps_script],
                                   capture_output = True, text = True, check = True)
            print(result.stdout.strip())

        elif os_type == 'darwin':  # macOS
            # Get clipboard content via pbpaste, trim it, and set via pbcopy
            clipboard = subprocess.run(["pbpaste"], capture_output = True, text = True).stdout
            if clipboard and len(clipboard) > max_chars:
                limited_content = clipboard[:max_chars]
                subprocess.run(["pbcopy"], input = limited_content.encode(), check = True)
                print(f"Clipboard content trimmed to {max_chars} characters")
            else:
                print("Clipboard content already within limits or empty")

        elif os_type == 'linux':
            # Try xsel first
            try:
                clipboard = subprocess.run(["xsel", "--clipboard", "--output"],
                                         capture_output = True, text = True).stdout
                if clipboard and len(clipboard) > max_chars:
                    limited_content = clipboard[:max_chars]
                    subprocess.run(["xsel", "--clipboard", "--input"],
                                  input = limited_content.encode(), check = True)
                    print(f"Clipboard content trimmed to {max_chars} characters")
                else:
                    print("Clipboard content already within limits or empty")
                return
            except FileNotFoundError:
                pass

            # Try xclip if xsel not available
            try:
                clipboard = subprocess.run(["xclip", "-selection", "clipboard", "-o"],
                                         capture_output = True, text = True).stdout
                if clipboard and len(clipboard) > max_chars:
                    limited_content = clipboard[:max_chars]
                    subprocess.run(["xclip", "-selection", "clipboard", "-i"],
                                  input = limited_content.encode(), check = True)
                    print(f"Clipboard content trimmed to {max_chars} characters")
                else:
                    print("Clipboard content already within limits or empty")
                return
            except FileNotFoundError:
                print("Could not access clipboard. Install xsel or xclip.")

    except Exception as e:
        print(f"Error trimming clipboard: {e}")

def test_clipboard():
    """Test clipboard functionality"""
    os_type = platform.system().lower()
    test_text = "This is a clipboard test"

    try:
        print("Testing clipboard functionality...")
        print(f"Attempting to set clipboard to: '{test_text}'")

        if os_type == 'windows':
            subprocess.run(["powershell", "-command", f"Set-Clipboard -Value '{test_text}'"],
                          check = True)

        elif os_type == 'darwin':  # macOS
            subprocess.run(["pbcopy"], input = test_text.encode(), check = True)

        elif os_type == 'linux':
            try:
                subprocess.run(["xsel", "--clipboard", "--input"],
                              input = test_text.encode(), check = True)
            except FileNotFoundError:
                try:
                    subprocess.run(["xclip", "-selection", "clipboard", "-i"],
                                  input = test_text.encode(), check = True)
                except FileNotFoundError:
                    print("Could not access clipboard. Install xsel or xclip.")
                    return

        time.sleep(1)  # Brief pause

        print("Now checking if clipboard contains the test text...")
        content = ""

        if os_type == 'windows':
            result = subprocess.run(["powershell", "-command", "Get-Clipboard -Format Text"],
                                   capture_output = True, text = True)
            content = result.stdout.strip()

        elif os_type == 'darwin':  # macOS
            result = subprocess.run(["pbpaste"], capture_output = True, text = True)
            content = result.stdout

        elif os_type == 'linux':
            try:
                result = subprocess.run(["xsel", "--clipboard", "--output"],
                                       capture_output = True, text = True)
                content = result.stdout
            except FileNotFoundError:
                try:
                    result = subprocess.run(["xclip", "-selection", "clipboard", "-o"],
                                           capture_output = True, text = True)
                    content = result.stdout
                except FileNotFoundError:
                    return

        if content.strip() == test_text:
            print("✅ Clipboard test successful! Copy/paste functionality is working.")
        else:
            print("❌ Clipboard test failed. Copy/paste may not be working correctly.")
            print(f"Expected: '{test_text}'")
            print(f"Got: '{content.strip()}'")

    except Exception as e:
        print(f"Error testing clipboard: {e}")

def main():
    os_type = platform.system().lower()
    print(f"Detected operating system: {platform.system()}")

    while True:
        print("\nClipboard Fix Tool")
        print("------------------")
        print("1. Clear clipboard (safe method)")
        print("2. Check clipboard size")
        print("3. Trim clipboard to 5000 characters")
        print("4. Test clipboard functionality")
        print("5. Exit")

        choice = input("\nEnter your choice (1-5): ")

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
            check_clipboard_size()

        elif choice == '3':
            trim_clipboard()

        elif choice == '4':
            test_clipboard()

        elif choice == '5':
            print("Exiting program. Your clipboard should now be usable.")
            break

        else:
            print("Invalid choice. Please select 1-5.")

        # Pause before returning to menu
        input("\nPress Enter to continue...")

if __name__ == "__main__":
    main()
