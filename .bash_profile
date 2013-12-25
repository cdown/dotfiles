[[ "$-" == *i* ]] || return

for file in ~/.config/shells/profile/*; do
    . "$file"
done

[[ -r ~/.bashrc ]] && . ~/.bashrc
