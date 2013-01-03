xset +fp /usr/share/fonts/local
xset fp rehash

autocutsel -fork
autocutsel -selection PRIMARY -fork

exec i3 > "/tmp/i3-$$.log" 2>&1
