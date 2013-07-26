#!/bin/bash

for file in ~/.bash/rc/*; do
    . "$file"
done
