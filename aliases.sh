[[ -x "$(which psysh)" && ! -x "$(which pe)" ]] && alias pe='psysh';
[[ -x "$(which docker-comper)" ]] && alias dc='docker-compose';

alias nn="$(which nano) --smarthome --tabstospaces --morespace --restricted --smooth --tabsize=4 --autoindent --cut --nowrap --wordbounds --const";
alias tm="tmux attach -f ${DOTFILES_DIR}/tmux.conf 2> /dev/null || tmux -f ${DOTFILES_DIR}/tmux.conf new > /dev/null 2> /dev/null";
alias shq="ps waux | grep ssh | grep -v grep | awk '{print $2}' | uniq | xargs -r kill";

alias gc='git checkout';
alias gs='git status';
alias gr='git rebase';
alias gm='git merge';
alias gd='git diff';
alias gp='git push';
alias ga='git add';
alias g='git';

alias lsa='ls -lAFh --color';
alias rr='repo-root';
alias gitc='gitt';
alias cls='clear';
