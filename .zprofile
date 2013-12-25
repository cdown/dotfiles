#!/bin/zsh

[[ "$-" == *i* ]] || return

for file in ~/.config/shells/profile/*; do
    . "$file"
done

[[ -r ~/.zshrc ]] && . ~/.zshrc
