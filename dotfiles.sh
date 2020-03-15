export SHELL=$(getent passwd "${USER}" | cut -d':' -f7);
export LESS="-FXR ${LESS}";
export GIT_EDITOR=vim;
export GIT_PAGER=less;
export EDITOR=vim;
export PAGER=less;

. "${DOTFILES_DIR}/functions.sh";
. "${DOTFILES_DIR}/aliases.sh";

[ -x "$(command -v neofetch)" ] && neofetch -cpu_temp C --kernel_shorthand off --distro_shorthand off  --memory_percent on;

[ -f "${HOME}/.config/dotfiles/config.sh" ] && . "${HOME}/.config/dotfiles/config.sh" || true;

