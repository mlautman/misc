export SCRIPT_BASE_PATH=`pwd`

# moving around filesystem
source $SCRIPT_BASE_PATH/scripts/unix.sh

# emacs customizations
source $SCRIPT_BASE_PATH/scripts/emacs.sh

# compressing files e.g. zip
source $SCRIPT_BASE_PATH/scripts/compress.sh

# git aliases and functions
source $SCRIPT_BASE_PATH/scripts/git.sh

# helpers for searching through files
source $SCRIPT_BASE_PATH/scripts/search.sh

# Shortcuts for building stuff
source $SCRIPT_BASE_PATH/scripts/build.sh

# Shortcuts for quickly opening notes
source $SCRIPT_BASE_PATH/scripts/aliases.sh

# Formatting shortcuts
source $SCRIPT_BASE_PATH/scripts/formatting.sh

# Docker
source $SCRIPT_BASE_PATH/scripts/docker.sh

# Python
# source $SCRIPT_BASE_PATH/scripts/python.sh

# Just for giggles
source $SCRIPT_BASE_PATH/scripts/fun.sh

# Special aliases for using bitchin unix
source $SCRIPT_BASE_PATH/scripts/bitchin.sh

# Ubuntu only scrips
if [[ $platform != 'osx' ]]; then
    source $SCRIPT_BASE_PATH/scripts/ubuntu.sh
fi

# ROS
source $SCRIPT_BASE_PATH/scripts/ros.sh
source $SCRIPT_BASE_PATH/scripts/catkin.sh

