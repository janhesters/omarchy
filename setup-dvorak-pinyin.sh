#!/bin/bash

# Post-install setup for Dvorak + ABC Extended (QWERTY) + Pinyin on Omarchy.
#
# - Hyprland XKB handles Dvorak ↔ QWERTY (Left Alt + Right Alt)
# - fcitx5 handles Pinyin on/off (Ctrl+/)
# - Pinyin inherits the active Latin layout (macOS-like behavior)
# - Waybar shows the active XKB layout indicator
#
# Usage (on a fresh Omarchy install):
#   curl -fsSL https://raw.githubusercontent.com/janhesters/omarchy/feat/keyboard-layout-setup-script/setup-dvorak-pinyin.sh | bash

set -e

HYPR_INPUT="$HOME/.config/hypr/input.conf"
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
FCITX5_CONF_DIR="$HOME/.config/fcitx5/conf"
FCITX5_PROFILE="$HOME/.config/fcitx5/profile"

echo "Setting up Dvorak + ABC Extended + Pinyin..."
echo ""

# 1. Install Pinyin input method
echo "[1/4] Installing fcitx5-chinese-addons..."
sudo pacman -S --noconfirm --needed fcitx5-chinese-addons

# 2. Configure Hyprland: Dvorak (default) + US QWERTY, toggle with Alt+Alt
echo "[2/4] Configuring keyboard layouts in input.conf..."

if [[ -f "$HYPR_INPUT" ]]; then
  # Remove existing kb_layout and kb_variant lines (commented or not)
  sed -i'' -e '/^[[:space:]]*#*[[:space:]]*kb_layout *=/d' "$HYPR_INPUT"
  sed -i'' -e '/^[[:space:]]*#*[[:space:]]*kb_variant *=/d' "$HYPR_INPUT"
  sed -i'' -e '/Use a specific keyboard variant/d' "$HYPR_INPUT"
  sed -i'' -e '/Use multiple keyboard layouts/d' "$HYPR_INPUT"

  # Insert Dvorak + US layouts before kb_options
  sed -i'' -e '/^[[:space:]]*kb_options/i\
  kb_layout = us,us\
  kb_variant = dvorak,' "$HYPR_INPUT"

  # Enable grp:alts_toggle
  if grep -q 'grp:alts_toggle' "$HYPR_INPUT"; then
    sed -i'' -e 's/\(compose:caps\)[[:space:]]*#[[:space:]]*,\(grp:alts_toggle\)/\1,\2/' "$HYPR_INPUT"
  else
    sed -i'' -e 's/\(kb_options = .*[^[:space:]]\)/\1,grp:alts_toggle/' "$HYPR_INPUT"
  fi

  echo "  → kb_layout = us,us (dvorak, qwerty)"
  echo "  → Toggle: Left Alt + Right Alt"
fi

# 3. Configure fcitx5 for Pinyin with Ctrl+/ trigger
echo "[3/4] Configuring fcitx5 for Pinyin..."

mkdir -p "$FCITX5_CONF_DIR"

cat > "$FCITX5_CONF_DIR/config" <<'EOF'
[Hotkey]
TriggerKeys="Control+slash"
EnumerateKeys=
EOF

cat > "$FCITX5_PROFILE" <<'EOF'
[Groups/0]
Name=Default
Default Layout=
DefaultIM=pinyin

[Groups/0/Items/0]
Name=pinyin
Layout=

[GroupOrder]
0=Default
EOF

echo "  → Pinyin trigger: Ctrl+/"
echo "  → Pinyin inherits active XKB layout"

# 4. Add waybar keyboard layout indicator
echo "[4/4] Adding waybar layout indicator..."

if [[ -f "$WAYBAR_CONFIG" ]]; then
  if grep -q 'hyprland/language' "$WAYBAR_CONFIG"; then
    echo "  → Waybar already has language module, skipping."
  else
    # Add hyprland/language to modules-right (after tray-expander)
    sed -i'' -e 's/"group\/tray-expander",/"group\/tray-expander",\n    "hyprland\/language",/' "$WAYBAR_CONFIG"

    # Add the module config (before the tray definition)
    sed -i'' -e '/"tray": {/i\
  "hyprland/language": {\
    "format": "{short}",\
    "tooltip-format": "{long}",\
    "on-click": "hyprctl switchxkblayout all next"\
  },' "$WAYBAR_CONFIG"

    echo "  → Added hyprland/language module to waybar"
  fi
fi

if [[ -f "$WAYBAR_STYLE" ]]; then
  if grep -q '#language' "$WAYBAR_STYLE"; then
    echo "  → Waybar style already has language rule, skipping."
  else
    cat >> "$WAYBAR_STYLE" <<'CSSEOF'

#language {
  min-width: 12px;
  margin: 0 7.5px;
  text-transform: uppercase;
}
CSSEOF
    echo "  → Added language indicator styling"
  fi
fi

# Apply live
if command -v hyprctl &>/dev/null; then
  hyprctl keyword input:kb_layout "us,us" 2>/dev/null || true
  hyprctl keyword input:kb_variant "dvorak," 2>/dev/null || true
  hyprctl keyword input:kb_options "compose:caps,grp:alts_toggle" 2>/dev/null || true
fi

if command -v fcitx5-remote &>/dev/null; then
  fcitx5-remote -r 2>/dev/null || true
fi

# Restart waybar
pkill waybar 2>/dev/null || true
sleep 0.5
hyprctl dispatch exec waybar 2>/dev/null || uwsm-app -- waybar 2>/dev/null || true

echo ""
echo "Done! Your keyboard setup:"
echo ""
echo "  Dvorak ↔ QWERTY    Left Alt + Right Alt"
echo "  Pinyin on/off       Ctrl + /"
echo ""
echo "  Pinyin follows your active Latin layout:"
echo "    Dvorak active → Dvorak romanization"
echo "    QWERTY active → QWERTY romanization"
echo ""
echo "  Waybar shows your current layout (click to toggle)."
