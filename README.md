# Omarchy

Omarchy is a beautiful, modern & opinionated Linux distribution by DHH.

Read more at [omarchy.org](https://omarchy.org).

## Keyboard Layout Setup (for stock Omarchy)

If you're running a stock Omarchy install and need an alternative keyboard layout (Dvorak, Colemak, BEPO, etc.), you can add keyboard layout selection without waiting for [the upstream PR](https://github.com/basecamp/omarchy/pull/4674) to be merged:

```bash
git clone https://github.com/janhesters/omarchy.git ~/omarchy-keyboard-fix
cd ~/omarchy-keyboard-fix
git checkout feat/keyboard-layout-setup-script
./setup-keyboard-select.sh
```

This will:
1. Install the `omarchy-keyboard-select` utility
2. Patch the Omarchy menu to add a Keyboard option under Update (Super+Alt+Space → Update → Keyboard)
3. Add a keyboard layout indicator to waybar (shows your active layout, click to cycle, right-click to open the selector)
4. Restart waybar to apply the changes
5. Launch the keyboard selector so you can pick your layout immediately

You can delete the cloned repo afterwards — the changes are applied to your live Omarchy install.

### Switching Between Multiple Layouts

To toggle between layouts (e.g. US and French) as [described in the FAQ](https://learn.omacom.io/2/the-omarchy-manual/67/faq):

1. Edit `~/.config/hypr/input.conf` and set multiple layouts:
   ```
   input {
     kb_layout = us,fr
     kb_options = compose:caps,grp:alts_toggle
   }
   ```
2. Toggle with **Left Alt + Right Alt**, or click the layout indicator in waybar
3. The waybar indicator updates automatically to show the active layout

If you already have multiple layouts configured when you run the setup script, it will automatically enable `grp:alts_toggle` for you.

## License

Omarchy is released under the [MIT License](https://opensource.org/licenses/MIT).
