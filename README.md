dpkg-tmux
=========

Script that compiles and builds a Ubuntu package for tmux from the official tmux GitHub with fpm.

## What
* `build.sh` - the main script; does all the work


## Pre-Requisites
* apt-get install bundler (required to run bundle command)

## Usage
```bash
bundle install
build.sh
```

You'll find your .deb in the _pkg directory.

* [tmux](https://github.com/tmux/tmux)
* [FPM](https://github.com/jordansissel/fpm)
