[[ -x "$(which docker-comper)" ]] && alias dc='docker-compose';
[[ -x "$(which psysh)" ]] && alias pe='psysh';

alias tm="tmux attach -f ${DOTFILES_DIR}/tmux.conf 2> /dev/null || tmux -f ${DOTFILES_DIR}/tmux.conf new > /dev/null 2> /dev/null";
alias shq="ps waux | grep ssh | grep -v grep | awk '{print $2}' | uniq | xargs -r kill";
alias lsa='ls -lAFh --color=auto';
alias gc='git checkout';
alias gs='git status';
alias rr='repo-root';
alias gd='git diff';
alias ga='git add';
alias gitc='gitt';
alias g='git';
