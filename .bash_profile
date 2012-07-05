[[ -r ~/.bashrc ]] && . ~/.bashrc

localesDesired=({en_{GB,US},C}.{utf8,UTF-8}) 

export EDITOR=vim
export LESS="-X -S"
export LESSSECURE=1
export PAGER=less
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

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

eval $(ssh-agent)
ssh-add
