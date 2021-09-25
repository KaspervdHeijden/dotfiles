#!/usr/bin/env false

complete -W 'env install nav reload update' dfs;
complete -W '-c' repo_root;
complete -W '-c' gitb;
complete -F _cds cds;

_cds()
{
    if [ "${DF_CDS_COMPLETE_FULL_PATHS:-0}" -eq 0 ]; then
        COMPREPLY=($(compgen -W "$(cds | xargs -I{} basename {} | xargs)" -- "${COMP_WORDS[$COMP_CWORD]}"));
    else
        COMPREPLY=($(compgen -W "$(cds | xargs)" -- "${COMP_WORDS[$COMP_CWORD]}"));
    fi
}

complete -F _gitl gitl;
_gitl()
{
    COMPRELY=($(compgen -W "$(git remote 2>/dev/null)" -- "${COMP_WORDS[$COMP_CWORD]}"));
}
