__df_prompt_git_status()
{
    [ "$(git config --get oh-my-zsh.hide-status 1>/dev/null)" = "1" ] && return 0;

    local branch_name=$(git symbolic-ref --short HEAD 2>/dev/null);
    [ -z "${branch_name}" ] && return 0;

    local output="%F{green}%B${branch_name}%b%f";
    [ "${DF_GIT_PROMPT_SHOW_DIRTY}" ] && [ -n "$(git status -uno --porcelain 2>/dev/null)" ] && output="${output}*";
    echo -ne " ${output}";
}

[ -z "${DF_HOST_PROMPT_COLOR_ZSH}" ] && DF_HOST_PROMPT_COLOR_ZSH='%F{green}';
PS1='[%(?..%B%F{red}%?%f%b )%B%F{white}%n%f%b@%f${DF_HOST_PROMPT_COLOR_ZSH}%U%m%u%f %F{cyan}%~%f %D{%Y-%m-%d} %T$(__df_prompt_git_status)]
%# ';

