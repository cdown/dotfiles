#!/bin/bash

for file in ~/.bash/profile/*; do
    . "$file"
done

[[ -r ~/.bashrc ]] && . ~/.bashrc
