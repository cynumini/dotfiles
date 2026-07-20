if [[ -f ~/.bashrc ]] ; then
    . ~/.bashrc
fi

export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/scripts:$PATH

export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export QT_QPA_PLATFORMTHEME=qt6ct

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
    exec dbus-launch --exit-with-session labwc
fi
