if [[ -f ~/.bashrc ]] ; then
    . ~/.bashrc
fi

if [ -f ~/.private ]; then
	. ~/.private
fi

export PATH=$PATH:~/.local/bin
