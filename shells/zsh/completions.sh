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
