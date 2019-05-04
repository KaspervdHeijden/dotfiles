if [[ -d "${ZSH}" && -r "${ZSH}/oh-my-zsh.sh" ]]; then
    if [[ -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]]; then
        plugins=(sudo zsh-autosuggestions);
    else
        plugins=(sudo);
    fi

    source "${ZSH}/oh-my-zsh.sh";
fi

export UPDATE_ZSH_DAYS=13;

autoload -Uz compinit;
compinit;

zstyle ':completion:*' menu select;

source "$(dirname $0)/prompt.sh";
source "$(dirname $0)/../dotfiles.sh";
