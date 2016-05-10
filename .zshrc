#!/bin/zsh

[[ "$-" == *i* ]] || return

if [[ -z "$SSHHOME" ]]; then
    config_home="$HOME"
else
    config_home="$SSHHOME"
fi

. "$config_home"/.config/shell/early-funcs

for file in "$config_home"/.config/{shell,zsh}/rc/*(N); do
    . "$file"
done

PS1='$(_get_ps1)'
