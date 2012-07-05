#!/bin/bash

shopt -s dotglob nullglob globstar

if [[ $1 != "noupdate" ]]; then
    if type -p git >/dev/null 2>&1; then
        if [[ ! -d ~/git/dotfiles ]]; then
            mkdir -p ~/git/dotfiles
            for file in ~/git/dotfiles/**/*; do
                fileName=${file##~/git/dotfiles/}
                [[ ! -f $file ]] && continue
                [[ $fileName == .git/* || $fileName == .gitignore ]] && continue
                [[ -e ~/$fileName ]] && unlink ~/"$fileName"
            done
            git clone git://github.com/cdown/dotfiles.git ~/git/dotfiles
        else
            git pull ~/git/dotfiles
        fi
        for file in ~/git/dotfiles/**/*; do
            fileName=${file##~/git/dotfiles/}
            [[ ! -f $file ]] && continue
            [[ $fileName == .git/* || $fileName == .gitignore ]] && continue
            [[ -e ~/$fileName ]] && unlink ~/"$fileName"
            [[ $fileName == */* ]] && mkdir -p "${fileName%/*}" 
            ln -s "$file" ~/"$fileName"
        done
    fi
    [[ -r ~/.bash_profile ]] && . ~/.bash_profile noupdate
fi

[[ -r ~/.bashrc ]] && . ~/.bashrc

if [[ $TERM == st || $TERM == st-256color ]]; then
    if [[ ! -f ~/.terminfo/s/st || ! -f ~/.terminfo/s/st-256color ]]; then
        wget -qO /tmp/st.info http://sprunge.us/BNMe && tic /tmp/st.info
    fi
fi

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

export LANG
export EDITOR=vim
export LESS="-X -S"
export LESSSECURE=1
export PAGER=less
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

eval $(ssh-agent)
ssh-add
