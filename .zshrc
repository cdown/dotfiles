[[ "$-" == *i* ]] || return

autoload -U compinit promptinit
compinit -i
promptinit

. ~/.config/shell/early-funcs

for file in ~/.config/{shell,zsh}/rc/*(N); do
    . "$file"
done

PS1='$(_get_ps1)'

# zsh's git tab completion by default is extremely slow. This makes it use
# local files only. See http://stackoverflow.com/a/9810485/945780.
__git_files () {
    _wanted files expl 'local files' _files
}

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
set -o rmstarsilent
set -o nullglob
set -o prompt_subst
set -o ksh_glob
set -o no_bare_glob_qual
set -o shwordsplit

zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

bindkey -e
