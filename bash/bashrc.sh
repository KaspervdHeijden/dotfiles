[[ -z "${PS1}" ]] && return;

HISTCONTROL=ignoreboth;
HISTFILESIZE=20000;
HISTSIZE=20000;

shopt -s checkwinsize histappend dirspell;

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)";
if [ -x /usr/bin/dircolors ]; then
    [ -r ~/.dircolors ] && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)";
    alias fgrep='fgrep --color=auto';
    alias egrep='egrep --color=auto';
    alias grep='grep --color=auto';
    alias ls='ls --color=auto';
fi

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        source /usr/share/bash-completion/bash_completion;
    elif [ -f /etc/bash_completion ]; then
        source /etc/bash_completion;
    fi
fi

source "${DOTFILES_DIR}/bash/prompt.sh";
source "${DOTFILES_DIR}/dotfiles.sh";

