#!/bin/bash

[[ -r ~/.bashrc ]] && . ~/.bashrc

export EDITOR=vim
export LANG=en_GB.utf8
export LESS="-X -S"
export LESSSECURE=1
export PAGER=less
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

if ! [[ $SSH_CLIENT ]] && (( EUID )) && ! pgrep -u "$EUID" -x ssh-agent; then
    ssh-agent > ~/.ssh-agent
    ssh-add
fi

[[ -r ~/.ssh-agent ]] && . ~/.ssh-agent
