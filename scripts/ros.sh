#!/bin/bash -eu

# Shortcuts for using ROS

# Console output prefix - hides timestamp. See http://wiki.ros.org/rosconsole
export ROSCONSOLE_FORMAT='${logger}: ${message}'
#export ROSCONSOLE_FORMAT='[${severity}] [${time}]: ${message}'
#export ROSCONSOLE_FORMAT='${time}, ${logger}: ${message}'

## Aliases
alias rviz="rosrun rviz rviz"
alias rqt="rosrun rqt_gui rqt_gui"

# Customize per user
alias myrosconsole="e $SCRIPT_BASE_PATH/config/${BASHRC_NAME}.rosconsole.yaml"

alias rosreindex="echo deprecated, type instead 'rospack profile'"

alias disablepkg="mv package.xml package.xml.disabled"
alias enablepkg="mv package.xml.disabled package.xml"

# TODO(davetcoleman): remove this in 2019
alias rosdepinstall_indigo="echo deprecated, please simply use the alias rosdepinstall"
alias rosdepinstall_jade="echo deprecated, please simply use the alias rosdepinstall"
alias rosdepinstall_kinetic="echo deprecated, please simply use the alias rosdepinstall"
alias rosdepinstall_melodic="echo deprecated, please simply use the alias rosdepinstall"

# Rosdep shortcut
function rosdepinstall {
  rosdep install --from-paths . --ignore-src --rosdistro ${ROS_DISTRO}
}

# Kill
alias killgazebo="killall -9 gazebo & killall -9 gzserver  & killall -9 gzclient"
alias killros="pkill -f rosmaster & pkill -f roscore & ps aux | grep ros"

# Time
alias rossimtime="rosparam set /use_sim_time true"

## Sync dev machine time to Baxter's syncing server
alias syncmytime="sudo ntpdate pool.ntp.org"

# TF
alias tfpdf='cd /var/tmp && rosrun tf view_frames && open frames.pdf &'

# Bloom shortcuts
alias bloom_alias_load="source $SCRIPT_BASE_PATH/scripts/bloom.sh"

function ros_clean_workspace
{
  # make sure the ordering of the ROS sources do not get mixed up
  unset CMAKE_PREFIX_PATH
  unset ROS_PACKAGE_PATH

  echo "Displaying ros package path:"
  rosPackagePath
}

# Testing ROS comm
alias rostestpub="rostopic pub /basic_test -r 1 std_msgs/Float32 99.9"
alias rostestecho="rostopic echo /basic_test"

# gdb
alias rosrungdb='gdb --ex run --args ' #/opt/ros/kinetic/lib/rviz/rviz

function rosPackagePath
{
  arr=$(echo $CMAKE_PREFIX_PATH | tr ":" "\n")
  for x in $arr
  do
    rootpath1="/home/$USER/ros/"
    rootpath2="/opt/ros/"
    x=${x#${rootpath1}}
    echo "  " ${x#${rootpath2}}
  done
};

function syncNTPServer
{
  sudo service ntp stop
  sudo ntpdate pool.ntp.org
  ntpdate -q 128.138.244.56
  sudo service ntp start
}

function ros_shadow_fixed_enable
{
  echo 'deb http://packages.ros.org/ros-shadow-fixed/ubuntu xenial main' | sudo tee /etc/apt/sources.list.d/ros-latest.list
  sudo apt-get update
}

function ros_shadow_fixed_disable
{
  echo 'deb http://packages.ros.org/ros/ubuntu xenial main' | sudo tee /etc/apt/sources.list.d/ros-latest.list
  sudo apt-get update
}

# function git_sync_moveit
# {
#     bash $SCRIPT_BASE_PATH/scripts/ros_moveit_sync.sh
# }

function ros_namespace_all_console_output
{
  # Regular
  findreplace 'ROS_DEBUG(' 'ROS_DEBUG_NAMED("_FILE_NAME_", '
  findreplace 'ROS_INFO(' 'ROS_INFO_NAMED("_FILE_NAME_", '
  findreplace 'ROS_WARN(' 'ROS_WARN_NAMED("_FILE_NAME_", '
  findreplace 'ROS_ERROR(' 'ROS_ERROR_NAMED("_FILE_NAME_", '
  findreplace 'ROS_FATAL(' 'ROS_FATAL_NAMED("_FILE_NAME_", '

  # Regular with extra space
  findreplace 'ROS_DEBUG (' 'ROS_DEBUG_NAMED("_FILE_NAME_", '
  findreplace 'ROS_INFO (' 'ROS_INFO_NAMED("_FILE_NAME_", '
  findreplace 'ROS_WARN (' 'ROS_WARN_NAMED("_FILE_NAME_", '
  findreplace 'ROS_ERROR (' 'ROS_ERROR_NAMED("_FILE_NAME_", '
  findreplace 'ROS_FATAL (' 'ROS_FATAL_NAMED("_FILE_NAME_", '

  # ONCE
  findreplace 'ROS_DEBUG_ONCE(' 'ROS_DEBUG_ONCE_NAMED("_FILE_NAME_", '
  findreplace 'ROS_INFO_ONCE(' 'ROS_INFO_ONCE_NAMED("_FILE_NAME_", '
  findreplace 'ROS_WARN_ONCE(' 'ROS_WARN_ONCE_NAMED("_FILE_NAME_", '
  findreplace 'ROS_ERROR_ONCE(' 'ROS_ERROR_ONCE_NAMED("_FILE_NAME_", '
  findreplace 'ROS_FATAL_ONCE(' 'ROS_FATAL_ONCE_NAMED("_FILE_NAME_", '

  # ONCE with extra space
  findreplace 'ROS_DEBUG_ONCE (' 'ROS_DEBUG_ONCE_NAMED("_FILE_NAME_", '
  findreplace 'ROS_INFO_ONCE (' 'ROS_INFO_ONCE_NAMED("_FILE_NAME_", '
  findreplace 'ROS_WARN_ONCE (' 'ROS_WARN_ONCE_NAMED("_FILE_NAME_", '
  findreplace 'ROS_ERROR_ONCE (' 'ROS_ERROR_ONCE_NAMED("_FILE_NAME_", '
  findreplace 'ROS_FATAL_ONCE (' 'ROS_FATAL_ONCE_NAMED("_FILE_NAME_", '

  # STREAM
  findreplace 'ROS_DEBUG_STREAM(' 'ROS_DEBUG_STREAM_NAMED("_FILE_NAME_", '
  findreplace 'ROS_INFO_STREAM(' 'ROS_INFO_STREAM_NAMED("_FILE_NAME_", '
  findreplace 'ROS_WARN_STREAM(' 'ROS_WARN_STREAM_NAMED("_FILE_NAME_", '
  findreplace 'ROS_ERROR_STREAM(' 'ROS_ERROR_STREAM_NAMED("_FILE_NAME_", '
  findreplace 'ROS_FATAL_STREAM(' 'ROS_FATAL_STREAM_NAMED("_FILE_NAME_", '

  # STREAM with extra space
  findreplace 'ROS_DEBUG_STREAM (' 'ROS_DEBUG_STREAM_NAMED("_FILE_NAME_", '
  findreplace 'ROS_INFO_STREAM (' 'ROS_INFO_STREAM_NAMED("_FILE_NAME_", '
  findreplace 'ROS_WARN_STREAM (' 'ROS_WARN_STREAM_NAMED("_FILE_NAME_", '
  findreplace 'ROS_ERROR_STREAM (' 'ROS_ERROR_STREAM_NAMED("_FILE_NAME_", '
  findreplace 'ROS_FATAL_STREAM (' 'ROS_FATAL_STREAM_NAMED("_FILE_NAME_", '
}

function ros_script {
  e $SCRIPT_BASE_PATH/scripts/ros.sh
  source $SCRIPT_BASE_PATH/scripts/ros.sh
  echo "ROS script re-sourced"
}

#Makes ws_$1/src folders and enables workon functionality
function ros_create_new_workspace #$1 is the name creates ws_$1, $2(optional) is path so ~/$2/ws_$1
{
  if [[ -z $1 ]]; then
    echo "Usage: ros_create_new_workspace <workspace_id> <workspace_path>"
    return 1
  fi

  cd ~
  #Make our folder
  mkdir -p ~/$2/src
  #Add it to .ros_workspaces to enable workon command
  echo "$1: $2" >> ~/.ros_workspaces
  #Workon our new workspace
  workon $1
}

#########################################################################################
# Switching between named workspaces with autocomplete
#
# These functions allow convenient switching between named ROS workspaces by calling.
#
# $: workon workspace_name
#
# For that, workspaces need to be specified inside a file ~/.ros_workspaces.
# The file should contain a list of workspace names and paths starting at $HOME.
# For example workspace_name at $HOME/ros/workspace_x matches the following entry:
#
# workspace_name: ros/workspace_x
#
# The current workspace is also stored in a file to make it available in new shells.
# By adding 'sourceCurrentWorkspace' to the .bashrc the workspace is sourced automatically.
###########################################################################################
# ROS_WORKSPACES_CONFIG: specify your workspaces here
ROS_WORKSPACES_CONFIG=$HOME/.ros_workspaces
# CURRENT_ROS_WORKSPACE_FILE: stores the current workspace and is generated automatically
CURRENT_ROS_WORKSPACE_FILE=$HOME/.current_ros_workspace

# load the ros workspaces config
loadRosWorkspacesConfig() {
  workspaces=()
  workspace_paths=()
  if [[ -f $ROS_WORKSPACES_CONFIG ]]; then
    while read name path; do
      workspaces+=("$name")
      workspace_paths+=("$path")
    done < <(sed '/:/!d;/^ *#/d;s/:/ /;' < "$ROS_WORKSPACES_CONFIG")
  else
    echo "Failed to find file $ROS_WORKSPACES_CONFIG"
  fi
}

# look for a ros workspace in the configuration file
findRosWorkspace() {
  local ws=${1:?"Please specifiy a ros workspace to look for"}
  loadRosWorkspacesConfig
  for i in "${!workspace_paths[@]}"
  do
    # find current workspace
    if [[ "${workspaces[$i]}" = "$ws" ]]; then
      echo "${HOME}/${workspace_paths[$i]}"
    fi
  done
}

# write workspace name to file and update current_ros_workspace
setCurrentRosWorkspace() {
  local ws=${1:?"Please specifiy a ros workspace path"}
  echo $ws > $CURRENT_ROS_WORKSPACE_FILE
  current_ros_workspace="$ws"
}

# return the current workspace
getCurrentRosWorkspace() {
  if [[ -f "$CURRENT_ROS_WORKSPACE_FILE" ]]; then
    current_ros_workspace="$(< $CURRENT_ROS_WORKSPACE_FILE)"
    current_ros_workspace_path="$(findRosWorkspace $current_ros_workspace)"
    echo $current_ros_workspace
  fi
}

# source the current workspace
sourceCurrentWorkspace() {
  if [[ -f $ROS_WORKSPACES_CONFIG ]]; then
    getCurrentRosWorkspace > /dev/null
    if [[ ! -z "$current_ros_workspace_path" ]]; then
      export CATKIN_WS=$current_ros_workspace_path
      if [[ -e "$current_ros_workspace_path/devel/setup.bash" ]]; then
        source "$current_ros_workspace_path/devel/setup.bash"
      fi
      if [[ -e "$current_ros_workspace_path/install/local_setup.bash" ]]; then
        source "$current_ros_workspace_path/install/local_setup.bash"
      fi
    fi
  fi
}

# change the current workspace to another one
workon() {
  # check input
  local ws=${1:?"Please specifiy a workspace name"}

  # try to load workspace config
  if [[ ! -f $ROS_WORKSPACES_CONFIG ]]; then
    echo "Could not find a valid workspace config at: ${ROS_WORKSPACES_CONFIG}"
    return
  fi
  loadRosWorkspacesConfig

  # check if workspace is already set
  getCurrentRosWorkspace > /dev/null
  local ws_path="$(findRosWorkspace $ws)"
  if [[ ! -z $ws_path ]]; then
    if [[ ($current_ros_workspace = "$ws"  &&  $current_ros_workspace_path = "$ws_path") ]]; then
      echo "Current ros workspace is already set to '${ws}' at: ${current_ros_workspace_path}"
    else
      echo "Changing current ros workspace to '${ws}' at: ${ws_path}"
    fi
    unset CMAKE_PREFIX_PATH
    unset ROS_PACKAGE_PATH
    export CATKIN_WS=${ws_path}
    if [[ -e  "${ws_path}/devel/setup.bash" ]]; then
      source "${ws_path}/devel/setup.bash"
    elif [[ -e  "${ws_path}/install/local_setup.bash" ]]; then
      source "${ws_path}/install/local_setup.bash"
    fi

    setCurrentRosWorkspace $ws
    current_ros_workspace_path=$ws_path
    cd $current_ros_workspace_path
    return
  else
    # we didn't find it
    echo "Workspace ${ws} could not be found. Please add it to the config: ${ROS_WORKSPACES_CONFIG}"
  fi
}

# autocomplete specified workspace names
_workspace_complete() {
  local cur
  COMPREPLY=()
  # Variable to hold the current word
  cur="${COMP_WORDS[COMP_CWORD]}"
  loadRosWorkspacesConfig
  COMPREPLY=( $(compgen -W "${workspaces[*]}" $cur) )
}

complete -F _workspace_complete workon
complete -F _workspace_complete findRosWorkspace
complete -F _workspace_complete setCurrentRosWorkspace
