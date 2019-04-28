
function custom-git-prompt()
{
    [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" == "1" ]] && return 0;

    local branch_name=$(git symbolic-ref --short HEAD 2> /dev/null);
    [[ -z "${branch_name}" ]] && return 0;

    local output="%{$fg_bold[green]${branch_name}%{$reset_color%}";
    [[ "${GIT_PROMPT_SHOW_DIRTY}" && ! -z $(git status --porcelain 2>/dev/null) ]] && output+='*';
    echo -ne " ${output}";
}

PROMPT='[%{$fg[magenta]%}zsh%{$reset_color%} %(?..%B%{$fg[red]%}%?%{$reset_color%}%b )%{$fg_bold[white]%}%n%{$reset_color%}@%{$fg_bold[green]%}%U%m%u%{$reset_color%} %{$fg[cyan]%}%~%{$reset_color%} %{$fg[fg-grey]%}%T%{$reset_color%}$(custom-git-prompt)]
%# ';
