# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTCONTROL=ignoreboth;
shopt -s histappend;
HISTFILESIZE=20000;
HISTSIZE=10000;

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize;

# Make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)";

function display-exitcode()
{
    local lastExitCode="${?}";
    [[ "${lastExitCode}" == '0' ]] && return 0;
    echo -ne "\033[1;31m${lastExitCode}\033[0;00m ";
}

if [[ -x /usr/bin/tput ]] && tput setaf 1 >&/dev/null; then
    PS1="[\$(display-exitcode)\e[1;37m\u\e[0;37m@\e[32m\h \e[36m\w\e[0m \$(date +'%H:%M')\e[32m\$(__git_ps1)\e[0m]\n% ";
#    GIT_PS1_SHOWDIRTYSTATE=1;
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ ';
fi

# Enable color support of ls and also add handy aliases
if [[ -x /usr/bin/dircolors ]]; then
    [[ -r ~/.dircolors ]] && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)";
    alias fgrep='fgrep --color=auto';
    alias egrep='egrep --color=auto';
    alias grep='grep --color=auto';
    alias ls='ls --color=auto';
fi

# Enable programmable completion features (you don't need to enable this, if it's
# already enabled in /etc/bash.bashrc and /etc/profile sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
        . /usr/share/bash-completion/bash_completion;
    elif [[ -f /etc/bash_completion ]]; then
        . /etc/bash_completion;
    fi
fi

source $(dirname "${BASH_SOURCE}")/dotfiles.sh;
