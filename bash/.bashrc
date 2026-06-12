if [[ $- != *i* ]] ; then
    return
fi

alias make-audiobook-from-epub="QuickPiperAudiobook --threads 12 --model en_US-hfc_female-medium.onnx --chapters"
alias make-audiobook-from-txt="QuickPiperAudiobook --threads 12 --model en_US-hfc_female-medium.onnx"
alias emerge-sync="sudo emerge --sync"
alias emerge-update="sudo emerge -avuDN @world"
alias emerge-remove="sudo emerge -avc"
