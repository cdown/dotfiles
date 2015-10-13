#!/bin/zsh

[[ "$-" == *i* ]] || return

. ~/.config/shell/early-funcs

for file in ~/.config/{shell,zsh}/rc/*(N); do
    . "$file"
done
