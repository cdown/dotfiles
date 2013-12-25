[[ "$-" == *i* ]] || return

for file in ~/.config/shell/rc/*; do
    . "$file"
done

PS1='%n@%m:$([[ $PWD == $HOME ]] && echo "~" || echo "${PWD##*/}")$(_git_prompt)$([[ $(id -u) == 0 ]] && echo "#" || echo $) '

autoload -U compinit promptinit
compinit
promptinit

HISTFILE=$HOME/.zsh_history
HISTSIZE=2500
SAVEHIST=$HISTSIZE

LISTMAX=0

set -o always_to_end
set -o append_history
set -o complete_in_word
set -o extendedglob
set -o histappend
set -o histignorealldups
set -o no_bang_hist
set -o nullglob
set -o prompt_subst
set -o share_history

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

bindkey -e

typeset -A key

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

[[ -n "${key[Home]}"   ]] && bindkey "${key[Home]}" beginning-of-line
[[ -n "${key[End]}"    ]] && bindkey "${key[End]}" end-of-line
[[ -n "${key[Insert]}" ]] && bindkey "${key[Insert]}" overwrite-mode
[[ -n "${key[Delete]}" ]] && bindkey "${key[Delete]}" delete-char
[[ -n "${key[Up]}"     ]] && bindkey "${key[Up]}" history-beginning-search-backward
[[ -n "${key[Down]}"   ]] && bindkey "${key[Down]}" history-beginning-search-forward
[[ -n "${key[Left]}"   ]] && bindkey "${key[Left]}" backward-char
[[ -n "${key[Right]}"  ]] && bindkey "${key[Right]}" forward-char

if [[ -n ${terminfo[smkx]} ]]; then
    zle-line-init() {
        echoti smkx
    }
    zle -N zle-line-init
fi

if [[ -n ${terminfo[rmkx]} ]]; then
    zle-line-finish() {
        echoti rmkx
    }
    zle -N zle-line-finish
fi
