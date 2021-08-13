complete -W 'env install nav reload update' dfs;
complete -F _cds cds;

_cds()
{
    if [ "${DF_CDS_COMPLETE_FULL_PATHS:-0}" -eq 0 ]; then
        COMPREPLY=($(compgen -W "$(cds | xargs -I{} basename {} | xargs)" -- "${COMP_WORDS[$COMP_CWORD]}"));
    else
        COMPREPLY=($(compgen -W "$(cds | xargs)" -- "${COMP_WORDS[$COMP_CWORD]}"));
    fi
}
