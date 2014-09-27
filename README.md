These are my dotfiles that I use across all of my machines.

## Branch structures

[`master`][] contains configuration that is portable to all machines. More
specific branches exist for specific use cases. The two major ones are:

- [`mac`][], which is what I run on my Macbook
- [`linux`][], which is what I run on my Linux laptops and servers

Ideally, there should be no need for overrides on those branches -- only
portable code should be present on the master branch. This may not be possible
in some cases, but since merges are frequent, it shouldn't be too much of a
problem anyway.

## Setup

Running `./setup` should sort everything out.

[master]: https://github.com/cdown/dotfiles/tree/master
[mac]: https://github.com/cdown/dotfiles/tree/mac
[linux]: https://github.com/cdown/dotfiles/tree/linux
