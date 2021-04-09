export SHELL=$(getent passwd "${USER}" | cut -d':' -f7);
export LESS="-FXR ${LESS}";
export GIT_EDITOR=vim;
export GIT_PAGER=less;
export EDITOR=vim;
export PAGER=less;

source "${DOTFILES_DIR}/functions.sh";
source "${DOTFILES_DIR}/aliases.sh";

[ -x "$(command -v neofetch)" ] && neofetch -cpu_temp C --kernel_shorthand off --distro_shorthand off --memory_percent on;

if [ -f "${HOME}/.config/dotfiles/config.sh" ]; then
    source "${HOME}/.config/dotfiles/config.sh";
fi

