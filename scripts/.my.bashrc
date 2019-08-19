#!/bin/bash -eu

# -----------------------------------------
# Welcome to the BITCHIN UNIX BASHRC Script
# -----------------------------------------
#  _______             _______
# |@|@|@|@|           |@|@|@|@|
# |@|@|@|@|   _____   |@|@|@|@|
# |@|@|@|@| /\_T_T_/\ |@|@|@|@|
# |@|@|@|@||/\ T T /\||@|@|@|@|
#  ~/T~~T~||~\/~T~\/~||~T~~T\~
#   \|__|_| \(-(O)-)/ |_|__|/
#   _| _|    \\8_8//    |_ |_
# |(@)]   /~~[_____]~~\   [(@)|
#   ~    (  |       |  )    ~
#       [~` ]       [ '~]
#       |~~|         |~~|
#       |  |         |  |
#      _<\/>_       _<\/>_
#     /_====_\     /_====_\
#
# An internal tool of PICKNIK Robotics.
#
# Customized bash script for multiple computers
#
# STYLE
#
#   Please follow the Google Shell Style Guide:
#   https://google.github.io/styleguide/shell.xml
#
# USAGE
#
#   # BASHRC_ENV tells .my.bashrc which environment we are in
#   # export BASHRC_ENV=mac
#
#   # Source users personal .my.bashrc if it exists.
#   # if [[ -f ~/bitchin_unix/.my.bashrc ]]; then
#   # . ~/bitchin_unix/.my.bashrc
#   # fi



# Default Ubuntu Settings #######################################################

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Clear the screen
clear

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
# Skip for Gento
if [[ $BASHRC_ENV != "ros_baxter" ]]; then
    [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
fi

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r $HOME/.dircolors && eval "$(dircolors -b $HOME/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Remove line numbers in history
alias history="history | sed 's/^[ ]*[0-9]\+[ ]*//'"

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Non-Default Ubuntu Settings #######################################################

# Linux vs OSX Settings
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='osx'
fi

# Reset Catkin stuff
# make sure the ordering of the ROS sources do not get mixed up
unset CMAKE_PREFIX_PATH
unset ROS_PACKAGE_PATH

# ccache, at front of source to enable compiling with ccache before other compilers
if [[ -d /usr/lib/ccache ]]; then #Only will use if installed
  export PATH=/usr/lib/ccache:$PATH
fi

function source_all()
{
  pushd .
  source_all
  cd ~/public_setup/scripts/
  source source_all.sh
  popd
}

function source_mike()
{
  source_all
  export UBUNTU_VERSION=`lsb_release --codename | cut -f2`
  alias fix_unset="set +o nounset"
  alias cignore="touch CATKIN_IGNORE"
  alias cnignore="rm -f CATKIN_IGNORE"

  vim_alias
  sourceCurrentWorkspace
  export CATKIN_WS=$current_ros_workspace_path
  export CATKIN_WS_ID=$current_ros_workspace

  clear
  echo -e  "BASHRC_ENV     | ros_mike"
  echo -e  "ROS_DISTRO     | $ROS_DISTRO"
  echo -e  "CATKIN_WS_ID   | $CATKIN_WS_ID"
  echo -e  "CATKIN_WS      | $CATKIN_WS"

  echo ""

}
