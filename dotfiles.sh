export SHELL=$(which $(ps -p $$ -o 'comm='));
export LESS="-F -X ${LESS}";
export GIT_PAGER=less;
export EDITOR=vim;
export PAGER=less;

source "${DOTFILES_DIR}/functions.sh";
source "${DOTFILES_DIR}/aliases.sh";

[[ -f ~/.custom_profile ]] && source ~/.custom_profile;

# Clear any non zero exit codes
true;

