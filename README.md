# Omarchy

Omarchy is a beautiful, modern & opinionated Linux distribution by DHH.

Read more at [omarchy.org](https://omarchy.org).

## Keyboard Layout Setup (for stock Omarchy)

If you're running a stock Omarchy install and need alternative keyboard layouts, you can add keyboard layout selection and switching without waiting for [the upstream PR](https://github.com/basecamp/omarchy/pull/4674) to be merged:

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

You can delete the cloned repo afterwards — the changes are applied to your live Omarchy install.

### How It Works

After running the setup script:

- **Left Alt + Right Alt** cycles through: US → Dvorak → Pinyin → US → ...
- **Click** the layout indicator in waybar to cycle layouts
- **Right-click** the layout indicator to open the full keyboard selector
- **Hover** over the indicator to see the full layout name (e.g. "English (Dvorak)")

This follows the [multi-layout switching approach described in the FAQ](https://learn.omacom.io/2/the-omarchy-manual/67/faq).

## License

Omarchy is released under the [MIT License](https://opensource.org/licenses/MIT).
