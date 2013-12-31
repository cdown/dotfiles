#!/bin/zsh

[[ "$-" == *i* ]] || return

for file in ~/.config/{shell,zsh}/profile/*(N); do
    . "$file"
done

[[ -r ~/.zshrc ]] && . ~/.zshrc
