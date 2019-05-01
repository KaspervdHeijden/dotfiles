export SHELL=$(which $(ps -p $$ -o 'comm='));
export GIT_PAGER=more;
export EDITOR=nano;
export PAGER=less;

if [[ ! -z "${BASH_SOURCE}" ]]; then
    export DOTFILES_DIR=$(dirname "${BASH_SOURCE}");
else
    export DOTFILES_DIR=$(dirname $0);
fi

source "${DOTFILES_DIR}/functions.sh";
source "${DOTFILES_DIR}/aliases.sh";

[[ -f ~/.custom_profile ]] && source ~/.custom_profile;
