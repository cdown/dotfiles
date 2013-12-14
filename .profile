[[ $KSH_VERSION == *"MIRBSD KSH"* ]] || return

[[ "$-" == *i* ]] || return

for file in ~/.config/mksh/profile/*; do
    . "$file"
done

[[ -r ~/.mkshrc ]] && . ~/.mkshrc
