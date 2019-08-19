#!/bin/bash
# qvm-screenshot-to-clipboard
# Creates a dom0 screenshot and copy it to the Clipboard of an AppVM

# Define Variables
MyAppVM=$1
MyScreenshot=qvm-screenshot-to-clipboard.png

# Take screenshot in dom0 by selecting an area and adding border+shadow
gnome-screenshot --area --include-border --border-effect=shadow --file=/tmp/$MyScreenshot

# Copy screenhot to AppVM 
qvm-move-to-vm $MyAppVM /tmp/$MyScreenshot

# Create a helper-Script in the AppVM to copy screenshot file to clipboard
echo "xclip -selection clipboard -l 1 -t image/png /home/user/QubesIncoming/dom0/$MyScreenshot &>/dev/null" > /tmp/file2clipboard.sh
chmod +x /tmp/file2clipboard.sh
qvm-move-to-vm $MyAppVM /tmp/file2clipboard.sh
# Send notification for 5sec when Screenshot has been pasted into (!) AppVM
notify-send --urgency low --icon image --expire-time=5000 "qvm-screenshot-to-clipboard" "Screenshot available in $MyAppVM's clipboard"
# Run the helper script in the AppVM
qvm-run $MyAppVM /home/user/QubesIncoming/dom0/file2clipboard.sh

### The last command will remain active until the pasting has been done in the AppVM

# Send notification for 5sec after Screenshot has been pasted from (!) AppVM
notify-send --urgency low --icon image --expire-time=5000 "qvm-screenshot-to-clipboard" "Screenshot pasted from $MyAppVM's clipboard"

# Remove helper script and screenshot file in AppVM
qvm-run $MyAppVM "rm -f /home/user/QubesIncoming/dom0/file2clipboard.sh /home/user/QubesIncoming/dom0/$MyScreenshot"
