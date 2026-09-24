#!/usr/bin/env sh

DOTFILES=$(realpath $(dirname $0))

symlink() {
    out=$(dirname "$HOME/$1")
    mkdir -p "$out"
    echo "Link $1 to $out"
    ln -sf "$DOTFILES/$1" "$out"
}

symlink ".bash_profile"
symlink ".bashrc"
symlink ".clang-format"
symlink ".config/autostart"
symlink ".config/btop/btop.conf"
symlink ".config/dunst/dunstrc"
symlink ".config/fcitx5/config"
symlink ".config/fontconfig/conf.d/99-japanese-fonts.conf"
symlink ".config/foot/foot.ini"
symlink ".config/git/config"
symlink ".config/gtk-3.0/settings.ini"
symlink ".config/gtk-4.0/settings.ini"
symlink ".config/hypr/.luarc.json"
symlink ".config/hypr/hyprland.lua"
symlink ".config/kanshi/config"
symlink ".config/labwc/autostart"
symlink ".config/labwc/rc.xml"
symlink ".config/mpd"
symlink ".config/mpv/input.conf"
symlink ".config/mpv/mpv.conf"
symlink ".config/user-dirs.dirs"
symlink ".emacs"
symlink "scripts"
