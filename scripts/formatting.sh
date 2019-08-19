#!/bin/bash -eu

# Helpers for formatting code
function console_red {
  echo -n -e "\e[00;31m"
}
function console_nored {
  echo -n -e "\e[00m"
}

# Setup:
#   sagi clang-format-3.9  # already setup with emacsinstall
#   ln -s  $SCRIPT_BASE_PATH/.clang-format .clang-format
alias clang-format="clang-format-3.9"
function clang_this_directory_custom # recursive
{
  # Make sure no changes have occured in repo
  if ! git diff-index --quiet HEAD --; then
    # changes
    console_red
    read -p "You have uncommitted changes, are you sure you want to continue? (y/n)" resp
    console_nored

    if [[ "$resp" = "y" ]]; then
      echo "Formatting..."
    else
      return -1
    fi
  fi

  find . -name '*.h' -or -name '*.hpp' -or -name '*.cpp' -o -name '*.c' -o -name '*.cc' -o -name '*.proto' | xargs clang-format-3.9 -i -style=file $1
}

function autopep8_this_directory_custom # recursive
{
  # Make sure no changes have occured in repo
  if ! git diff-index --quiet HEAD --; then
    # changes
    console_red
    read -p "You have uncommitted changes, are you sure you want to continue? (y/n)" resp
    console_nored

    if [[ "$resp" = "y" ]]; then
      echo "Formatting..."
    else
      return -1
    fi
  fi

  find . -name '*.py' | xargs autopep8 --max-line-length 100 --in-place $1
}

# No .clang-format requried, assumes Google style
function clang_this_directory_google # recursive
{
  version=${1:-3.9}
  # Make sure no changes have occured in repo
  if ! git diff-index --quiet HEAD --; then
    # changes
    console_red
    read -p "You have uncommitted changes, are you sure you want to continue? (y/n)" resp
    console_nored

    if [ "$resp" = "y" ]; then
      echo "Formatting..."
    else
      return -1
    fi
  fi

  find . -name '*.h' -or -name '*.hpp' -or -name '*.cpp' -o -name '*.c' -o -name '*.cc' -o -name '*.proto' | xargs clang-format-$version -i -style=Google $1
}

# Recursively remove all whitespace from code-type files
function remove_trailing_whitespace_code_recursively {
  find . \( -name '*.h' -o -name '*.hpp' -o -name '*.cpp' -o -name '*.c' -o -name '*.markdown' -o -name '*.md' -o -name '*.xml' -o -name '*.m' -o -name '*.txt' -o -name '*.sh' -o -name '*.launch' -o -name '*.world' -o -name '*.urdf' -o -name '*.xacro' -o -name '*.py' -o -name '*.cfg' -o -name '*.msg' -o -name '*.yml' -o -name '*.yaml' -o -name '*.rst' -o -name '*.proto' \) -exec sed -i 's/ *$//' '{}' ';'
}

# Switch line ending types
function convert_window_to_linux_line_ending_recursively {
  read -p "WARNING THIS WILL CORRUPT MANY FILES WITHOUT BEING NOTICEABLE, TODO: choose which files to operate on. Continue?" $dummy
  find . -name "*" -type f -exec perl -pi -e 's/\r\n/\n/;' {}  \;
}

# Auto convert code to C++11
# Argument: directory of source code
function ctidy  {
  #run-clang-tidy.py -clang-tidy-binary=/opt/local/bin/clang-tidy-4.0 -fix -header-filter=src/ompl* -p=/home/$USER/ros/current/ws_moveit/build/moveit_core $1
  #run-clang-tidy-4.0.py -clang-tidy-binary=/usr/lib/llvm-4.0/bin/clang-tidy -fix -p=/home/$USER/ros/current/ws_moveit/build/moveit_core $1

  # rviz_visual_tools
  run-clang-tidy-4.0.py -clang-tidy-binary=/usr/lib/llvm-4.0/bin/clang-tidy -fix -p=/home/$USER/ros/current/ws_moveit/build/rviz_visual_tools $1
}
