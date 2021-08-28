# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

autoload -Uz compinit && compinit;
autoload -U colors && colors;

bindkey -e;

bindkey -M emacs '^H' backward-delete-word; # Ctrl-Backspace
bindkey -M emacs '^[[1;5D' backward-word;   # Ctrl-Left
bindkey -M emacs '^[[1;5C' forward-word;    # Ctrl-Right
bindkey -M emacs '^[[3;5~' kill-word;       # Ctrl-Del

unsetopt menu_complete;
unsetopt flowcontrol;

setopt prompt_subst;
setopt histignoredups;
setopt appendhistory;
setopt interactivecomments;
setopt auto_menu;
setopt complete_in_word;
setopt always_to_end;

export DF_ROOT_DIR="$(realpath "$(dirname $0)/../../")";
export HISTFILE="${HOME}/.zsh_history";
export HISTSIZE=20000;
export SAVEHIST=20000;

command -v dircolors >/dev/null && eval "$(dircolors -b)";

if [ -d "${ZSH}" ] && [ -r "${ZSH}/oh-my-zsh.sh" ]; then
    export DISABLE_UPDATE_PROMPT=true;
    export UPDATE_ZSH_DAYS=7;
    export plugins=(sudo pass);

    . "${ZSH}/oh-my-zsh.sh";
fi

. "${DF_ROOT_DIR}/shells/zsh/completions.sh";
. "${DF_ROOT_DIR}/shells/zsh/prompt.sh";
. "${DF_ROOT_DIR}/dotfiles.sh";

if [ -f "${DF_ROOT_DIR}/plugins/zsh.sh" ]; then
    . "${DF_ROOT_DIR}/plugins/zsh.sh";
fi
