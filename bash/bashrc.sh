# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTCONTROL=ignoreboth;
HISTFILESIZE=20000;
HISTSIZE=10000;

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize;
shopt -s histappend;

# Make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)";

# Enable color support of ls and also add handy aliases
if [[ -x /usr/bin/dircolors ]]; then
    [[ -r ~/.dircolors ]] && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)";
    alias fgrep='fgrep --color=auto';
    alias egrep='egrep --color=auto';
    alias  grep='grep --color=auto';
    alias    ls='ls --color=auto';
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

source "${DOTFILES_DIR}/bash/prompt.sh";
source "${DOTFILES_DIR}/dotfiles.sh";
