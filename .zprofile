#!/bin/zsh

[[ "$-" == *i* ]] || return

. ~/.config/shell/early-funcs

for file in ~/.config/{shell,zsh}/profile/*(N); do
    . "$file"
done

[[ -r ~/.zshrc ]] && . ~/.zshrc
