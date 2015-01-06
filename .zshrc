[[ "$-" == *i* ]] || return

for file in ~/.config/{shell,zsh}/rc/*(N); do
    . "$file"
done

PS1='%n@%m$chroot_text:$(if [[ $PWD == $HOME ]]; then
    echo "~"
else
    stripped_pwd="${PWD##*/}"
    if [[ -n $stripped_pwd ]]; then
        echo "$stripped_pwd"
    else
        echo /
    fi
fi
)$(_git_prompt)$([[ $(id -u) == 0 ]] && echo "#" || echo $) '

__git_files () {
    _wanted files expl 'local files' _files
}

autoload -U compinit promptinit
compinit -i
promptinit

HISTFILE=$HOME/.zsh_history
HISTSIZE=2500
SAVEHIST=$HISTSIZE

LISTMAX=0

case $TERM in
    xterm*|rxvt*)
        precmd() {
            print -Pn "\e]0;zsh %(1j,%j job%(2j|s|); ,)%~\a"
        }
        preexec() {
            printf "\033]0;%s\a" "$1"
        }
    ;;
esac

alias git='noglob git'

set -o always_to_end
set -o append_history
set -o complete_in_word
set -o extendedglob
set -o histappend
set -o histignorealldups
set -o no_bang_hist
set -o rmstarsilent
set -o nullglob
set -o prompt_subst
set -o share_history

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

bindkey -e
