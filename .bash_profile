#!/bin/bash

for file in ~/.bash/profile/*; do
    [[ -e $file ]] && . "$file"
done

[[ -r ~/.bashrc ]] && . ~/.bashrc
