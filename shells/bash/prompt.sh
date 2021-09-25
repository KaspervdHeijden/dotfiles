#!/usr/bin/env false

__df_prompt_last_exitcode()
{
    local latest_exitcode="${?}";
    [ "${latest_exitcode}" -eq "0" ] && return 0;
    echo -ne "\033[1;31m${latest_exitcode}\033[0;00m ";
}

__df_prompt_git_status()
{
    local output="$(git symbolic-ref --short HEAD 2>/dev/null)";
    [ -z "${output}" ] && return 0;

    [ "${DF_GIT_PROMPT_SHOW_DIRTY}" ] && [ -n "$(git status -uno --porcelain 2>/dev/null)" ] && output="${output}*";
    echo -ne " ${output}";
}

[ -z "${DF_HOST_PROMPT_COLOR_BASH}" ] && DF_HOST_PROMPT_COLOR_BASH='4;32';
PS1="[\$(__df_prompt_last_exitcode)\e[1;37m\u\e[0;37m@\e[${DF_HOST_PROMPT_COLOR_BASH}m\h\e[0m \e[0;33mbash\e[0m \$(uname -s)\e[0;36m \w\e[0m \$(date +'%Y-%m-%d %H:%M')\e[1;32m\$(__df_prompt_git_status)\e[0;0m]\n% ";
