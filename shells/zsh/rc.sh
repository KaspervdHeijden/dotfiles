#!/usr/bin/env false

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

autoload -Uz compinit && compinit;
autoload -U colors && colors;

bindkey -e;

bindkey -M emacs "${terminfo[kcbt]}" reverse-menu-complete  # Shift+Tab: move through completion menu backwards
bindkey -M emacs '^H' backward-delete-word;                 # Ctrl+Backspace: delete word backwards
bindkey -M emacs '^[[1;5D' backward-word;                   # Ctrl+Left: move word backwards
bindkey -M emacs '^[[1;5C' forward-word;                    # Ctrl+Right: move word forwards
bindkey -M emacs '^[[3;5~' kill-word;                       # Ctrl+Del: delete word forwards
bindkey  "^[[3~"  delete-char;                              # Delete key deletes char

bindkey -M emacs '^[[H' beginning-of-line;
bindkey -M emacs '^[[F' end-of-line;

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
export HISTSIZE=50000;
export SAVEHIST=50000;

command -v dircolors >/dev/null && eval "$(dircolors -b)";

if [ -d "${ZSH}" ] && [ -r "${ZSH}/oh-my-zsh.sh" ]; then
    export DISABLE_UPDATE_PROMPT=true;
    export UPDATE_ZSH_DAYS=7;
    export plugins=(sudo);

    . "${ZSH}/oh-my-zsh.sh";
fi

. "${DF_ROOT_DIR}/shells/zsh/completions.sh";
. "${DF_ROOT_DIR}/shells/zsh/prompt.sh";
. "${DF_ROOT_DIR}/dotfiles.sh";

if [ -f "${DF_ROOT_DIR}/plugins/zsh.sh" ]; then
    . "${DF_ROOT_DIR}/plugins/zsh.sh";
fi
