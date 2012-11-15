xset +fp /usr/share/fonts/local
xset fp rehash

autocutsel -selection CLIPBOARD -fork
autocutsel -selection PRIMARY -fork

exec dwm
