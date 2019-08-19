#!/bin/bash -eu

alias catbuildrelease="catkin br"
alias catclean="catkin clean"
alias catcleanbuild="catclean && catbuild"
alias catcleanbuilddebug="catclean && catbuilddebug"
alias catcleanbuildrelease="catclean && catbuildrelease"

function catkin_tools_set_arg
{
  ROS_SOURCE_TYPE=$1
  ROS_SOURCE_TYPE_CAP="$(tr '[:lower:]' '[:upper:]' <<< ${ROS_SOURCE_TYPE:0:1})${ROS_SOURCE_TYPE:1}"
  echo "Setting catkin_tools to $ROS_SOURCE_TYPE and build type $ROS_SOURCE_TYPE_CAP"

  echo "export ROS_SOURCE_TYPE=$ROS_SOURCE_TYPE" > ~/.catkin_source.sh
  catkin profile add $ROS_SOURCE_TYPE
  catkin profile set $ROS_SOURCE_TYPE
  catkin config -b build_$ROS_SOURCE_TYPE -d devel_$ROS_SOURCE_TYPE $2 --extend /opt/ros/${ROS_DISTRO} --cmake-args -DCMAKE_BUILD_TYPE=$ROS_SOURCE_TYPE_CAP
  catkin build
  mybashr
}

function catkin_tools_set_release
{
  catkin_tools_set_arg release --no-install
}

function catkin_tools_set_debug
{
  catkin_tools_set_arg debug --no-install
}

function catkin_tools_set_relwithdebinfo
{
  catkin_tools_set_arg relwithdebinfo --no-install
}

function catkin_clean_all__build_artifacts
{
  # Run this in a folder that contains many catkin workspaces
  # and it should delete all build artifacts to save memory when
  # copying

  find . -type d -name build -exec rm -rf {} \;
  find . -type d -name devel -exec rm -rf {} \;
  find . -type d -name build_relwithdebinfo -exec rm -rf {} \;
  find . -type d -name devel_relwithdebinfo -exec rm -rf {} \;
  find . -type d -name build_debug -exec rm -rf {} \;
  find . -type d -name devel_debug -exec rm -rf {} \;
  find . -type d -name build_release -exec rm -rf {} \;
  find . -type d -name devel_release -exec rm -rf {} \;
  find . -type d -name install -exec rm -rf {} \;
}

alias cignore="touch CATKIN_IGNORE"
alias cnignore="rm CATKIN_IGNORE"

function catdisablemoveit
{
  declare -a moveit_packages=(
    "moveit_commander"
    "moveit_core"
    "moveit_experimental"
    "moveit_kinematics"
    "moveit_planners"
    "moveit_plugins"
    "moveit_ros"
    "moveit_runtime"
    "moveit_setup_assistant"
  )
  for (( i = 0; i < ${#moveit_packages[@]}; i++ ))
  do
    if [[ -d "${moveit_packages[i]}" ]]; then
      cd "${moveit_packages[i]}"
      cignore
      cd ..
    else
      echo "Could not find directory ${moveit_packages[i]}"
    fi
  done
}

function catenablemoveit
{
  declare -a moveit_packages=(
    "moveit_commander"
    "moveit_core"
    "moveit_experimental"
    "moveit_kinematics"
    "moveit_planners"
    "moveit_plugins"
    "moveit_ros"
    "moveit_runtime"
    "moveit_setup_assistant"
  )
  for (( i = 0; i < ${#moveit_packages[@]}; i++ ))
  do
    if [[ -d "${moveit_packages[i]}" ]]; then
      cd "${moveit_packages[i]}"
      cnignore
      cd ..
    else
      echo "Could not find directory ${moveit_packages[i]}"
    fi
  done
}
