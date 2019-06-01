[[ -x "$(which psysh)" && ! -x "$(which pe)" ]] && alias pe='psysh';
[[ -x "$(which docker-compose)" ]] && alias dc='docker-compose';

alias tm="tmux attach -f ${DOTFILES_DIR}/tmux.conf 2> /dev/null || tmux -f ${DOTFILES_DIR}/tmux.conf new > /dev/null 2> /dev/null";
alias nano='nano --smarthome --tabstospaces --morespace --smooth --tabsize=4 --autoindent --cut --nowrap --wordbounds --const';
alias ack='ack -s --ignore-dir=vendor --ignore-dir=.git --ignore-dir=.composer --flush --follow --noenv --ackrc=/dev/null';
alias vim="vim -u ${DOTFILES_DIR}/vimrc";
alias shq='killall ssh-agent';

alias gcm='git checkout master';
alias gca='git commit --amend';
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
alias c='clear';

alias ...='cd ../..';
alias ..='cd ..';

1='cd -';
2='cd -2';
3='cd -3';
4='cd -4';
5='cd -5';
6='cd -6';
7='cd -7';
8='cd -8';
9='cd -9';
