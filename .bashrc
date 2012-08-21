shopt -s extglob globstar

HISTCONTROL=ignoredups

alias l='ls --color=auto'
alias g='grep --color=auto'
alias v='l -laFh'
if type -p sudo >/dev/null 2>&1; then
    alias s='sudo -i'
else
    alias s='su -'
fi
alias sprunge='curl -F "sprunge=<-" http://sprunge.us'

PS1='\h:\W\$ '
