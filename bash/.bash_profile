if [[ -f ~/.bashrc ]] ; then
    . ~/.bashrc
fi

export PATH=$PATH:~/.local/bin

export QT_QPA_PLATFORMTHEME=qt6ct

export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
