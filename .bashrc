if [[ $- != *i* ]] ; then
    return
fi

if [ -f ~/.private ]; then
    . ~/.private
fi

alias emerge-remove="sudo emerge -avc"
alias emerge-sync="sudo emerge --sync"
alias emerge-update="sudo emerge -avuDN @world"
alias emerge-update-9999="sudo emerge --ask @live-rebuild"
alias make-audiobook-from-epub="QuickPiperAudiobook --threads 12 --model en_US-hfc_female-medium.onnx --chapters"
alias make-audiobook-from-txt="QuickPiperAudiobook --threads 12 --model en_US-hfc_female-medium.onnx"
alias un7z="7z x"
alias untargz="tar -xvzf"
alias unzip_jp="unzip -O shift-jis"
alias music="mpv $HOME/music --shuffle"

timer () {
    termdown $1
    notify-send -u critical "It's time to stop" > /dev/null
    mpv ~/documents/notification.opus --no-config > /dev/null
}

roll() {
    shuf -i 1-$1 -n 1
}

c () {
    python -c "import math; print($1)"
}

icon-extract() {
    wrestool -x -t 14 "$1" > output.ico; magick convert output.ico output.png; rm output.ico
}

compress() {
    tar -cf - $1 | zstd -19 -o $2.tar.zst
}

mount-iso() {
    sudo mount $1 /mnt -o loop
}
