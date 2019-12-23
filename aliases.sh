[ -x "$(which tmux)" ] &&alias tm="tmux attach 2> /dev/null || tmux -2u -f ${DOTFILES_DIR}/tmux.conf new -s $(whoami)-tmux-session > /dev/null 2> /dev/null";
[ -x "$(which nano)" ] && alias nano='nano --smarthome --tabstospaces --morespace --smooth --tabsize=4 --autoindent --cut --nowrap --wordbounds --const';
[ -x "$(which ack)" ] && alias ack='ack -is --ignore-dir=vendor --ignore-dir=.git --ignore-dir=.composer --flush --follow --noenv --ackrc=/dev/null';
[ -x "$(which psysh)" -a ! -x "$(which pe)" ] && alias pe='psysh';

alias shq='killall ssh-agent 2>/dev/null';
alias vim="vim -u ${DOTFILES_DIR}/vimrc";
alias hlp='declare -f';


if [ -x "$(which docker-compose)" ]; then
   alias dcu='docker-compose up -d';
   alias dce='docker compose exec';
   alias dc='docker-compose';
fi

if [ -x "$(which composer)" ]; then
    alias ci='composer install --ignore-platform-reqs';
    alias cu='composer update --ignore-platform-reqs';
fi

if [ -x "$(which git)" ]; then
    alias gcm='git checkout master';
    alias gca='git commit --amend';
    alias grm='git rebase master';
    alias gcb='git checkout -b';
    alias gc='git checkout';
    alias gap='git add -p';
    alias gs='git status';
    alias gr='git rebase';
    alias gb='git branch';
    alias gt='git remote';
    alias gm='git merge';
    alias gf='git fetch';
    alias gd='git diff';
    alias gp='git push';
    alias ga='git add';
    alias g='git';
fi

alias rr='repo-root';
alias lsa='ls -lAFh';
alias h='history';
alias c='clear';

alias ...='cd ../..';
alias ..='cd ..';
alias 1='cd -';
alias 2='cd -2';
alias 3='cd -3';
