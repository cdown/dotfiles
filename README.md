These are my dotfiles that I use across all of my machines.

## Setup

Running `./setup` should sort everything out.

## Branch structures

[`master`][] contains configuration that is portable to all machines. More
specific branches exist for specific use cases. The two major ones are:

- [`mac`][], which is what I run on my Macbook
- [`linux`][], which is what I run on my Linux laptops and servers

Ideally, there should be no need for overrides on those branches -- only
portable code should be present on the master branch. This may not be possible
in some cases, but since merges are frequent, it shouldn't be too much of a
problem anyway.

If you can make your configuration present the right option portably using the
configuration file alone, you should ideally do that. This lowers the risk of
encountering merge conflicts.

## Changes

### Linux

Added configurations for:

- fcitx
- fontconfig
- htop
- X.org
- hushlogin
- mpd

Modified master configuration for:

- GPG agent to include QT4 pinentry

Also included is a systemd unit and timer for offlineimap.

[master]: https://github.com/cdown/dotfiles/tree/master
[mac]: https://github.com/cdown/dotfiles/tree/mac
[linux]: https://github.com/cdown/dotfiles/tree/linux
