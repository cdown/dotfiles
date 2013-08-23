#!/bin/bash

[[ "$-" == *i* ]] || return

for file in ~/.bash/profile/*; do
    . "$file"
done

[[ -r ~/.bashrc ]] && . ~/.bashrc
