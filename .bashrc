shopt -s extglob globstar nullglob

HISTCONTROL=ignoredups
HISTFILESIZE=250
HISTSIZE=$HISTFILESIZE
PS1='\h:\W\$ '

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias v='ls -laFh'
alias sprunge='curl -F "sprunge=<-" http://sprunge.us'

so() {
    local tmpdir="$(mktemp -d)"
    local tmprc="$(mktemp)"
    cat > "$tmprc" << EOF
PS1='\$ '
cd "$tmpdir"
EOF
    env - "$(type -p bash)" --noprofile --rcfile "$tmprc"
    rm -r "$tmpdir" "$tmprc"
}
