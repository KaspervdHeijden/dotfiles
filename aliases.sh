
alias tm="tmux attach -f ${DOTFILES_DIR}/tmux.conf 2> /dev/null || tmux -f ${DOTFILES_DIR}/tmux.conf new > /dev/null 2> /dev/null";
alias shq="ps waux | grep ssh | grep -v grep | awk '{print $2}' | uniq | xargs -r kill";

[[ $(which docker-comper) ]] && alias dc='docker-compose';
alias shl='ssh -A vanderheijdenk@10.103.9.20';
alias dev='ssh -A vanderheijdenk@10.4.177.1';

[[ $(which psysh) ]] && alias pe='psysh';
alias lsa='ls -lAFh --color=auto';
alias gc='git checkout';
alias gs='git status';
alias rr='repo-root';
alias gd='git diff';
alias ga='git add';
alias gitc='gitt';
alias g='git';
