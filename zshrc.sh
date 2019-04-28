
function custom-git-prompt()
{
    [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" == "1" ]] && return 0;

    local branch_name=$(git symbolic-ref --short HEAD 2> /dev/null);
    [[ -z "${branch_name}" ]] && return 0;

    local output="%{$fg_bold[green]${branch_name}%{$reset_color%}";
#    [[ ! -z $(git status --porcelain 2>/dev/null) ]] && output+=' *';
    echo -ne " (${output})";
}

# COMPLETION_WAITING_DOTS=true;
ZSH_THEME='gianu';
if [[ -d "${ZSH}/custom/plugins/zsh-autosuggestions" ]]; then
    plugins=(sudo zsh-autosuggestions);
else
    plugins=(sudo);
fi

[[ -r "${ZSH}/oh-my-zsh.sh" ]] && source "${ZSH}/oh-my-zsh.sh";

PROMPT='[%(?..%B%{$fg[red]%}%?%{$reset_color%}%b )%{$fg_bold[white]%}%n%{$reset_color%}@%{$fg_bold[green]%}%U%m%u%{$reset_color%} %{$fg[cyan]%}%~%{$reset_color%} %{$fg[fg-grey]%}%T%{$reset_color%}$(custom-git-prompt)]
%# ';

source "$(dirname $0)/dotfiles.sh";
