#!/usr/bin/env false

command -v apt >/dev/null && alias update='sudo sh -c "apt -y update && apt -y upgrade && apt -y autoclean && apt -y autoremove && { command -v snap >/dev/null && snap refresh || true; } && { command -v flatpack >/dev/null && flatpack update || true; }"';
command -v pacman >/dev/null && alias update='sudo sh -c "pacman -Syu && { command -v snap >/dev/null && snap refresh || true; } && { command -v flatpack >/dev/null && flatpack update || true; }"';
command -v ssh-agent >/dev/null && alias shq='killall ssh-agent 2>/dev/null';

alias tm="tmux attach 2>/dev/null || tmux -2u -f '${DF_ROOT_DIR}/config/tmux.rc' new -s '$(whoami)-tmux-session' >/dev/null 2>&1";
alias ack='ack -is --ignore-dir=vendor --ignore-dir=.git --ignore-dir=.composer --flush --follow --noenv --ackrc=/dev/null';
alias nano='nano --smarthome --tabstospaces --tabsize=4 --autoindent --cut --nowrap --wordbounds --const --linenumbers';
alias grep='grep --color=auto --exclude-dir=vendor --exclude-dir=.git --exclude-dir=.composer';
alias vim="vim -u '${DF_ROOT_DIR}/config/vimrc.vim'";

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

alias ci='composer install';
alias cu='composer update';

alias rr='cd "$(repo_root)"';
alias lsa='ls -lAFhH';
