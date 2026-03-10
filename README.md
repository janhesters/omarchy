# Omarchy

Omarchy is a beautiful, modern & opinionated Linux distribution by DHH.

Read more at [omarchy.org](https://omarchy.org).

## Keyboard Layout Setup (Dvorak + ABC Extended + Pinyin)

One-command setup for Dvorak, ABC Extended (QWERTY), and Pinyin (Simplified Chinese) on a fresh Omarchy install. Designed for users with a Dvorak laptop keyboard and a hardware-Dvorak external keyboard (e.g. Kinesis Advantage 2) who also need Chinese input.

### Quick Start

On your freshly installed Omarchy machine:

```bash
curl -fsSL https://raw.githubusercontent.com/janhesters/omarchy/feat/keyboard-layout-setup-script/setup-dvorak-pinyin.sh | bash
```

Or if you prefer to inspect first:

```bash
git clone https://github.com/janhesters/omarchy.git ~/omarchy-keyboard
cd ~/omarchy-keyboard
git checkout feat/keyboard-layout-setup-script
./setup-dvorak-pinyin.sh
```

You can delete the cloned repo afterwards — the changes are applied to your live config.

### What It Does

1. Installs `fcitx5-chinese-addons` (Omarchy already ships fcitx5)
2. Configures Hyprland with two Latin layouts: **Dvorak** (default) and **US QWERTY**
3. Configures fcitx5 for **Pinyin** input with a non-conflicting trigger key
4. Adds a **keyboard layout indicator** to waybar (click to toggle)
5. Applies everything live — no reboot needed

### How It Works

| What | Shortcut |
|------|----------|
| Dvorak ↔ QWERTY | **Left Alt + Right Alt** |
| Pinyin on/off | **Ctrl + /** |

Latin layout switching and Chinese input are on **separate toggles**. Pinyin inherits whichever Latin layout is currently active — so Dvorak gives you Dvorak-based romanization, and QWERTY gives you QWERTY-based romanization, just like macOS.

This works because Omarchy's fcitx5 is configured to not override XKB settings (`Allow Overriding System XKB Settings=False` in `xcb.conf`), so Pinyin defers to Hyprland for the underlying layout.

#### Why not `Ctrl+Space` or `Super+Space`?

- `Ctrl+Space` is the **tmux prefix** in Omarchy
- `Super+Space` is the **app launcher** (walker)
- `Ctrl+/` is unused and easy to reach

### What It Modifies

All changes are config-file-only:

| File | Change |
|------|--------|
| `~/.config/hypr/input.conf` | Sets `kb_layout=us,us`, `kb_variant=dvorak,`, enables `grp:alts_toggle` |
| `~/.config/fcitx5/conf/config` | Sets Pinyin trigger to `Ctrl+/` |
| `~/.config/fcitx5/profile` | Adds Pinyin as the fcitx5 input method |
| `~/.config/waybar/config.jsonc` | Adds `hyprland/language` module |
| `~/.config/waybar/style.css` | Adds `#language` styling |

Re-running the script is safe — it skips changes that are already applied.

### Pre-Install Note

When installing Arch Linux (before Omarchy), select **dvorak** as your keyboard layout. Omarchy's `detect-keyboard-layout.sh` will pick this up, so your first boot is already on Dvorak. Then run the script above to get the full setup.

---

<details>
<summary><strong>Legacy: XKB-only approach (setup-keyboard-select.sh)</strong></summary>

An earlier approach that treats all three layouts (US, Dvorak, Pinyin) as XKB keyboard layouts cycled with a single `Left Alt + Right Alt` toggle.

```bash
git clone https://github.com/janhesters/omarchy.git ~/omarchy-keyboard-fix
cd ~/omarchy-keyboard-fix
git checkout feat/keyboard-layout-setup-script
./setup-keyboard-select.sh
```

**Why this was replaced:**

- Pinyin as an XKB layout (`cn`) maps Chinese characters directly to physical keys — it does **not** give you romanized Pinyin input (typing "nihao" to get 你好). For actual Pinyin, you need fcitx5's Pinyin input method.
- Cycling 3 layouts on one toggle is clunky (sometimes 2 presses to reach the layout you want).
- Patching `omarchy-menu` with Python string manipulation is fragile across upstream updates.
- No separation between Latin switching and Chinese input — can't have Pinyin follow the active Latin layout.

The new `setup-dvorak-pinyin.sh` script solves all of these issues.

</details>

## License

Omarchy is released under the [MIT License](https://opensource.org/licenses/MIT).
