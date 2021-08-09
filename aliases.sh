[ -x "$(command -v tmux)" ] && alias tm="tmux attach 2>/dev/null || tmux -2u -f '${DF_ROOT_DIR}/config/tmuxrc' new -s '$(whoami)-tmux-session' >/dev/null 2>&1";
[ -x "$(command -v ack)" ] && alias ack='ack -is --ignore-dir=vendor --ignore-dir=.git --ignore-dir=.composer --flush --follow --noenv --ackrc=/dev/null';
[ -x "$(command -v nano)" ] && alias nano='nano --smarthome --tabstospaces --tabsize=4 --autoindent --cut --nowrap --wordbounds --const --linenumbers';
[ -x "$(command -v psysh)" ] && [ ! -x "$(command -v pe)" ] && alias pe='psysh';

if [ -x "$(command -v apt)" ]; then
    alias update='sudo sh -c "apt -y update && sudo apt -y upgrade && sudo apt -y autoclean && sudo apt -y autoremove"';
    alias update-all='update && [ -x "$(command -v snap)" ] && sudo snap refresh || true';
fi

[ -x "$(command -v vim)" ] && alias vim="vim -u '${DF_ROOT_DIR}/config/vimrc.vim'";
[ -x "$(command -v ssh-agent)" ] && alias shq='killall ssh-agent 2>/dev/null';

if [ -x "$(command -v composer)" ]; then
    alias ci='composer install';
    alias cu='composer update';
fi

if [ -x "$(command -v git)" ]; then
    alias masin='git checkout master && { git pull upstream master 2>/dev/null || git pull origin master } && git checkout - && git rebase master';
    alias gcm='git checkout master';
    alias gca='git commit --amend';
    alias grm='git rebase master';
    alias gds='git diff --staged';
    alias gtv='git remote -v';
    alias gc='git checkout';
    alias gap='git add -p';
    alias gt='git remote';
    alias gs='git status';
    alias gr='git rebase';
    alias gb='git branch';
    alias gm='git merge';
    alias gf='git fetch';
    alias gd='git diff';
    alias ga='git add';
    alias g='git';
fi

alias rr='repo_root -c';
alias lsa='ls -lAFhH';
