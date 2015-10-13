#!/bin/bash

[[ "$-" == *i* ]] || return

. ~/.config/shell/early-funcs

for file in ~/.config/{shell,bash}/rc/*; do
    [[ -e $file ]] && . "$file"
done

PS1='$(_get_ps1)'
