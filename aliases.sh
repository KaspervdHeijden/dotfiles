[ -x "$(command -v tmux)" ] && alias tm="tmux attach 2>/dev/null || tmux -2u -f '${DOTFILES_DIR}/config/tmux.conf' new -s '$(whoami)-tmux-session' >/dev/null 2>/dev/null";
[ -x "$(command -v nano)" ] && alias nano='nano --smarthome --tabstospaces --morespace --smooth --tabsize=4 --autoindent --cut --nowrap --wordbounds --const';
[ -x "$(command -v ack)" ] && alias ack='ack -is --ignore-dir=vendor --ignore-dir=.git --ignore-dir=.composer --flush --follow --noenv --ackrc=/dev/null';
[ -x "$(command -v psysh)" ] && [ ! -x "$(command -v pe)" ] && alias pe='psysh';


alias update='sudo apt -y update && sudo apt -y upgrade && sudo apt -y autoremove';
alias vim="vim -u '${DOTFILES_DIR}/config/vim.conf'";
alias shq='killall ssh-agent 2>/dev/null';

if [ -x "$(command -v docker-compose)" ]; then
   alias dcu='docker-compose up -d';
   alias dce='docker compose exec';
   alias dc='docker-compose';
fi

if [ -x "$(command -v composer)" ]; then
    alias ci='composer install --ignore-platform-reqs';
    alias cu='composer update --ignore-platform-reqs';
fi

if [ -x "$(command -v git)" ]; then
    alias gcm='git checkout master';
    alias gca='git commit --amend';
    alias grm='git rebase master';
    alias gds='git diff --staged';
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

alias rr='repo_root && cd $(repo_root)';
alias lsa='ls -lAFh';

