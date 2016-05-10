[[ "$-" == *i* ]] || return

if [[ -z "$SSHHOME" ]]; then
    config_home="$HOME"
else
    config_home="$SSHHOME/.sshrc.d"
fi

. "$config_home"/.config/shell/early-funcs

for file in "$config_home"/.config/{shell,bash}/profile/*; do
    [[ -e $file ]] && . "$file"
done

[[ -r "$config_home"/.bashrc ]] && . "$config_home"/.bashrc
