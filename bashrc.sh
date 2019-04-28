# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTCONTROL=ignoreboth;
shopt -s histappend;
HISTFILESIZE=20000;
HISTSIZE=10000;

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize;

# Make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)";


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


function __prompt_last_exitcode_info()
{
    local latest_exitcode="${?}";
    [[ "${latest_exitcode}" == '0' ]] && return 0;
    echo -ne "\033[1;31m${latest_exitcode}\033[0;00m ";
}

function __prompt_git_info()
{
    local branch_name=$(git symbolic-ref --short HEAD 2>/dev/null);
    [[ -z "${branch_name}" ]] && return 0;
    echo -ne " ${branch_name}";
}

PS1="[\$(__prompt_last_exitcode_info)\e[1;37m\u\e[0;37m@\e[1;4;32m\h\e[0;36m \w\e[0m \$(date +'%H:%M')\e[1;32m\$(__prompt_git_info)\e[0;0m]\n% ";

source $(dirname "${BASH_SOURCE}")/dotfiles.sh;
