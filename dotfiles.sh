export LESS="-FXR ${LESS}";
export GIT_EDITOR=vim;
export GIT_PAGER=less;
export EDITOR=vim;
export PAGER=less;

. "${DF_ROOT_DIR}/functions.sh";
. "${DF_ROOT_DIR}/aliases.sh";

[ -f "${HOME}/.config/dotfiles/config.sh" ] && . "${HOME}/.config/dotfiles/config.sh";
awk -v current_period="$(date +'%m-%d')" '$2 == current_period { print "Birthday today " $1 "!"}' "$([ -f "${DF_BIRTHDAYS_FILE}" ] && echo "${DF_BIRTHDAYS_FILE}" || echo '/dev/null')";
