#!/bin/bash -eu

# Jump to this folder
alias myscripts='cd $SCRIPT_BASE_PATH/scripts && ls -a'

# Aliases for listing files and folders
alias ll='ls -AlFh'
alias la='ls -Ah'
alias l='ls -CFh'
alias listfolders='ls -AF | grep /'
alias listfiles="find * -type f -print" # lists files in the current directory
function cdl {
  cd "$1" && ll
}

# Quick back folder
alias c="cd .."
alias mkdir="mkdir -p"

# Search for particular argument in man page
# Format: mans PROGRAM SEARCH_KEY
function mans {
    man $1 | less -p "^ +$2"
}

# Diff with color
alias diff="colordiff"

# Folder size
alias foldersize="du -hs" #folder
alias foldersizes="du -h -d 1" #folders

# get just the ip address
function myip
{
    ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
}

alias pingg="ping google.com"

# When only working from terminal (no X windows)
# this allows ssh key to be remebered
function ssh_remember_key_terminal
{
    ssh-agent
    eval $(ssh-agent)
    ssh-add ~/.ssh/id_rsa
}

# Text Editor
function vim_alias {
    alias e="vim"
    alias se="sudo vim"
    export EDITOR='vim'
}

function sublime_alias
{
    alias e="subl"
    alias se="sudo subl"

    # Keep current EDITOR
    #export EDITOR='subl'
    # Change git config editor here - default sublime does not wait
    #git config --global core.editor "'subl' --wait"
}

# Clipboard
alias xc="xclip" # copy
alias xv="xclip -o" # paste
alias pwdxc="pwd | xclip"
alias copy="xclip -sel clip"
alias paste="xclip -sel clip -o"

# Search running processes
alias pp="ps aux | grep "

# gdb
alias gdbrun='gdb --ex run --args '

# play success sounds
# alias playsuccess="play -v 0.9 -q $SCRIPT_BASE_PATH/config/emacs/success.wav"
# alias playdone="play -v 0.9 -q $SCRIPT_BASE_PATH/config/emacs/done.wav"
# alias playfailure="play -v 0.9 -q $SCRIPT_BASE_PATH/config/emacs/failure.wav"

alias copysshpub="xclip -sel clip < ~/.ssh/id_rsa.pub"
# alias copysshprivate="xclip -sel clip < ~/.ssh/id_rsa"
