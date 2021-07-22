#!/bin/bash

ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/.gitignore_global ~/.gitignore_global

# Install RMate for remote Sublime for use with https://github.com/randy3k/RemoteSubl
# https://stefanbauer.me/tips-and-tricks/edit-files-on-a-remote-server-via-ssh-with-sublime-right-in-your-terminal
sudo wget -O /usr/local/bin/rsub https://raw.github.com/aurora/rmate/master/rmate
sudo chmod a+x /usr/local/bin/rsub
sudo mv /usr/local/bin/rmate /usr/local/bin/subl
