export LESS="-FXR ${LESS}";
export GIT_EDITOR=vim;
export GIT_PAGER=less;
export EDITOR=vim;
export PAGER=less;

. "${DF_ROOT_DIR}/functions.sh";
. "${DF_ROOT_DIR}/aliases.sh";

[ -f "${HOME}/.config/dotfiles/config.sh" ] && . "${HOME}/.config/dotfiles/config.sh";

if [ -f "${DF_BIRTHDAYS_FILE}" ]; then
    awk -v day="$(date +'%m-%d')" '$1 == day { print "!! birthday " $2 " today: " $3; print ""; }' "${DF_BIRTHDAYS_FILE}";
fi
