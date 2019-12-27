setopt prompt_subst histignoredups appendhistory interactivecomments;

autoload -Uz compinit && compinit;
autoload -U colors && colors;

export HISTFILE=~/.zsh_history;
export HISTSIZE=20000;
export SAVEHIST=20000;

[ -x "$(command -v dircolors)" ] && eval "$(dircolors -b)";

zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*';
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s;
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s;
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31';
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd';
zstyle ':completion:*' completer _expand _complete _correct _approximate;
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS};
zstyle ':completion:*' auto-description 'specify: %d';
zstyle ':completion:*' format 'Completing %d';
zstyle ':completion:*' use-compctl false;
zstyle ':completion:*' list-colors '';
zstyle ':completion:*' group-name '';
zstyle ':completion:*' menu select=2;
zstyle ':completion:*' verbose true;

if [ -d "${ZSH}" ] && [ -r "${ZSH}/oh-my-zsh.sh" ]; then
    plugins=(sudo pass);

    for plugin in "zsh-autosuggestions" "zsh-syntax-highlighting"; do
        if [ -d "${ZSH}/custom/plugins/${plugin}" ]; then
            plugins+=($plugin);
        fi
    done

    export DISABLE_UPDATE_PROMPT="true";
    export UPDATE_ZSH_DAYS=7;

    . "${ZSH}/oh-my-zsh.sh";
fi

. "${DOTFILES_DIR}/zsh/prompt.sh";
. "${DOTFILES_DIR}/dotfiles.sh";

