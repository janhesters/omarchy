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
3. Launch the keyboard selector so you can pick your layout immediately

You can delete the cloned repo afterwards — the changes are applied to your live Omarchy install.

## License

Omarchy is released under the [MIT License](https://opensource.org/licenses/MIT).
