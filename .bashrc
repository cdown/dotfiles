#!/bin/bash

for file in ~/.bash/rc/*; do
    [[ -e $file ]] && . "$file"
done
