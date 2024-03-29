#!/usr/bin/env false

if command -v vim >/dev/null; then
    export GIT_EDITOR=vim;
    export EDITOR=vim;
else
    export GIT_EDITOR=nano;
    export EDITOR=nano;
fi

export LESS="-FXR ${LESS}";
export TERM=xterm-256color;
export GIT_PAGER=less;
export PAGER=less;

. "${DF_ROOT_DIR}/functions.sh";
. "${DF_ROOT_DIR}/aliases.sh";

if [ -f "${HOME}/.config/dotfiles/config.sh" ]; then
    . "${HOME}/.config/dotfiles/config.sh";
fi
