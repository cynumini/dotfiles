if [[ -f ~/.bashrc ]] ; then
    . ~/.bashrc
fi

export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/go/bin:$PATH
export PATH=$HOME/opt/msvc/bin/x64:$PATH
export PATH=$HOME/scripts:$PATH

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
    exec dbus-launch --exit-with-session start-hyprland
fi
