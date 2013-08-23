#!/bin/bash

[[ "$-" == *i* ]] || return

for file in ~/.bash/rc/*; do
    . "$file"
done
