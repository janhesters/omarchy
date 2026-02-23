#!/bin/bash

# Post-install setup for keyboard layout selection on stock Omarchy
# Run this once after a fresh Omarchy install to add Dvorak (or any layout) support

set -e

OMARCHY_BIN="$HOME/.local/share/omarchy/bin"

# 1. Install omarchy-keyboard-select
echo "Installing omarchy-keyboard-select..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cp "$SCRIPT_DIR/bin/omarchy-keyboard-select" "$OMARCHY_BIN/omarchy-keyboard-select"
chmod +x "$OMARCHY_BIN/omarchy-keyboard-select"

# 2. Patch omarchy-menu to add Keyboard entry to the Update menu
echo "Patching omarchy-menu..."
MENU="$OMARCHY_BIN/omarchy-menu"

if grep -q 'Keyboard.*omarchy-keyboard-select' "$MENU"; then
  echo "omarchy-menu already patched, skipping."
else
  # Add Keyboard to the menu options string (before Timezone)
  python3 -c "
with open('$MENU', 'rb') as f:
    data = f.read()

# Find 'Password\n' followed by the Timezone icon and insert Keyboard entry
import re
# Match Password\\n<icon>  Timezone pattern
idx = data.find(b'Password')
if idx == -1:
    print('ERROR: Could not find Password in omarchy-menu')
    exit(1)

# Find the \\n after Password
newline_idx = data.find(b'\\\\n', idx)
if newline_idx == -1:
    newline_idx = data.find(b'\\n', idx)
    insert = b'\\n\xe2\x8c\xa8  Keyboard'
else:
    insert = b'\\\\n\xe2\x8c\xa8  Keyboard'

data = data[:newline_idx] + insert + data[newline_idx:]

with open('$MENU', 'wb') as f:
    f.write(data)
print('Menu options updated.')
"

  # Add the case match for Keyboard (before *Timezone*)
  sed -i'' -e '/*Timezone.*omarchy-tz-select/i\
  *Keyboard*) present_terminal omarchy-keyboard-select ;;' "$MENU"

  echo "omarchy-menu patched."
fi

# 3. Run the keyboard selector now
echo ""
echo "Setup complete! Launching keyboard selector..."
echo ""
exec omarchy-keyboard-select
