#!/bin/bash

# Get the path of the script file (its own path)
selfpath=$(
    cd $(dirname $0)
    pwd
)

ln -sf $selfpath/.zshrc $HOME/.zshrc
ln -sF $selfpath/.kevin_zsh $HOME/.kevin_zsh
ln -sf $selfpath/.vimrc $HOME/.vimrc
ln -sf $selfpath/.uncrustify.cfg $HOME/.uncrustify.cfg
ln -sf $selfpath/.tmux.conf.local $HOME/.tmux.conf.local
