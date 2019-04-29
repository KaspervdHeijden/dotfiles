export SHELL=$(which $(ps -p $$ -o 'comm='));
export GIT_PAGER=more;
export EDITOR=nano;

if [[ ! -z "${BASH_SOURCE}" ]]; then
    export DOTFILES_DIR=$(dirname "${BASH_SOURCE}");
else
    export DOTFILES_DIR=$(dirname $0);
fi

source "${DOTFILES_DIR}/functions.sh";
source "${DOTFILES_DIR}/aliases.sh";

[[ -d "${DOTFILES_DEFAULT_STARTDIR}" ]] && cd "${DOTFILES_DEFAULT_STARTDIR}" || cd;
