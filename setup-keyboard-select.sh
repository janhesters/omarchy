#!/bin/bash

# Post-install setup for keyboard layout selection on stock Omarchy
# Run this once after a fresh Omarchy install to add Dvorak (or any layout) support

set -e

OMARCHY_BIN="$HOME/.local/share/omarchy/bin"
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"

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

# 3. Add keyboard layout indicator to waybar
echo "Configuring waybar keyboard layout indicator..."

if grep -q 'hyprland/language' "$WAYBAR_CONFIG"; then
  echo "Waybar already has language module, skipping."
else
  # Add hyprland/language to modules-right (after tray-expander)
  sed -i'' -e 's/"group\/tray-expander",/"group\/tray-expander",\n    "hyprland\/language",/' "$WAYBAR_CONFIG"

  # Add the module configuration (before the tray definition)
  sed -i'' -e '/"tray": {/i\
  "hyprland/language": {\
    "format": "{short}",\
    "tooltip-format": "{long}",\
    "on-click": "hyprctl switchxkblayout all next",\
    "on-click-right": "omarchy-launch-floating-terminal-with-presentation omarchy-keyboard-select"\
  },' "$WAYBAR_CONFIG"

  echo "Waybar config updated."
fi

if grep -q '#language' "$WAYBAR_STYLE"; then
  echo "Waybar style already has language rule, skipping."
else
  # Add styling for the language module
  cat >> "$WAYBAR_STYLE" <<'CSSEOF'

#language {
  min-width: 12px;
  margin: 0 7.5px;
  text-transform: uppercase;
}
CSSEOF

  echo "Waybar style updated."
fi

# 4. Enable layout switching in input.conf if multiple layouts are configured
HYPR_INPUT="$HOME/.config/hypr/input.conf"
if [[ -f "$HYPR_INPUT" ]] && grep -q 'kb_layout.*,.*' "$HYPR_INPUT"; then
  # Multiple layouts detected — enable grp:alts_toggle if not already present
  if ! grep -q 'grp:alts_toggle' "$HYPR_INPUT"; then
    sed -i'' -e 's/kb_options = \(.*\)/kb_options = \1,grp:alts_toggle/' "$HYPR_INPUT"
    echo "Enabled Alt+Alt layout switching (multiple layouts detected)."
  fi
fi

# 5. Restart waybar to apply changes
echo "Restarting waybar..."
pkill waybar 2>/dev/null || true
hyprctl dispatch exec waybar 2>/dev/null || true

# 6. Run the keyboard selector now
echo ""
echo "Setup complete! Launching keyboard selector..."
echo ""
exec omarchy-keyboard-select
