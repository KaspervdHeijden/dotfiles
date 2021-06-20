export LESS="-FXR ${LESS}";
export GIT_EDITOR=vim;
export GIT_PAGER=less;
export EDITOR=vim;
export PAGER=less;

. "${DOTFILES_DIR}/functions.sh";
. "${DOTFILES_DIR}/aliases.sh";

[ "${DF_SHOW_NEOFETCH}" ] && [ -x "$(command -v neofetch)" ] && neofetch --cpu_temp C --kernel_shorthand off --distro_shorthand off --memory_percent on;

if [ -f "${HOME}/.config/dotfiles/config.sh" ]; then
    . "${HOME}/.config/dotfiles/config.sh";
fi

