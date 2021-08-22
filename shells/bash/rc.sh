# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

[ -z "${PS1}" ] && return;

export DF_ROOT_DIR="$(realpath "$(dirname "${BASH_SOURCE}")/../..")";

HISTCONTROL=ignoreboth;
HISTFILESIZE=20000;
HISTSIZE=20000;

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)";
if [ -x /usr/bin/dircolors ]; then
    [ -r "${HOME}/.dircolors" ] && eval "$(dircolors -b "${HOME}/.dircolors")" || eval "$(dircolors -b)";
    alias fgrep='fgrep --color=auto';
    alias egrep='egrep --color=auto';
    alias grep='grep --color=auto';
    alias ls='ls --color=auto';
fi

if [ -x "$(command -v shopt)" ]; then
    shopt -s checkwinsize histappend dirspell 2>/dev/null;

    if ! shopt -oq posix 2>/dev/null; then
        if [ -f /usr/share/bash-completion/bash_completion ]; then
            . /usr/share/bash-completion/bash_completion;
        elif [ -f /etc/bash_completion ]; then
            . /etc/bash_completion;
        fi
    fi
fi

if [ -d "${OSH}" ] && [ -r "${OSH}/oh-my-bash.sh" ]; then
    export completions=(git composer ssh);
    export plugins=(sudo pass);
    export UPDATE_OSH_DAYS=7;

    . "${OSH}/oh-my-bash.sh";
fi

. "${DF_ROOT_DIR}/shells/bash/completions.sh";
. "${DF_ROOT_DIR}/shells/bash/prompt.sh";
. "${DF_ROOT_DIR}/dotfiles.sh";

if [ -f "${DF_ROOT_DIR}/plugins/bash.sh" ]; then
    . "${DF_ROOT_DIR}/plugins/bash.sh";
fi
