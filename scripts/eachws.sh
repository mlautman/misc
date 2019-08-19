#!/bin/bash -eu

# Manage multiple git repos and/or catkin ws with these shortcuts

source $SCRIPT_BASE_PATH/scripts/colors.sh

export MY_ROS_Workspaces=(
  #$HOME"/ros/current/ws_ompl"
  #$HOME"/ros/current/ws_moveit"
  #$HOME"/ros/current/ws_acme"
  # $HOME"/ros/current/ws_swri"
  #$HOME"/ros/current/ws_acme_all"
)

function git_require_clean_work_tree  {
  # Update the index
  git update-index -q --ignore-submodules --refresh
  err=0

  # Disallow unstaged changes in the working tree
  if ! git diff-files --quiet --ignore-submodules --
    then
      # echo >&2 "cannot $1: you have unstaged changes."
      # git diff-files --name-status -r --ignore-submodules -- >&2
      err=1
  fi

  # Disallow uncommitted changes in the index
  if ! git diff-index --cached --quiet HEAD --ignore-submodules --; then
      #echo >&2 "cannot $1: your index contains uncommitted changes."
      #git diff-index --cached --name-status -r --ignore-submodules HEAD -- >&2
      err=1
  fi

  if [[ $err = 1 ]]; then
    #echo >&2 "Please commit or stash them."
    return 1
  fi
}

function commitGit
{
  #if git diff-index --quiet HEAD --; then
  if git_require_clean_work_tree; then
    echo "No changes detected in git repo"
  else
    echo ""
    echo "Changes have been detected in git repo:"
    echo "--------------------------------------------------------"
    echo -e "\e[00;1;95m"
    pwd
    parse_vc_branch_and_add_brackets
    echo -e "\e[00m"
    echo "--------------------------------------------------------"
    echo ""
    git status
    read -p "View git diff? (y/n): " resp
    if [[ "$resp" = "y" ]]; then
      echo ""
      git diff

      repo_name=`git rev-parse --show-toplevel`
      repo_name=`basename $repo_name`
      if [[ "$repo_name" = "iiwa_7_r800" ]]; then
	console_red
	echo "Not committing because acme"
	console_nored
	cd `pwd`
	return 1
      else
	read -p "Commit with gitall? (y/n): " resp
	if [[ "$resp" = "y" ]]; then
	  git add -A :/ && git commit -a && git push origin --all
          if [[ "$1" = "1" ]]; then
            echo "not prompting because at end of list"
          else
	    read -p "Continue? " resp
          fi
	fi
      fi
    fi
  fi
}

function compileWS
{
  #if catkin build --cmake-args -DCMAKE_BUILD_TYPE=Debug; then  # -j1
  if catbuild; then  # -j1
    echo "Compile succeeded"
    return 0
  else
    echo "Compile failed"
    return 1
  fi
}

function pullGit
{
  pwd
  repo_name=`git rev-parse --show-toplevel`
  repo_name=`basename $repo_name`
  if [[ "$repo_name" = "iiwa_7_r800" ]]; then
    echo "Not pulling because acme"
  else
    git pull
  fi
}

function checkBranch
{
  gitbranch=`git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\ \[\1\]/'`

  result=${PWD##*/}          # to assign to a variable
  echo -n $gitbranch
  echo -e -n "  \e[00;1;34m"
  printf '%s' "${PWD##*/}"
  echo -e "\e[00m"
}

function checkRemote
{
  echo -e -n "\e[00;1;34m"
  printf '%s' "${PWD##*/}"
  echo -e "\e[00m"
  git remote -v
}

# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
# ---------------------------------------------------------------------

function eachWs
{
  for i in "${MY_ROS_Workspaces[@]}"; do
    pushd "$i" >> /dev/null
    echo "Workspace: `pwd`"
    if eval "$1 $2"; then
      echo ""
      echo "------------------------------------------------------"
      echo "Command succeeded in workspace"
      echo ""
      popd >> /dev/null
    else
      red
      echo "Command '$1 $2' ended in workspace $i"
      console_nored
      #play -q $SCRIPT_BASE_PATH/config/emacs/failure.wav
      return 1
    fi
  done
  return 0 # success
}

function eachGit
{
  for x in `find \`pwd\` -name .git -type d -prune`; do
    pushd $x/../  >> /dev/null
    if eval "$1"; then
      echo ""
      popd >> /dev/null
    else
      red
      echo "Loop ended for each git"
      console_nored
      #play -q $SCRIPT_BASE_PATH/config/emacs/failure.wav >> /dev/null
      #popd >> /dev/null
      return 1
    fi
  done
  return 0 # success
}

# Shortcuts ---------------------------------------------

# alias eachws_pull="eachWs eachGit pullGit"
# alias eachws_branch="eachWs eachGit checkBranch"
# alias eachws_compile="eachWs compileWS"
# alias eachws_clean="eachWs catclean"

function eachgit_commit
{
  if eval "eachGit commitGit"; then
    pushd $SCRIPT_BASE_PATH  >> /dev/null
    commitGit 1
    popd >> /dev/null
  fi
}

function eachgit_pull
{
  eachGit pullGit
}

function eachgit_branch
{
  eachGit checkBranch
}

# Other commands:
# eachGit git_https_to_ssh
