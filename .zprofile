#!/bin/zsh

[[ "$-" == *i* ]] || return

if [[ -z "$SSHHOME" ]]; then
    config_home="$HOME"
else
    config_home="$SSHHOME/.sshrc.d"
fi

. "$config_home"/.config/shell/early-funcs

for file in "$config_home"/.config/{shell,zsh}/profile/*(N); do
    . "$file"
done

[[ -r "$config_home"/.zshrc ]] && . "$config_home"/.zshrc
