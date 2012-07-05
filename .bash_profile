#!/bin/bash

shopt -s dotglob nullglob globstar

updateDotfiles() {
    if type -p git >/dev/null 2>&1; then
        rm -rf /tmp/cdown-dotfiles
        if [[ -f ~/id_rsa ]]; then
            gitCommand=(git clone git@github.com:cdown/dotfiles.git /tmp/cdown-dotfiles)
        else
            gitCommand=(git clone git://github.com/cdown/dotfiles.git /tmp/cdown-dotfiles)
        fi
        if "${gitCommand[@]}"; then
            for file in ~/git/dotfiles/**/*; do
                fileName=${file##~/git/dotfiles/}
                [[ ! -f $file ]] && continue
                [[ $fileName == .git/* || $fileName == .gitignore ]] && continue
                [[ -e ~/$fileName ]] && unlink ~/"$fileName"
            done
            mkdir -p ~/git
            rm -rf ~/git/dotfiles && mv /tmp/cdown-dotfiles ~/git/dotfiles
            for file in ~/git/dotfiles/**/*; do
                fileName=${file##~/git/dotfiles/}
                [[ ! -f $file ]] && continue
                [[ $fileName == .git/* || $fileName == .gitignore ]] && continue
                [[ $fileName == */* ]] && mkdir -p "${fileName%/*}" 
                [[ -e ~/$fileName ]] && unlink ~/"$fileName"
                ln -s "$file" ~/"$fileName"
            done
        fi
        [[ -r ~/.bash_profile ]] && . ~/.bash_profile noupdate
    fi
}

getTerminfo() {
    if [[ $TERM == st || $TERM == st-256color ]]; then
        if [[ ! -f ~/.terminfo/s/st || ! -f ~/.terminfo/s/st-256color ]]; then
            wget -qO /tmp/st.info http://sprunge.us/BNMe && tic /tmp/st.info
            rm /tic/st.info
        fi
    fi
}

getLocale() {
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
    eval $(ssh-agent)
    ssh-add
}

exportEnvironment() {
    export EDITOR=vim
    export LANG
    export LESS="-X -S"
    export LESSSECURE=1
    export PAGER=less
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
}

if [[ $1 == noupdate ]]; then
    [[ -r ~/.bashrc ]] && . ~/.bashrc
    getTerminfo
    getLocale
    exportEnvironment
else
    runSSHAgent
    updateDotfiles
fi
