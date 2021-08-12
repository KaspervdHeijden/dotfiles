command -v apt >/dev/null && alias update='sudo sh -c "apt -y update && apt -y upgrade && apt -y autoclean && apt -y autoremove && { command -v snap >/dev/null && snap refresh || true; }"';
command -v tmux >/dev/null && alias tm="tmux attach 2>/dev/null || tmux -2u -f '${DF_ROOT_DIR}/config/tmuxrc.rc' new -s '$(whoami)-tmux-session' >/dev/null 2>&1";
command -v ack >/dev/null && alias ack='ack -is --ignore-dir=vendor --ignore-dir=.git --ignore-dir=.composer --flush --follow --noenv --ackrc=/dev/null';
command -v nano >/dev/null && alias nano='nano --smarthome --tabstospaces --tabsize=4 --autoindent --cut --nowrap --wordbounds --const --linenumbers';
command -v vim >/dev/null && alias vim="vim -u '${DF_ROOT_DIR}/config/vimrc.vim'";
command -v psysh >/dev/null && { command -v pe >/dev/null || alias pe='psysh'; }
command -v ssh-agent >/dev/null && alias shq='killall ssh-agent 2>/dev/null';

if command -v composer >/dev/null; then
    alias ci='composer install';
    alias cu='composer update';
fi

if command -v git >/dev/null; then
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
