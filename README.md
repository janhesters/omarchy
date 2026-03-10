# Omarchy

Omarchy is a beautiful, modern & opinionated Linux distribution by DHH.

Read more at [omarchy.org](https://omarchy.org).

## Keyboard Layout Setup

Two approaches for configuring alternative keyboard layouts (e.g. Dvorak + Pinyin) on Omarchy.

### Approach A: Automated Script

Run the setup script to automatically configure US, Dvorak, and Pinyin layouts with waybar integration:

```bash
git clone https://github.com/janhesters/omarchy.git ~/omarchy-keyboard-fix
cd ~/omarchy-keyboard-fix
git checkout feat/keyboard-layout-setup-script
./setup-keyboard-select.sh
```

This will:
1. Install the `omarchy-keyboard-select` utility
2. Patch the Omarchy menu to add a Keyboard option under Update (Super+Alt+Space → Update → Keyboard)
3. Configure three keyboard layouts: **US (QWERTY)**, **Dvorak**, and **Pinyin (Simplified Chinese)**
4. Enable toggling between layouts with **Left Alt + Right Alt**
5. Add a keyboard layout indicator to waybar (shows your active layout, click to cycle, right-click to open the keyboard selector)
6. Restart waybar and apply all changes live

After running the setup script:

- **Left Alt + Right Alt** cycles through: US → Dvorak → Pinyin → US → ...
- **Click** the layout indicator in waybar to cycle layouts
- **Right-click** the layout indicator to open the full keyboard selector
- **Hover** over the indicator to see the full layout name (e.g. "English (Dvorak)")

You can delete the cloned repo afterwards — the changes are applied to your live Omarchy install.

### Approach B: Manual Configuration (Dvorak + ABC Extended + Pinyin)

If you need separate control over Latin layout switching (Dvorak ↔ QWERTY) and Chinese input (Pinyin), and you want Pinyin to follow your active Latin layout (like macOS), use this manual approach instead.

#### During Arch Linux Installation

Select **dvorak** as your keyboard layout when the installer prompts you. Omarchy's `detect-keyboard-layout.sh` will pick this up automatically.

#### After Omarchy Boots

**Step 1: Configure Dvorak ↔ QWERTY switching**

Edit `~/.config/hypr/input.conf` and set:

```
kb_layout = us,us
kb_variant = dvorak,
kb_options = compose:caps,grp:alts_toggle
```

- Layout 1 (default): **Dvorak** — for your laptop's built-in keyboard
- Layout 2: **US QWERTY** ("ABC Extended") — for external keyboards with hardware Dvorak (e.g. Kinesis Advantage 2)
- Toggle: **Left Alt + Right Alt**

Hyprland auto-reloads on save.

**Step 2: Install Pinyin support**

```bash
sudo pacman -S fcitx5-chinese-addons
```

Omarchy already ships `fcitx5`, `fcitx5-gtk`, and `fcitx5-qt`.

**Step 3: Configure fcitx5 for Pinyin**

Create the fcitx5 config for a non-conflicting trigger key:

```bash
mkdir -p ~/.config/fcitx5/conf
```

Write `~/.config/fcitx5/conf/config`:

```ini
[Hotkey]
TriggerKeys="Control+slash"
EnumerateKeys=
```

> **Why `Ctrl+/`?** Both `Ctrl+Space` (tmux prefix) and `Super+Space` (app launcher) are already taken in Omarchy.

Write `~/.config/fcitx5/profile`:

```ini
[Groups/0]
Name=Default
Default Layout=
DefaultIM=pinyin

[Groups/0/Items/0]
Name=pinyin
Layout=

[GroupOrder]
0=Default
```

Then restart fcitx5:

```bash
fcitx5-remote -r
```

#### How It Works

| What | Shortcut | Mechanism |
|------|----------|-----------|
| Dvorak ↔ QWERTY | Left Alt + Right Alt | Hyprland XKB |
| Pinyin on/off | Ctrl + / | fcitx5 |

Because Omarchy's fcitx5 is configured to **not override XKB settings** (`Allow Overriding System XKB Settings=False` in `xcb.conf`), Pinyin inherits whichever Latin layout Hyprland currently has active:

- Dvorak active → activate Pinyin → romanization follows Dvorak key positions
- QWERTY active → activate Pinyin → romanization follows QWERTY key positions

This matches macOS behavior where switching from Dvorak to Pinyin gives you Dvorak-based romanization.

### Which approach should I use?

| | Approach A (Script) | Approach B (Manual) |
|-|---------------------|---------------------|
| **Setup** | One command | Edit 3 files |
| **Layout cycling** | All 3 layouts on one toggle (Alt+Alt) | Latin and Pinyin on separate toggles |
| **Pinyin behavior** | Fixed to one XKB layout at a time | Follows your active Latin layout (macOS-like) |
| **Waybar indicator** | Included | Not included |
| **Best for** | Quick setup, single keyboard | Dvorak laptop + QWERTY external keyboard, macOS converts |

## License

Omarchy is released under the [MIT License](https://opensource.org/licenses/MIT).
