[[ "$-" == *i* ]] || return

for file in ~/.config/bash/profile/*; do
    . "$file"
done

[[ -r ~/.bashrc ]] && . ~/.bashrc
