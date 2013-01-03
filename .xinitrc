xset +fp /usr/share/fonts/local
xset fp rehash

exec i3 > "/tmp/i3-$$.log" 2>&1
