[[ -r ~/.bashrc ]] && . ~/.bashrc

export EDITOR=vim
export LANG=en_GB.utf8
export PAGER=less
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

if ! [[ $SSH_CLIENT ]] && (( EUID )) && ! pgrep -u "$EUID" -x ssh-agent; then
    eval "$(ssh-agent | tee ~/.ssh-agent)"
    ssh-add
else
    [[ -r ~/.ssh-agent ]] && . ~/.ssh-agent
fi
