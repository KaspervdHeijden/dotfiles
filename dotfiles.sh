export SHELL=$(which $(ps -p $$ -o 'comm='));
export LESS="-FXR ${LESS}";
export GIT_EDITOR=vim;
export GIT_PAGER=less;
export EDITOR=vim;
export PAGER=less;

source "${DOTFILES_DIR}/functions.sh";
source "${DOTFILES_DIR}/aliases.sh";

if [ -f ~/.custom_profile ]; then
    source ~/.custom_profile;
fi

