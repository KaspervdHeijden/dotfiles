export LESS="-FXR ${LESS}";
export GIT_EDITOR=vim;
export GIT_PAGER=less;
export EDITOR=vim;
export PAGER=less;

. "${DF_ROOT_DIR}/functions.sh";
. "${DF_ROOT_DIR}/aliases.sh";

if [ -f "${HOME}/.config/dotfiles/config.sh" ]; then
    . "${HOME}/.config/dotfiles/config.sh";
fi
