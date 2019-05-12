setopt histignoredups appendhistory;

autoload -Uz compinit;
compinit;

HISTFILE=~/.zsh_history;
HISTSIZE=1000;
SAVEHIST=1000;

zstyle ':completion:*' auto-description 'specify: %d';
zstyle ':completion:*' completer _expand _complete _correct _approximate;
zstyle ':completion:*' format 'Completing %d';
zstyle ':completion:*' group-name '';
zstyle ':completion:*' menu select=2;
eval "$(dircolors -b)";
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS};
zstyle ':completion:*' list-colors '';
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s;
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*';
zstyle ':completion:*' menu select;
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s;
zstyle ':completion:*' use-compctl false;
zstyle ':completion:*' verbose true;

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31';
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd';


if [[ -d "${ZSH}" && -r "${ZSH}/oh-my-zsh.sh" ]]; then
    if [[ ! -z "${ZSH_CUSTOM}" && -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]]; then
        plugins=(sudo zsh-autosuggestions);
    elif [[ -d "${ZSH}/custom/plugins/zsh-autosuggestions" ]]; then
        plugins=(sudo zsh-autosuggestions);
    else
        plugins=(sudo);
    fi

    export DISABLE_UPDATE_PROMPT=true;
    source "${ZSH}/oh-my-zsh.sh";
fi

source "${DOTFILES_DIR}/zsh/prompt.sh";
source "${DOTFILES_DIR}/dotfiles.sh";

