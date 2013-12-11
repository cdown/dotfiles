#!/bin/zsh

[[ "$-" == *i* ]] || return

for file in ~/.config/zsh/profile/*; do
    . "$file"
done

[[ -r ~/.zshrc ]] && . ~/.zshrc
