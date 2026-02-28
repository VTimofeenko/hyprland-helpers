# Hyprland Helpers

A collection of Rust-based utilities for Hyprland:

- `hyprland-lang-notifier` Displays notifications for keyboard layout changes.
- `hyprland-mode-notifier` Displays notifications for submap/mode changes.
- `hyprland-workspace-notifier` Displays notifications for workspace switches.
- `hyprland-switch-lang-on-xremap` Helper for layout synchronization.

## Installation

### Using Nix

This repository is a Nix flake. You can run the binaries directly:

```bash
nix run github:VTimofeenko/hyprland-helpers#hyprland-lang-notifier
```

Or add the packages to your system configuration.

### Home Manager modules

The flake exports Home Manager modules for easy configuration:

```nix
{ inputs, ... }: {
  imports = [ inputs.hyprland-helpers.homeManagerModules.hyprland-helpers ];
  services.hyprland-helpers.enable = true;
}
```
