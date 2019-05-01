if [[ -d "${ZSH}" ]]; then
    ZSH_THEME='gianu';
    if [[ -d "${ZSH}/custom/plugins/zsh-autosuggestions" ]]; then
        plugins=(sudo zsh-autosuggestions);
    else
        plugins=(sudo);
    fi

    [[ -r "${ZSH}/oh-my-zsh.sh" ]] && source "${ZSH}/oh-my-zsh.sh";
fi

autoload -Uz compinit;
compinit;

zstyle ':completion:*' menu select;

source "$(dirname $0)/prompt.sh";
source "$(dirname $0)/../dotfiles.sh";
