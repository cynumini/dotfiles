#!/usr/bin/env sh

DOTFILES=$(realpath $(dirname $0))

symlink-base () {
    mkdir -p "$2"
    echo "Link $1 to $2"
    ln -sf "$1" "$2"
}

symlink () {
    OUT=$(dirname "$HOME/$2")
    symlink-base "$DOTFILES/$1" "$OUT"
}

symlink2 () {
    OUT=$(dirname "$HOME/$1")
    symlink-base "$DOTFILES/$1" "$OUT"
}

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
symlink2 ".bash_profile"
symlink2 ".bashrc"
symlink2 ".config/foot/foot.ini"
symlink2 ".config/mpv/input.conf"
symlink2 "scripts"
