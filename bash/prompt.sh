function __prompt_last_exitcode_info()
{
    local latest_exitcode="${?}";
    [[ "${latest_exitcode}" == '0' ]] && return 0;
    echo -ne "\033[1;31m${latest_exitcode}\033[0;00m ";
}

function __prompt_git_info()
{
    local output=$(git symbolic-ref --short HEAD 2>/dev/null);
    [[ -z "${output}" ]] && return 0;
    [[ "${GIT_PROMPT_SHOW_DIRTY}" && $(git status --porcelain 2> /dev/null) ]] && output+='*';
    echo -ne " ${output}";
}

[[ -z "${DOTFILES_HOST_PROMPT_COLOR}" ]] && DOTFILES_HOST_PROMPT_COLOR='1;4;32';
PS1="[\$(__prompt_last_exitcode_info)\e[1;37m\u\e[0;37m@\e[${DOTFILES_HOST_PROMPT_COLOR}m\h\e[0;36m \w\e[0m \$(date +'%H:%M')\e[1;32m\$(__prompt_git_info)\e[0;0m]\n% ";
