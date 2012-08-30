[[ -r ~/.bashrc ]] && . ~/.bashrc

export EDITOR=vim
export LANG=en_GB.utf8
export PAGER=less
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

if ! pgrep -u "$EUID" -x ssh-agent >/dev/null 2>&1; then
    eval "$(ssh-agent | tee ~/.ssh-agent)" >/dev/null
    ssh-add
else
    [[ -r ~/.ssh-agent ]] && . ~/.ssh-agent >/dev/null
fi
