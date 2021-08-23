zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*';
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s;
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s;
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31';
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd';
zstyle ':completion:*' completer _expand _complete _correct _approximate;
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS};
zstyle ':completion:*' auto-description 'specify: %d';
zstyle ':completion:*' format 'Completing %d';
zstyle ':completion:*' special-dirs true;
zstyle ':completion:*' use-compctl false;
zstyle ':completion:*' list-colors '';
zstyle ':completion:*' group-name '';
zstyle ':completion:*' menu select=5;
zstyle ':completion:*' verbose true;

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
    _arguments "1: :($(git remote 2>/dev/null))";
}

compdef _gitb gitb;
_gitb()
{
    _arguments '-c[Branch from current branch instead]';
}
