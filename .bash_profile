[[ "$-" == *i* ]] || return

for file in ~/.config/{shell,bash}/profile/*; do
    [[ -e $file ]] && . "$file"
done

[[ -r ~/.bashrc ]] && . ~/.bashrc
