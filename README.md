# Dotfiles

My personal dotfiles, including configuration files and scripts. To
deploy this configuration, you need Zig 0.16.

# Configurations

- alacritty
- bash
- btop
- clang
- emacs
- fcitx5
- git
- gtk
- i3
- i3status
- picom
- qt6ct
- x11
- fonts

# Scripts

- deploy - create symlinks for configs.
- wallpaper - use the path in the clipboard to create a wallpaper from
  any image and set it. Uses ImageMagick and xwallpaper.

# Deployment

```sh
zig build deploy
zig build -Dscripts=true -Doptimize=ReleaseFast -p ~/.local/
```

# Refereces
- ./fonts/99-japanese-fonts.conf from https://github.com/tatsumoto-ren/dotfiles
