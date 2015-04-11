[[ "$-" == *i* ]] || return

autoload -U compinit promptinit
compinit -i
promptinit

. ~/.config/shell/early-funcs

for file in ~/.config/{shell,zsh}/rc/*(N); do
    . "$file"
done

PS1='$(_get_ps1)'

__git_files () {
    _wanted files expl 'local files' _files
}

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

zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

bindkey -e
