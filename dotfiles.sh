
export SHELL=$(which $(ps -p $$ -o 'comm='));
export GIT_PAGER=more;
export EDITOR=nano;
export PAGER=less;

source "${DOTFILES_DIR}/functions.sh";
source "${DOTFILES_DIR}/aliases.sh";

[[ -f ~/.custom_profile ]] && source ~/.custom_profile;
