[[ "$-" == *i* ]] || return

for file in ~/.config/shell/profile/*; do
    . "$file"
done

[[ -r ~/.bashrc ]] && . ~/.bashrc
