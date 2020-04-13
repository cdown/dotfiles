#!/bin/bash

[[ "$-" == *i* ]] || return

if [[ -z "$SSHHOME" ]]; then
    config_home="$HOME"
else
    config_home="$SSHHOME/.sshrc.d"
fi

. "$config_home"/.config/shell/early-funcs

for file in "$config_home"/.config/{shell,bash}/rc/*; do
    [[ -e $file ]] && . "$file"
done

PS1='$(_get_ps1)'
