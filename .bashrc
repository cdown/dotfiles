#!/bin/bash

[[ "$-" == *i* ]] || return

for file in ~/.config/bash/rc/*; do
    . "$file"
done
