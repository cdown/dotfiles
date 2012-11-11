[[ -r ~/.bashrc ]] && . ~/.bashrc

export EDITOR=vim
export PAGER=less
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

[[ -r ~/.ssh-agent ]] && . ~/.ssh-agent >/dev/null
if ! ssh-add -l >/dev/null 2>&1; then
    if ! pgrep -u "$EUID" -x ssh-agent >/dev/null 2>&1; then
        eval "$(ssh-agent | tee ~/.ssh-agent)" >/dev/null
    fi
    ssh-add
fi
