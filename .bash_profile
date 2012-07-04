[[ -r ~/.bashrc ]] && . ~/.bashrc

export EDITOR=vim
export LESS="-X -S"
export LESSSECURE=1
export PAGER=less
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

eval $(ssh-agent)
ssh-add
