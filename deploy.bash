#!/usr/bin/env bash

DOTFILES=$(realpath $(dirname $0))

symlink-base () {
    DIRNAME=$(dirname "$2")
    mkdir -p "$DIRNAME"
    echo "Link $1 to $2"
    ln -sf "$1" "$2"
}

symlink () {
    symlink-base "$DOTFILES/$1" "$HOME/$2"
}

symlink2 () {
    symlink-base "$DOTFILES/$1" "$HOME/$1"
}

symlink "alacritty/alacritty.toml" ".config/alacritty.toml"
symlink "bash/.bash_profile" ".bash_profile"
symlink "bash/.bashrc" ".bashrc"
symlink "btop/btop.conf" ".config/btop/btop.conf"
symlink "clang/.clang-format" ".clang-format"
symlink "emacs/.emacs" ".emacs"
symlink "fcitx5/config" ".config/fcitx5/config"
symlink "fonts/99-japanese-fonts.conf" ".config/fontconfig/conf.d/99-japanese-fonts.conf"
symlink "git/config" ".config/git/config"
symlink "gtk/settings.ini" ".config/gtk-3.0/settings.ini"
symlink "i3/config" ".config/i3/config"
symlink "i3status/config" ".config/i3status/config"
symlink "picom/picom.conf" ".config/picom.conf"
symlink "qt6ct/qt6ct.conf" ".config/qt6ct/qt6ct.conf"
symlink "x11/.xinitrc" ".xinitrc"
symlink2 ".config/mpv/input.conf"
