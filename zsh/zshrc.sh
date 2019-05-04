if [[ -d "${ZSH}" && -r "${ZSH}/oh-my-zsh.sh" ]]; then
    if [[ -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]]; then
        plugins=(sudo zsh-autosuggestions);
    else
        plugins=(sudo);
    fi

    source "${ZSH}/oh-my-zsh.sh";
fi

export UPDATE_ZSH_DAYS=7;

autoload -Uz compinit;
compinit;

zstyle ':completion:*' menu select;

source "${DOTFILES_DIR}/zsh/prompt.sh";
source "${DOTFILES_DIR}/dotfiles.sh";
