
function custom-git-prompt()
{
    [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" == "1" ]] && return 0;

    local branch_name=$(git symbolic-ref --short HEAD 2> /dev/null);
    [[ -z "${branch_name}" ]] && return 0;

    local output="%F{green}%B${branch_name}%b%f";
    [[ "${GIT_PROMPT_SHOW_DIRTY}" && ! -z $(git status --porcelain 2>/dev/null) ]] && output+='*';
    echo -ne " ${output}";
}

[[ -z "${DOTFILES_HOST_PROMPT_COLOR}" ]] && DOTFILES_HOST_PROMPT_COLOR='%F{green}';
autoload -U colors && colors;
setopt prompt_subst;

PS1='[%F{magenta}zsh%f %(?..%B%F{red}%?%f%b )%B%F{white}%n%f%b@%f${DOTFILES_HOST_PROMPT_COLOR}%U%m%u%f %F{cyan}%~%f %T$(custom-git-prompt)]
%# ';

