#!/bin/bash -eu

# Shortcuts for using git

## Maintain workspaces
source $SCRIPT_BASE_PATH/scripts/eachws.sh

# Use hub if available
if hash hub 2>/dev/null; then
  alias git=hub
fi

#https://github.com/davetcoleman/moveit_ros/tree/add-joystick-interface
#https://bitbucket.org/davetcoleman/moveit_ros/branch/all_dev_combined_indigo

function gitsync
{
  git fetch --all
  git rebase origin/master
}

function gitall
{
  git diff
  read -p "Continue?"
  git add -A :/
  git commit -a
}

# Stages all modified and deleted files which are tracked
alias gitau='git add -u'
alias gitb='git branch'
alias gitbsort='git branch --sort=-committerdate' # list branches chronologically by last commit (most to least recent)
alias gitca='git commit --amend'
alias gitcan='git commit --amend --no-edit'
alias gitdiff='GIT_PAGER="" git diff --color-words'  # show the diff for unstaged files
alias gitdiffc='gitdiff --cached'  # show the diff for staged files
alias gitdiffa='gitdiff HEAD'  # show the diff for unstaged and staged files
alias gitdstat='git diff --stat' # show diffstat
alias gitdno='git diff --name-only' # list files modified
alias gitdno1="gitdno HEAD^" # git diff name-only @~1
alias gitdlist1="gitdlist HEAD^"
alias gitdstat1="gitdstat HEAD^"
alias gitlg='git lg -p' # generate patches
alias gitorigin='git remote show -n origin'
alias gitreadme='git commit README.md -m "Updated README" && git push'
alias gitr='git remote -v'
alias gitst='git status'

alias gti='git'
alias gtist='git status'
alias gtica='git commit --amend'
alias gtican='git commit --amend --no-edit'
alias gtidiff='GIT_PAGER="" git diff --color-words'  # show the diff for unstaged files
alias gtib='git branch'
alias gtidiff='GIT_PAGER="" git diff --color-words'  # show the diff for unstaged files
alias gtir='git remote -v'

alias gitlogcompare="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative "
alias gitlogcompare_hydro_indigo="gitlogcompare hydro-devel..indigo-devel"
alias gitlogcompare_indigo_hydro="gitlogcompare indigo-devel..hydro-devel"

# copy last commit hash to clipboard
alias git_commit_to_clipboard="git log --pretty=format:'%h' -n 1 | xclip -sel clip"

alias gitremoteswich="git remote rename origin upstream"


# Git Diff List: list all changed files in 1 line
# "gitdlist | xargs subl -n" opens all modified files in a new sublime window for easy reviewing
function gitdlist {
  rev=${1:-HEAD}
  git diff $rev --name-only | tr "\n" " " | xargs echo ""
}

function gitamend
{
  git diff
  read -p "Continue to amend?"
  git commit -a --amend
}

function gitrebasei
{
  git rebase -i HEAD~10
}

function gitautosquash
{
  git rebase -i HEAD~20 --autosquash
}

# Find all git repos in pwd and run 'git pull'
function git_pull_all
{
  original_location=$(pwd);

  for x in `find \`pwd\` -name .git -type d -prune`; do
    cd $x
    cd ../
    echo "--------------------------------------------------------"
    echo -e "\e[00;1;95m"
    pwd
    parse_vc_branch_and_add_brackets
    echo -e "\e[00m"

    if git pull; then
      echo "Pull successfull"
    else
      read -p "Error. Continue?" resp
    fi
    echo "--------------------------------------------------------"
  done

  cd $original_location
  echo ""
  echo "Finished pulling all ROS repos!"
  echo ""
}


# change git ssh to https
function git_ssh_to_https {
  #-- Script to automate https://help.github.com/articles/why-is-git-always-asking-for-my-password

  REPO_URL=`git remote -v | grep -m1 '^origin' | sed -Ene's#.*(git@[^[:space:]]*).*#\1#p'`
  if [[ -z "$REPO_URL" ]]; then
    echo "-- ERROR:  Could not identify Repo url."
    echo "   It is possible this repo is already using SSH instead of HTTPS."
    return
  fi

  USE_BITBUCKET=false
  USER=`echo $REPO_URL | sed -Ene's#git@github.com:([^/]*)/(.*).git#\1#p'`
  if [[ -z "$USER" ]]; then
    USER=`echo $REPO_URL | sed -Ene's#git@bitbucket.org:([^/]*)/(.*).git#\1#p'`
    USE_BITBUCKET=true
    if [[ -z "$USER" ]]; then
      echo "-- ERROR:  Could not identify User."
      return
    fi
  fi

  REPO=`echo $REPO_URL | sed -Ene's#git@github.com:([^/]*)/(.*).git#\2#p'`
  if [[ -z "$REPO" ]]; then
    REPO=`echo $REPO_URL | sed -Ene's#git@bitbucket.org:([^/]*)/(.*).git#\2#p'`
    if [[ -z "$REPO" ]]; then
      echo "-- ERROR:  Could not identify Repo."
      return
    fi
  fi

  if [ "$USE_BITBUCKET" = true ]; then
    NEW_URL="https://bitbucket.org/$USER/$REPO.git"
  else
    NEW_URL="https://github.com/$USER/$REPO.git"
  fi
  echo "Changing repo url from "
  echo "  '$REPO_URL'"
  echo "      to "
  echo "  '$NEW_URL'"
  echo ""

  CHANGE_CMD="git remote set-url origin $NEW_URL"
  `$CHANGE_CMD`

  echo "Success"
}

# change git https to ssh
function git_https_to_ssh {
  #-- Script to automate https://help.github.com/articles/why-is-git-always-asking-for-my-password
  echo "Attempting to switch git repo from https to ssh"

  REPO_URL=`git remote -v | grep -m1 '^origin' | sed -Ene's#.*(https://[^[:space:]]*).*#\1#p'`
  if [[ -z "$REPO_URL" ]]; then
    echo "-- ERROR:  Could not identify Repo url."
    echo "   It is possible this repo is already using SSH instead of HTTPS."
    return
  fi
  echo "REPO_URL: $REPO_URL"

  USE_BITBUCKET=false
  USER=`echo $REPO_URL | sed -Ene's#https://github.com/([^/]*)/(.*)#\1#p'`
  if [[ -z "$USER" ]]; then
    USER=`echo $REPO_URL | sed -Ene's#https://bitbucket.org/([^/]*)/(.*)#\1#p'`
    USE_BITBUCKET=true
    if [[ -z "$USER" ]]; then
      echo "-- ERROR:  Could not identify User."
      return
    fi
  fi

  REPO=`echo $REPO_URL | sed -Ene's#https://github.com/([^/]*)/(.*)#\2#p'`
  if [[ -z "$REPO" ]]; then
    REPO=`echo $REPO_URL | sed -Ene's#https://bitbucket.org/([^/]*)/(.*)#\2#p'`
    if [[ -z "$REPO" ]]; then
      echo "-- ERROR:  Could not identify Repo."
      return
    fi
  fi

  if [[ "$USE_BITBUCKET" = true ]]; then
    NEW_URL="git@bitbucket.org:$USER/$REPO"
  else
    NEW_URL="git@github.com:$USER/$REPO"
  fi
  echo "Changing repo url from "
  echo "  '$REPO_URL'"
  echo "      to "
  echo "  '$NEW_URL'"
  echo ""

  CHANGE_CMD="git remote set-url origin $NEW_URL"
  `$CHANGE_CMD`

  echo "Success"
}

function git_https_to_ssh_all {
  for d in */ ; do
    echo "$d"
    cd "$d"
    git_https_to_ssh
    cd ..
  done
}

function git_stash_all {
  for d in */ ; do
    echo "$d"
    cd "$d"
    git stash
    cd ..
  done
}

alias vcss="vcs status"

# Show what git or hg branch we are in
function parse_vc_branch_and_add_brackets {
  gitbranch=`git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\ \[\1\]/'`

  if [[ "$gitbranch" != '' ]]; then
    echo $gitbranch
  else
    hg branch 2> /dev/null | awk '{print $1 }'
  fi
}

# Opens the github page for the current git repository in your browser.
# Can pass in argument for which remote to use, defaults to 'origin'
function gh {
  gitremote="$1"
  if [[ "$1" == "" ]]; then
    gitremote="origin";
  fi

  giturl=$(git config --get remote.$gitremote.url)
  if [[ "$giturl" == "" ]]; then
    echo "Not a git repository or no remote.origin.url set"
    return
  fi

  giturl=${giturl/git\@github\.com\:/https://github.com/}
  #giturl=${giturl/\.git/\/tree}
  giturl=${giturl/\.git/}
  branch="$(git symbolic-ref HEAD 2>/dev/null)" ||
  branch="(unnamed branch)"     # detached HEAD
  branch=${branch##refs/heads/}
  #giturl=$giturl/$branch
  giturl=$giturl

  if [[ $platform != 'osx' ]]; then
    xdg-open $giturl # linux
  else
    open $giturl # mac
  fi
}

# Opens BitBucket page
function bb {
  gitremote="$1"
  if [[ "$1" == "" ]]; then
    gitremote="origin";
  fi

  giturl=$(git config --get remote.$gitremote.url)
  if [[ "$giturl" == "" ]]; then
    echo "Not a git repository or no remote.origin.url set"
    return
  fi

  giturl=${giturl/git\@bitbucket\.org\:/https://bitbucket.org/}
  giturl=${giturl/\.git/\/commits\/branch}
  branch="$(git symbolic-ref HEAD 2>/dev/null)" ||
  branch="(unnamed branch)"     # detached HEAD
  branch=${branch##refs/heads/}
  giturl=$giturl/$branch

  if [[ $platform != 'osx' ]]; then
    xdg-open $giturl # linux
  else
    open $giturl # mac
  fi
}

# Show git branch at prompt:
export PS1="\[\033[34m\][\h]\[\033[0m\]\[\033[0;32m\]\$(parse_vc_branch_and_add_brackets)\[\033[0m\] \W$ "

function git_add_me
{
  git remote add $BASHRC_NAME
}

function git_make_me_origin
{
  echo -e -n "\e[00;1;34m"
  echo "This function is deprecated. Instead use git_remote_add_me or directly:"
  echo -e "\e[00m"
  echo "   git remote add USERNAME"
  echo -e -n "\e[00;1;34m"
  echo ""
  echo "Hub will magically add your remote for Github"
  echo -e "\e[00m"

  git remote -v
}

function git_remote_add_me
{
  git remote add $BASHRC_NAME
  git remote -v
}

# Find replace string in all file NAMES in a directory recursively
function gitfindreplacefilename {
  find . -depth -name "*$1*" -exec bash -c 'for f; do base=${f##*/}; git mv -- "$f" "${f%/*}/${base//'$1'/'$2'}"; done' _ {} +
}

# Runs aspell on modified lines which are // comments and aggregates the response
function gitspell {
  # grep -E "\+\s*//|\+\s*#|\+\s*\"\"\"" Get added lines that contain either //, #, or """
  # sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" Remove escape characters for color coding, etc
  # sed 's_^[/+ ]*__' Remove git formatting and leading // and whitespace
  # aspell -a --dont-suggest Run aspell suppressing suggestions to keep things clean
  # sed -r '/^.{,2}$/d' Remove apell's blank formatting lines aspell puts around
  # sed -rn 's/([^0-9]*).*/\1/p' Remove additional aspell formatting
  # awk '!a[$0]++' Removes duplicates
  rev=${1:-HEAD}
  git diff $rev --no-ext-diff --unified=0 --exit-code -a --no-prefix | grep -E "\+\s*//|\+\s*#|\+\s*\"\"\"" | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" | sed 's_^[/+ ]*__' | aspell -a --dont-suggest | sed -r '/^.{,2}$/d' | sed -rn 's/([^0-9]*).*/\1/p' | awk '!a[$0]++'
}

# Adds $1 to the aspell dictionary
function gitspelladd {
  echo -e "*$1\n#" | aspell -a
}
