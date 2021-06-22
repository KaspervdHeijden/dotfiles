# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

[ -z "${PS1}" ] && return;

HISTCONTROL=ignoreboth;
HISTFILESIZE=20000;
HISTSIZE=20000;

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)";
if [ -x /usr/bin/dircolors ]; then
    [ -r ~/.dircolors ] && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)";
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

. "${DOTFILES_DIR}/shells/bash/prompt.sh";
. "${DOTFILES_DIR}/dotfiles.sh";

if declare -f dof >/dev/null 2>/dev/null; then
    complete -W 'update reload env nav' dof;
fi

if declare -f cds >/dev/null 2>/dev/null; then
    complete -F _cds cds

    _cds()
    {
        COMPREPLY=($(compgen -W "$(cds | xargs -I{} basename {} | xargs)" -- "${COMP_WORDS[$COMP_CWORD]}") );
    }
fi

