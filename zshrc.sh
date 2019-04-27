export ZSH="$(echo ~)/.oh-my-zsh";

plugins=(sudo zsh-autosuggestions);
COMPLETION_WAITING_DOTS="true";
ZSH_THEME="gianu";

function custom_zsh_git_prompt_info()
{
    if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" == "1" ]]; then
        return;
    fi

    local branch_name=$(git symbolic-ref --short HEAD 2> /dev/null);
    if [[ -z "${branch_name}" ]]; then
        return 0;
    fi

    local changes=$(git status --porcelain 2>/dev/null | wc -l);
    local output=' [';

    if [[ "${changes}" -gt 0 ]]; then
        output+='* ';
    fi

    output+="%{$fg_bold[green]${branch_name}%{$reset_color%}";
    if [[ "${changes}" -gt 0 ]]; then
        output+="(%{$fg[yellow]%}${changes}%{$reset_color%})";
    fi

    echo -n "${output}]";
}


source "${ZSH}/oh-my-zsh.sh";
PROMPT='%{$fg_bold[white]%}%n%{$reset_color%}@%{$fg_bold[red]%}%m%{$reset_color%} %{$fg[cyan]%}%~%{$reset_color%}%(?.. [!%B%{$fg[red]%}%?%{$reset_color%}%b]) [%{$fg[fg-grey]%}%T%{$reset_color%}]$(custom_zsh_git_prompt_info)
 %# ';

source "$(dirname $0)/dotfiles.sh";
