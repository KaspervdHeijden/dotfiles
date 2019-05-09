[[ -x "$(which psysh)" && ! -x "$(which pe)" ]] && alias pe='psysh';
[[ -x "$(which docker-comper)" ]] && alias dc='docker-compose';

alias nn="$(which nano) --smarthome --tabstospaces --morespace --smooth --tabsize=4 --autoindent --cut --nowrap --wordbounds --const";
alias tm="tmux attach -f ${DOTFILES_DIR}/tmux.conf 2> /dev/null || tmux -f ${DOTFILES_DIR}/tmux.conf new > /dev/null 2> /dev/null";
alias vim="vim -u ${DOTFILES_DIR}/vimrc.conf";

alias gc='git checkout';
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
alias cls='clear';
alias ..='cd ..';

