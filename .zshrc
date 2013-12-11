#!/bin/zsh

[[ "$-" == *i* ]] || return

for file in ~/.config/zsh/rc/*; do
    . "$file"
done
