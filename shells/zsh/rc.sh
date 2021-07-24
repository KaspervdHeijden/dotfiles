# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

setopt prompt_subst histignoredups appendhistory interactivecomments;

autoload -Uz compinit && compinit;
autoload -U colors && colors;

bindkey -e;

export DF_ROOT_DIR="$(realpath "$(dirname $0)/../../")";
export HISTFILE="${HOME}/.zsh_history";
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

    for plugin in 'zsh-autosuggestions' 'zsh-syntax-highlighting'; do
        if [ -d "${ZSH}/custom/plugins/${plugin}" ]; then
            plugins+=($plugin);
        fi
    done

    export DISABLE_UPDATE_PROMPT='1';
    export UPDATE_ZSH_DAYS='7';

    . "${ZSH}/oh-my-zsh.sh";
fi

. "${DF_ROOT_DIR}/shells/zsh/prompt.sh";
. "${DF_ROOT_DIR}/dotfiles.sh";

compdef _dfs dfs;
_dfs()
{
    _arguments '1: :(env install nav reload update)';
}

compdef _repo_root repo_root;
_repo_root()
{
    _arguments '-c[Only display root directory]';
}

compdef _cds cds;
_cds()
{
    if [ "${DF_CDS_COMPLETE_FULL_PATHS:-0}" -eq 0 ]; then
        _arguments "1: :($(cds | xargs -I {} basename {} | xargs))";
    else
        _arguments "1: :($(cds | xargs))";
    fi
}

compdef _gitl gitl;
_gitl()
{
    _arguments "1: :($(git remote))";
}

compdef _gitb gitb;
_gitb()
{
    local current_branch=$(git symbolic-ref --short HEAD 2>/dev/null);
    _arguments "-c[Branch from current '${current_branch}' instead]";
}
