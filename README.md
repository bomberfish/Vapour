# Vapour

An opinionated window transparency tweak for macOS.
Requires the [ammonia](https://github.com/CoreBedtime/ammonia) tweak runtime.

## Installation

```
make
sudo make install
```

## Tips
Vapour reads from both the app's and the global defaults domains. You can control Vapour features through macOS's built-in `defaults` command.

```bash
# Write a global setting
defaults write -g VapourEnabled -bool false
# Write an app-specific setting
defaults write com.example.MyApp VapourEnabled -bool true
```
### Available settings
- `VapourEnabled` (boolean, default: true): Enable or disable Vapour.
- `VapourOpacity` (float, default: 0.97): Set the opacity level for windows.
- `VapourOverrideColours` (boolean, default: false): Enable or disable color overrides. Currently only works for dark mode.
<!-- - `VapourDisableBorder` (boolean, default: true): Enable or disable window borders. -->