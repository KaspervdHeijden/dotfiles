dotfiles_prompt_last_exitcode()
{
    local latest_exitcode="${?}";
    [ "${latest_exitcode}" -eq "0" ] && return 0;
    echo -ne "\033[1;31m${latest_exitcode}\033[0;00m ";
}

dotfiles_prompt_git_status()
{
    local output=$(git symbolic-ref --short HEAD 2>/dev/null);
    [ -z "${output}" ] && return 0;

    [ "${GIT_PROMPT_SHOW_DIRTY}" ] && [ -n "$(git status --porcelain 2>/dev/null)" ] && output="${output}*";
    echo -ne " ${output}";
}

[ -z "${DOTFILES_HOST_PROMPT_COLOR_BASH}" ] && DOTFILES_HOST_PROMPT_COLOR_BASH='1;4;32';
PS1="[\$(dotfiles_prompt_last_exitcode)\e[1;37m\u\e[0;37m@\e[${DOTFILES_HOST_PROMPT_COLOR_BASH}m\h\e[0;36m \w\e[0m \$(date +'%H:%M')\e[1;32m\$(dotfiles_prompt_git_status)\e[0;0m]\n% ";

