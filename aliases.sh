[[ -x "$(which psysh)" && ! -x "$(which pe)" ]] && alias pe='psysh';
[[ -x "$(which docker-comper)" ]] && alias dc='docker-compose';

alias tm="tmux attach -f ${DOTFILES_DIR}/tmux.conf 2> /dev/null || tmux -f ${DOTFILES_DIR}/tmux.conf new > /dev/null 2> /dev/null";
alias nano='nano --smarthome --tabstospaces --morespace --smooth --tabsize=4 --autoindent --cut --nowrap --wordbounds --const';
alias vim="vim -u ${DOTFILES_DIR}/vimrc";

alias gcb='git checkout -b';
alias gc='git checkout';
alias gap='git add -p';
alias gs='git status';
alias gr='git rebase';
alias gb='git branch';
alias gm='git merge';
alias gd='git diff';
alias gp='git push';
alias ga='git add';
alias g='git';

alias rr='repo-root';
alias lsa='ls -lAFh';
alias gitc='gitt';
alias h='history';
alias ..='cd ..';
alias c='clear';

