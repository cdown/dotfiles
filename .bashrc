[[ "$-" == *i* ]] || return

for file in ~/.config/{shell,bash}/rc/*; do
    [[ -e $file ]] && . "$file"
done

PS1=''

if [[ $USER != chris && $USER != cdown ]]; then
    PS1+='\u@'
fi

PS1+='\h$chroot_text:\W$(_git_prompt)\$ '

set +H

HISTSIZE=2500
HISTFILESIZE=$HISTSIZE
HISTCONTROL=ignoredups

shopt -s histappend
shopt -s extglob
shopt -s globstar

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
elif [[ -r /etc/bash_completion ]]; then
    . /etc/bash_completion
fi
