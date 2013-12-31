[[ "$-" == *i* ]] || return

for file in ~/.config/{shell,zsh}/rc/*(N); do
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
