
zstyle ':completion:*' menu select;
autoload -Uz compinit;
compinit;

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
