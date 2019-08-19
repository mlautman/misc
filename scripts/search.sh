#!/bin/bash -eu

## Helper Scripts for GREP / FIND

# Linux vs OSX Settings
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
  platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
  platform='osx'
fi

# Searching within files, recursive from current location
function gr {
  result="$( grep -I --color=always --ignore-case --line-number --recursive  "$1" . )"
  if [[ "$hide_match_numbers" = true ]] ; then
    echo "${result}"
  else
    echo "${result}" | awk '{ printf "%s \033[0;32m%s\033[0m\n", $0, NR }'
  fi
}
# Searching within files with case sensitivity, recursive from current location
function grcase {
  result="$( grep -I --color=always --line-number --recursive  "$1" . )"

  if [[ "$hide_match_numbers" = true ]] ; then
    echo "${result}"
  else
    echo "${result}" | awk '{ printf "%s \033[0;32m%s\033[0m\n", $0, NR }'
  fi
}
# Searching within file $2 only
function grf {
  grep -I --color=always --ignore-case --line-number "$1" "$2" ;
}
# Searching within files, recursive from current location, printing only the first match in a file
function grl {
  result="$( grep -I --color=always --ignore-case -l --recursive  "$1" . )"

  if [[ "$hide_match_numbers" = true ]] ; then
    echo "${result}"
  else
    echo "${result}" | awk '{ printf "%s\033[0;32m:: %s\033[0m\n", $0, NR }'
  fi
}
# Grep-Limited: Searching within files for $1, recursive from current location, excluding lines matching $2
# - Useful for filtering out '_test' or an extension
function grlim {
  result="$( (grep -I --color=always --ignore-case -l --recursive  "$1" . ) | grep -v $2 )"

  if [[ "$hide_match_numbers" = true ]] ; then
    echo "${result}"
  else
    echo "${result}" | awk '{ printf "%s\033[0;32m:: %s\033[0m\n", $0, NR }'
  fi
}
# Grep-Definition: Look for a line that looks like it declares a data structure $1
function grdef {
  result="$(
    grep -I --color=always --ignore-case --line-number --recursive  "class .*$1.* " .
    grep -I --color=always --ignore-case --line-number --recursive "struct .*$1.* {" .
    grep -I --color=always --ignore-case --line-number --recursive  "enum .*$1.* {" .
    grep -I --color=always --ignore-case --line-number --recursive  "message .*$1.* {" .
    grep -I --color=always --ignore-case --line-number --recursive  "service .*$1.* {" .
    grep -I --color=always --ignore-case --line-number --recursive  "using .*$1.* = " . )"

  if [[ "$hide_match_numbers" = true ]] ; then
    echo "${result}"
  else
    echo "${result}" | awk '{ printf "%s \033[0;32m%s\033[0m\n", $0, NR }'
  fi
}

# Grep-Header: Look for a line in a header file
function grh {
  result="$( grep -I --color=always --ignore-case --line-number --recursive  "$1" . | grep "\.h" )"

  if [ "$hide_match_numbers" = true ] ; then
    echo "${result}"
  else
    echo "${result}" | awk '{ printf "%s \033[0;32m%s\033[0m\n", $0, NR }'
  fi
}

# Exclude certain directories from grep. this doesn't work for osx
if [[ $platform != 'osx' ]]; then
  export UBUNTU_VERSION=`lsb_release --codename | cut -f2`
  #if [ "$UBUNTU_VERSION" = "xenial" ]; then
  alias grep="grep --color=auto --exclude-dir=\.hg --exclude-dir=\.git --exclude=\.#*"
  # else
  #     export GREP_OPTIONS="--color=auto --exclude-dir=\.hg --exclude-dir=\.git --exclude=\.#*"
  # fi
fi

# Find a file with a string and open with emacs (kinda like e gr STRING)
function gre {
  grep -l -I --ignore-case --recursive "$1" . | xargs e -nw -t ;
}

# Grep-Multiple: Returns a list of files, each file contains each search argument
# grmul foo bar bovik
function grmul {
  if [[ "$#" -lt 1 ]]; then
    echo "grmul requires at least 1 argument"
    return 1
  fi

  result="$( grep -I --ignore-case --files-with-matches --recursive "$1" )"

  for ((i=2; i<=$#; i++)); do
    result="$( echo "$result" | xargs grep --ignore-case --files-with-matches "${!i}" )"
  done

  if [[ "$hide_match_numbers" = true ]] ; then
    echo "${result}"
  else
    echo "${result}" | awk '{ printf "%s\033[0;32m:: %s\033[0m\n", $0, NR }' ;
  fi
}

# Find files with name in directory
function findfile {
  if [[ $platform != 'osx' ]]; then
    result="$( find -iname *$1* 2>/dev/null )"
    if [[ "$hide_match_numbers" = true ]] ; then
      echo "${result}"
    else
      echo "${result}" | awk '{ printf "%s\033[0;32m:: %s\033[0m\n", $0, NR }'
    fi
  else
    #find . -name '[mM][yY][fF][iI][lL][eE]*' # makes mac case insensitive
    echo "'*$1*'" |perl -pe 's/([a-zA-Z])/[\L\1\U\1]/g;s/(.*)/find . -name \1/'|sh
  fi
}

# Find files ignoring directories:
#find . -type d \( -path dir1 -o -path dir2 -o -path dir3 \) -prune -o -print

# Find files recursively by file type and copy them to a directory
#find . -name "*.rst" -type f -exec cp {} ~/Desktop/ \;

# Find files and delete them
#find -name *conflicted* -delete

# Also:
# find . -iname '*.so'

# Find and replace string in all files in a directory
#  param1 - old word
#  param2 - new word
function findreplace {
  grep -lr -e "$1" * | xargs sed -i "s/$1/$2/g" ;
}

function findreplacehidden {
  grep -lr -e "$1" | xargs sed -i "s/$1/$2/g" ;
}

function findreplacehiddenexcludegit {
  for f in $(find . -not -path '*/\.git*'); do
    grep --file=$f -lre "$1" | xargs sed -i "s/$1/$2/g" ;
  done
}

# interactive find and replace. Use for option to review changes before and after.
function findreplaceinteractive {

  case $3 in
    [matlab]* )
      echo "Searching matlab (*.m) files..."
      file_types="*.m";;
    * )
      echo "Searching all files..."
  esac

  # \unaliased, --include doesn't seem to work with the bash aliased version
  \grep -rw --color=auto --include=$file_types -e "$1" ./;

  read -p $'\e[36mDo you wish to replace these instances? (y/n): \e[0m' yn

  case $yn in
    [Yy]* ) echo -e "\e[36mContinuing...\e[0m";;
    [Nn]* ) echo -e "\e[31mAborting...\e[0m"
	    return;;
    *) echo "Please answer yes or no.";;
  esac

  # the \b ensures that partial matches aren't replaced.
  grep -lrw  --include=$file_types -e "$1" * | xargs sed -i "s/\b$1\b/$2/g";

  echo -e "\e[36mResults of Find & Replace operation:\e[0m"

  \grep -rw --color=auto --include=$file_types -e "$2" ./;
}

# Find replace string in all file NAMES in a directory recursively
function findreplacefilename {
  find . -depth -name "*$1*" -exec bash -c 'for f; do base=${f##*/}; mv -- "$f" "${f%/*}/${base//'$1'/'$2'}"; done' _ {} +
}

# Find installed programs in Ubuntu:
function findprogram {
  sudo find /usr -name "$1*" ;
}

# Remove all lines from files in a directory (not subfolders) containing a certain string
function findreplacelineswithstring {
  find . -type f -print0 | xargs -0 sed -i "/$1/d"
}

# Recursively find files with name $1 that contain text $2
function findfilegr {
  find . -name "$1" -exec grep -H "$2" {} +
}

# Grep-Edit: Open $1-th file printed by previous grep/findfile/search-related command
# - Filenames must have been printed to terminal by the previous command
# - Filenames must be at the beginning of lines and be followed by a : (followed by anything)
function gred {
  # "$(fc -ln -1)" Run last command
  # sed -n "$1p" Grab $1-th line from the last command's output
  # sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" Remove escape characters for color coding, etc
  # sed -rn 's/(([^:]*:){2}).*/\1/p' Grab text from start of line to second ":" inclusively so we open file at specific line number
  # e Open resulting filename in preferred editor
  $(e $(eval "$(fc -ln -1)" | sed -n "$1p" | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" | sed -rn 's/(([^:]*:){2}).*/\1/p'))
}
