#!/bin/bash

shopt -s dotglob nullglob globstar

getLocale() {
    local localesDesired \
          localeDesired \
          localeAvailable

    localesDesired=({en_{GB,US},C}.{utf8,UTF-8}) 
    unset LANG
    while IFS= read -r localeAvailable; do
        localesAvailable+=( "$localeAvailable" )
    done < <(locale -a)
    for localeDesired in "${localesDesired[@]}"; do
        for localeAvailable in "${localesAvailable[@]}"; do
            if [[ $localeAvailable == "$localeDesired" ]]; then
                LANG=$localeAvailable
                break 2
            fi
        done
    done
    : ${LANG:=C}
}

runSSHAgent() {
    if pgrep -u "$EUID" -x ssh-agent && [[ -f ~/.ssh-agent ]]; then
        . ~/.ssh-agent
    else
        ssh-agent > ~/.ssh-agent
        . ~/.ssh-agent
        ssh-add
    fi
}

exportEnvironment() {
    export EDITOR=vim
    export LANG
    export LESS="-X -S"
    export LESSSECURE=1
    export PAGER=less
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
}

[[ -r ~/.bashrc ]] && . ~/.bashrc
if ! [[ $SSH_CLIENT ]] && (( EUID )); then
    runSSHAgent
fi
getLocale
exportEnvironment
