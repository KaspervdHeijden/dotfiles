export SHELL=$(getent passwd "${USER}" | cut -d':' -f7);
export LESS="-FXR ${LESS}";
export GIT_EDITOR=vim;
export GIT_PAGER=less;
export EDITOR=vim;
export PAGER=less;

. "${DOTFILES_DIR}/functions.sh";
. "${DOTFILES_DIR}/aliases.sh";

if [ -f ~/.custom_profile ]; then
    . ~/.custom_profile;
fi

