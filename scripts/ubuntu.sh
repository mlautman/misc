#!/bin/bash -eu

# Auto install script for misc
#
# Please follow the Google Style Guide https://google.github.io/styleguide/shell.xml

# Exports
export UBUNTU_VERSION=`lsb_release --codename | cut -f2`

################################################################################
# Install general tools that can be used on all versions of Ubuntu
################################################################################

core_install()
{
  sudo apt -o Acquire::ForceIPv4=true install -y \
       git-core \
       ssh \
       colordiff \
       tree \
       bash-completion \
       less \
       lsb-release \
       iputils-ping
}

################################################################################
# Caps-lock to Caps-lock
################################################################################

setup_default_keyboard()
{
  echo "Resetting default keyboard settings to /etc/default/keyboard.bak"
  # If a keyboard backup config exists replace keyboard with the original. If not copy an unmapped one
  if [[ -f /etc/default/keyboard.bak ]]; then
    sudo cp /etc/default/keyboard.bak /etc/default/keyboard
  else
    echo "Currently no keyboard config backup exists. Creating one from your current /etc/default/keyboard."
    backup_keyboard_config
  fi
  gsettings reset org.gnome.desktop.input-sources xkb-options
}

################################################################################
# Caps lock to escape
################################################################################

setup_custom_keyboard_caps2esc()
{
  backup_keyboard_config
  this_session_reset_keyboard
  echo "Disabling capslock and replacing with escape"
  sudo cp ~/misc/config/keyboard/keyboard_caps2esc /etc/default/keyboard
  gsettings reset org.gnome.desktop.input-sources xkb-options

  # This session
  setxkbmap -option caps:escape
}

################################################################################
# Caps-lock to escape, Swapping super and ctrl
################################################################################

setup_custom_keyboard_caps2esc_ctrlsuperswap()
{
  backup_keyboard_config
  this_session_reset_keyboard
  echo "Disabling capslock and replacing with escape, also swapping super and ctrl"
  sudo cp ~/misc/config/keyboard/keyboard_caps2esc_ctrlSuperSwap /etc/default/keyboard
  gsettings reset org.gnome.desktop.input-sources xkb-options

  # This session
  setxkbmap -option caps:escape,ctrl:swap_rwin_rctl,ctrl:swap_lwin_lctl
}

################################################################################
# Caps-lock to control Ubuntu
################################################################################

setup_custom_keyboard_caps2ctrl()
{
  backup_keyboard_config
  this_session_reset_keyboard
  echo "Disabling caps lock and replacing with Ctrl"
  sudo cp ~/misc/config/keyboard/keyboard_caps2ctrl /etc/default/keyboard
  gsettings reset org.gnome.desktop.input-sources xkb-options

  # This session
  setxkbmap -option ctrl:nocaps
}

################################################################################
# Backs up /etc/default/keyboard if one doesn't exist.
################################################################################

backup_keyboard_config()
{
  # If on doesn't exist make a backup of original keyboard file
  if [[ ! -f /etc/default/keyboard.bak ]]; then
    sudo cp /etc/default/keyboard /etc/default/keyboard.bak
  fi
}

################################################################################
# resets current remaps and turns off caps-lock
################################################################################

this_session_reset_keyboard()
{
  # Turn off caps lock
  python ~/misc/config/keyboard/caps_lock_off.py
  # This session reset keyboard to no remaps
  setxkbmap -option
}

################################################################################
# Enforce computer sleep security policy
################################################################################

################################################################################
# OS Customizations for 16.04
################################################################################

ubuntu_16_install() # TODO(davetcoleman): i don't really like this config anymore
{
  sudo apt install -y xclip synaptic compizconfig-settings-manager || echo -e "\e[00;31mAPT-GET FAILED\e[00m"

  # Change Nautilus bookmarks
  rm -f ~/.config/user-dirs.dirs

  # Switch to natural scrolling
  gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true

  # Remove Screen Reader (Gnome Orca) because it can be accidentally enabled
  # when searching for screenshot tool and its very hard to turn off again
  sudo apt remove -y gnome-orca

  # Disable annoying update pop-up
  gsettings set com.ubuntu.update-notifier no-show-notifications true
}

################################################################################
# OS Customizations for 18.04
################################################################################

ubuntu_18_install()
{
  # Clipboard
  # Package manager
  # Disk space analyzer
  sudo apt install -y xclip synaptic baobab

  # Remove Screen Reader (Gnome Orca) because it can be accidentally enabled
  # when searching for screenshot tool and its very hard to turn off again
  sudo apt remove -y gnome-orca

  # Remove favorites from gnome3 dash except chrome
  gsettings set org.gnome.shell favorite-apps "['chrome.desktop']"

  # 12-hour format
  gsettings set org.gnome.desktop.interface clock-format 12h

  # Make windows switching not group program windows
  gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
  gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab', '<Alt>Above_Tab']"
  gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
  gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"

  # Mute all sound effects
  gsettings set org.gnome.desktop.sound event-sounds false

  # Script for installing extensions locally
  sudo wget -O /usr/local/bin/gnomeshell-extension-manage "https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/ubuntugnome/gnomeshell-extension-manage"
  sudo chmod +x /usr/local/bin/gnomeshell-extension-manage

  ## Install Extensions ---------------------------------
  # Get more extensions: https://extensions.gnome.org/

  # Window List
  # https://extensions.gnome.org/extension/602/
  gnomeshell-extension-manage --install --extension-id 602 --system

  # Altertab
  # gnomeshell-extension-manage --install --extension-id 15 --system

  # Caffeine
  # https://extensions.gnome.org/extension/517/
  gnomeshell-extension-manage --install --extension-id 517 --system

  # Sound input & ouput device choose
  gnomeshell-extension-manage --install --extension-id 906 --system

  # Show date
  gsettings set org.gnome.desktop.interface clock-show-date true

  # Disable annoying update pop-up
  gsettings set com.ubuntu.update-notifier no-show-notifications true

  # Restart gnome-shell
  gnome-shell --replace &
}

################################################################################
# Terminator is like, the best terminal
################################################################################

terminator_install()
{
  sudo apt install -y terminator || echo -e "\e[00;31mAPT-GET FAILED\e[00m"

  # xdotool simulates key bindings which we use to change terminator profiles (see verb.sh)
  sudo apt install -y xdotool || echo -e "\e[00;31mAPT-GET FAILED\e[00m"

  # setup configuration for terminator
  rm -rf $HOME/.config/terminator
  mkdir ~/.config/terminator
  if [ "$1" = "1" ]; then
    echo "Setting terminator to white background"
    ln -s $HOME/misc/config/terminator/config_white $HOME/.config/terminator/config
  else
    echo "Setting terminator to black background"
    ln -s $HOME/misc/config/terminator/config_dark $HOME/.config/terminator/config
  fi
  # make terminator default
  gsettings set org.gnome.desktop.default-applications.terminal exec 'terminator'

  # make terminator default for x-cinnamon windows manager
  #gsettings set org.cinnamon.desktop.default-applications.terminal exec /usr/bin/terminator

  # set terminator to auto start
  mkdir -p ~/.config/autostart
  cp ~/misc/install/ubuntu/autostart/terminator.desktop ~/.config/autostart/terminator.desktop
}

################################################################################
# Install Gnome 3 Ubuntu 16.04
################################################################################

gnome3_install()
{
  sudo apt install -y ubuntu-gnome-desktop gnome-tweak-tool

  # Remove Gnome stuff
  sudo apt --purge -y remove evolution evolution-plugins evolution-common gnome-calendar
  # Make workspaces synced between multiple monitors
  # http://gregcor.com/2011/05/07/fix-dual-monitors-in-gnome-3-aka-my-workspaces-are-broken/
  gsettings set org.gnome.shell.overrides workspaces-only-on-primary false

  # Remove favorites from gnome3 dash except chrome
  gsettings set org.gnome.shell favorite-apps "['chrome.desktop']"

  # 12-hour format
  gsettings set org.gnome.desktop.interface clock-format 12h

  # Make windows switching not group program windows
  gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
  gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab', '<Alt>Above_Tab']"
  gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
  gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"

  # Mute all sound effects
  gsettings set org.gnome.desktop.sound event-sounds false

  # Set timezone to Colorado
  sudo timedatectl set-timezone America/Denver

  # Extensions
  gnome_install_extensions
}

################################################################################
# Gnome extensions install Ubuntu 16.04
################################################################################

gnome_install_extensions()
{
  pushd .
  # Script for installing extensions
  TMP_DIR=$(mktemp -d)
  cd $TMP_DIR
  sudo wget -O /usr/local/bin/gnomeshell-extension-manage "https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/ubuntugnome/gnomeshell-extension-manage"
  sudo chmod +x /usr/local/bin/gnomeshell-extension-manage

  ## Install Extensions ---------------------------------
  # Get more extensions: https://extensions.gnome.org/

  # Application Menu
  gnomeshell-extension-manage --install --extension-id 6 --system
  # Window List
  gnomeshell-extension-manage --install --extension-id 602 --system
  # Altertab
  gnomeshell-extension-manage --install --extension-id 15 --system
  # Caffeine
  gnomeshell-extension-manage --install --extension-id 517 --system
  # No topleft hot corner
  gnomeshell-extension-manage --install --extension-id 118 --system
  # Sound input & ouput device choose
  gnomeshell-extension-manage --install --extension-id 906 --system
  # StatusNotifierItem/AppIndicator
  gnomeshell-extension-manage --install --extension-id 615 --system

  # Restart gnome-shell
  gnome-shell --replace &

  # OTHER SETTINGS
  # Show date
  gsettings set org.gnome.desktop.interface clock-show-date true

  # Titlebar buttons - Min Max
  gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"

  # Cleanup
  rm -rf $TMP_DIR
  popd
}

################################################################################
# Install Vim
################################################################################

vim_install()
{
  # vim
  sudo apt install -y vim-gnome || echo -e "\e[00;31mAPT-GET FAILED\e[00m"

  rm -rf ~/.vim ~/.vimrc
  ln -s  ~/misc/config/.vim ~/
  ln -s  ~/misc/config/.vim/.vimrc ~/.vimrc
  # Vundle
  rm -rf ~/misc/config/.vim/bundle/Vundle.vim
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall
}

################################################################################
# Qt creator for ros is a very powerful IDE to edit cpp code in ros workspace.
# Some features: autocompletion, search for any file, class, function, word
# and a lot of keyboard shortcuts for almost anything you want to do.
# You can create a ros workspace from scratch or you can open a pre-existing
# ros workspace. The only issue is that if there is no executable target for
# a file, it assigns random parsing context but you have the option to choose
# your own parser.
################################################################################

qtcreator_install()
{

  if [[ -n QtCreator ]]; then
    echo "Qt Creator is already installed"
    return
  else
    pushd .

    TMP_DIR=$(mktemp -d)
    cd $TMP_DIR

    wget https://qtcreator-ros.datasys.swri.edu/downloads/installers/bionic/qtcreator-ros-bionic-latest-online-installer.run
    chmod +x qtcreator-ros-bionic-latest-online-installer.run
    ./qtcreator-ros-bionic-latest-online-installer.run

    popd

    # Cleanup
    rm -rf $TMP_DIR
  fi
}

################################################################################
# Install Emacs
################################################################################

emacs_install()
{
  # emacs
  sudo apt install -y emacs emacs-goodies-el || echo -e "\e[00;31mAPT-GET FAILED\e[00m"

  # for use with emacs 'play' command for finishing compiling
  # and for code formatting
  sudo apt install -y sox clang-format-* || echo -e "\e[00;31mAPT-GET FAILED\e[00m"

  # Use sudo incase a file was edited with sudo with emacs and it already
  # created default folders (especially for .emacs.d, which contains auto file
  # backups)
  sudo rm -rf ~/emacs
  ln -s ~/misc/config/emacs ~/emacs
  sudo rm -rf ~/.emacs.d
  ln -s ~/misc/config/.emacs.d ~/.emacs.d
  sudo rm -rf ~/.emacs
  ln -s ~/misc/config/emacs/.emacs ~/.emacs

  # TODO: install yassnippet from source, because having it copied in misc would break it
  # when we upgraded emacs versions
  # TODO: use a fancier way for installing this emacs plugin, such as `package-install` or `el-get`
}

################################################################################
# Test a computer's performance against other computers using this easy tool
################################################################################

benchmark_install()
{
  sudo apt install -y hardinfo
  hardinfo -r
}

################################################################################
# Install Chrome
################################################################################

function chrome_install {
  # Check if already installed
  sudo apt install -y google-chrome-stable -qq
  if [[ ! $? ]]; then
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt update
    sudo apt install -y google-chrome-stable || echo -e "\e[00;31mAPT-GET FAILED\e[00m"
    sudo apt install -y chrome-gnome-shell || echo -e "\e[00;31mAPT-GET FAILED\e[00m"
  fi
  # set chrome to auto start
  mkdir -p ~/.config/autostart
  cp ~/misc/install/ubuntu/autostart/google-chrome-dave.desktop ~/.config/autostart/google-chrome-dave.desktop

  # GPI settings:
  # about:gpu

  # Fix scaling factor:
  # google-chrome –high-dpi-support=1 –force-device-scale-factor=1
}

################################################################################
# Install Slack Chat
# https://snapcraft.io/slack
################################################################################

slack_install()
{
  sudo snap install slack --classic

  # Alternate approach without snap
  # google-chrome https://slack.com/downloads/linux
}

################################################################################
# Install Spotify: http://www.spotify.com/us/download/previews/
################################################################################

spotify_install()
{
  # 1. Add the Spotify repository signing keys to be able to verify downloaded packages
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90

  # 2. Add the Spotify repository
  echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list

  # 3. Update list of available packages
  sudo apt update

  # 4. Install Spotify
  sudo apt install -y spotify-client
}

################################################################################
# Install Dropbox
################################################################################

dropbox_install()
{
  pushd .
  #google-chrome 'https://www.dropbox.com/install'

  # download dropbox
  TMP_DIR=$(mktemp -d)
  cd $TMP_DIR
  wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -

  # Install
  #sudo apt -y install nautilus-dropbox
  #nautilus --quit
  # Make dropbox auto start
  #mkdir -p ~/.config/autostart
  #cp ~/misc/install/ubuntu/autostart/dropbox.desktop ~/.config/autostart/dropbox.desktop

  # Start dropbox
  ~/.dropbox-dist/dropboxd &

  # The Linux version of the Dropbox desktop application is limited from monitoring more than 10000 folders by default. Anything over that is not watched and, therefore, ignored when syncing. There's an easy fix for this. Open a terminal and enter the following:
  #echo fs.inotify.max_user_watches=100000 | sudo tee -a /etc/sysctl.conf; sudo sysctl -p

  # Check if dropbox is running:
  #sudo service dropbox status

  # Symlinks for dropbox
  ln -s $HOME/Dropbox/Documents/2017 $HOME/2017
  #ln -s /media/dave/DataDrive/Dropbox/Documents/2016 $HOME/2016
  popd

  # Cleanup
  rm -rf $TMP_DIR
}

################################################################################
# Install flux
################################################################################

flux_install()
{
  # sudo add-apt-repository -y ppa:kilian/f.lux
  # sudo apt update
  # sudo apt install fluxgui -y || echo -e "\e[00;31mAPT-GET FAILED\e[00m"

  sudo apt install redshift redshift-gtk -y || echo -e "\e[00;31mAPT-GET FAILED\e[00m"
  # set redshift to auto start
  mkdir -p ~/.config/autostart
  cp ~/misc/install/ubuntu/autostart/redshift.desktop ~/.config/autostart/redshift.desktop

  # temp turn off redshift
  # pkill -USR1 redshift
}

################################################################################
# Install good image capturing and editing software
# Pinta: mspaint
# peek: advanced screenshots, including gifs!
# shutter: advanced screenshots including drawing on shreenshots before saving
# Gimp: photoshop
################################################################################

common_media_install()
{
  sudo apt install -y gimp vlc pinta openshot kazam

  # Make awesome gifs from sceenshots:
  sudo add-apt-repository -y ppa:peek-developers/stable
  sudo apt update
  sudo apt install peek -y

  # Improved static screenshots:
  sudo apt install shutter -y

  # Gimp config (makes it look more like photoshop)
  rm -f ~/.gimp-2.8
  ln -s ~/misc/config/.gimp-2.8/ ~/.gimp-2.8
}

################################################################################
# Custom Catkin commands
################################################################################

install_catkin_tools_config()
{
  # setup catkin_tools config
  mkdir -p ~/.config/catkin/verb_aliases
  ln -f -s ~/misc/config/catkin/01-custom-aliases.yaml ~/.config/catkin/verb_aliases/01-custom-aliases.yaml
}

################################################################################
# Install ROS Kinetic Ubuntu 16.04
################################################################################

install_ros_kinetic()
{
  pushd .
  TMP_DIR=$(mktemp -d)
  cd $TMP_DIR
  wget https://raw.githubusercontent.com/PickNikRobotics/quick-ros-install/master/ros_install.sh
  chmod 755 ./ros_install.sh
  ./ros_install.sh kinetic
  echo "Finished install ROS Kinetic"
  install_catkin_tools_config

  install_picknik_boilerplates

  # Cleanup
  rm -rf $TMP_DIR
  popd
}

################################################################################
# Install ROS2 Crystal Ubuntu 18.04
################################################################################

install_ros2_crystal()
{
  sudo apt install curl -y
  curl http://repo.ros2.org/repos.key | sudo apt-key add -
  sudo sh -c 'echo "deb [arch=amd64,arm64] http://repo.ros2.org/ubuntu/main `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'
  export ROS_DISTRO=crystal  # or ardent

  sudo apt update

  sudo apt install -y \
       ros-$ROS_DISTRO-desktop \
       python3-argcomplete \
       python3-pip

  pip3 install -U --user argcomplete

  install_picknik_boilerplates
}

################################################################################
# Install Lunar Ubunut 16.04 and 17.04
################################################################################

install_ros_lunar()
{
  pushd .
  TMP_DIR=$(mktemp -d)
  cd $TMP_DIR
  wget https://raw.githubusercontent.com/PickNikRobotics/quick-ros-install/master/ros_install.sh && chmod 755 ./ros_install.sh && ./ros_install.sh lunar
  install_catkin_tools_config
  install_picknik_boilerplates

  # Cleanup
  rm -rf $TMP_DIR
  popd
}

################################################################################
# Install ROS Melodic Ubutntu 18.04
################################################################################

install_ros_melodic()
{
  pushd .
  TMP_DIR=$(mktemp -d)
  cd $TMP_DIR
  wget https://raw.githubusercontent.com/PickNikRobotics/quick-ros-install/master/ros_install.sh
  chmod 755 ./ros_install.sh
  ./ros_install.sh melodic

  install_catkin_tools_config
  install_picknik_boilerplates

  # Cleanup
  rm -rf $TMP_DIR
  popd
}

################################################################################
# Install Bloom Github oauth access token for releasing ROS packages
################################################################################

install_ros_github_token()
{
  read -p "Your Github username: " gitUserName
  read -p "A Github oauth token for your account: " oAuthToken

  rm -f $HOME/.config/bloom
  cat <<EOF >> $HOME/.config/bloom
{
    "github_user": "$gitUserName",
    "oauth_token": "$oAuthToken"
}
EOF
}

################################################################################
# Install Gazebo 7 for Ubuntu
################################################################################

gazebo_install()
{
  pushd .
  sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
  TMP_DIR=$(mktemp -d)
  cd $TMP_DIR
  wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
  sudo apt update
  sudo apt install libgazebo7-dev -y

  # Cleanup
  rm -rf $TMP_DIR
  popd
}

################################################################################
# Install PickNik Boilerplates
################################################################################

install_picknik_boilerplates()
{
  echo "Installing PickNik Boilerplates"
  pushd .
  if [ ! -d "$HOME/ros" ]; then
    mkdir $HOME/ros
  fi
  cd $HOME/ros
  if [ ! -d "$HOME/ros/picknik_boilerplates" ]; then
    git clone git@github.com:PickNikRobotics/picknik_boilerplates.git
  fi
  cd $HOME
  popd
}

################################################################################
# Matlab: Documentation: https://help.ubuntu.com/community/MATLAB
################################################################################

matlab_install()
{
  pushd .
  # Create installation location and fix permssions so installation does not require sudo
  sudo mkdir /opt/matlab
  sudo chown $USER:$USER /opt/matlab

  #sudo apt install -y openjdk-6-jre icedtea-netx-common  || echo -e "\e[00;31mAPT-GET FAILED\e[00m"
  google-chrome 'http://www.mathworks.com/downloads/web_downloads/select_release?mode=gwylf'
  # 1. Go to mathworks website and download to start installation
  # 2. Unzip onto desktop in folder called `matlab`
  read -p "Press continue when ~/Desktop/matlab exists"
  cd ~/Desktop/matlab
  ./install
  # 3. Install matlab:
  #    - Install in /opt/matlab/.
  #    - Do not create symbolic links
  #    - GCC libraries - leave default
  read -p "Press continue when done installing"
  # 5. Install matlab-support
  sudo apt install -y matlab-support || echo -e "\e[00;31mAPT-GET FAILED\e[00m"
  popd

  # Note you may also need to run something like:
  # sudo chown dave:dave ~/.matlab/R2019a
  # you'll see this error by running
  # matlab -nodisplay
}

################################################################################
# Latex: use kile to edit. change pdf viewer to evince in kile
################################################################################

#latex_install() {
  #sudo apt install -y texlive-full lmodern texlive-fonts-recommended latex-beamer etoolbox kile
#}

################################################################################
# Install R
################################################################################

r_install()
{
  # ess = emacs mode for lots of stats languages
  # r-cran-rcmdr = R Commander
  sudo apt install -y r-base r-base-dev ess r-cran-rcmdr
}

################################################################################
# ecryptfs: install and encrypt the swap partition
################################################################################

ecryptfs_install()
{
  ~/misc/install/ubuntu/ecryptfs/ecryptfs_swap.sh
}


################################################################################
# VirtualBox 5.2 Install
################################################################################

virtualbox_install()
{
  pushd .
  # From https://www.virtualbox.org/wiki/Linux_Downloads
  TMP_DIR=$(mktemp -d)
  cd $TMP_DIR
  sudo sh -c "echo 'deb http://download.virtualbox.org/virtualbox/debian '$(lsb_release -cs)' contrib' > /etc/apt/sources.list.d/virtualbox.list"
  wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
  sudo apt update
  sudo apt install -y virtualbox-5.2 dkms

  # Cleanup
  rm -rf $TMP_DIR
  popd
}

################################################################################
# Install python tools
################################################################################

python_install()
{
  sudo apt install -y ipython python-numpy python-scipy python-matplotlib python-pep8 python-autopep8
}

################################################################################
# Install python3 tools
################################################################################

python3_install()
{
  sudo apt install -y ipython3 python3-numpy python3-scipy python3-matplotlib python3-pep8
}

################################################################################
# CREATE UNIQUE SSH KEY
################################################################################

setup_ssh_keys()
{
  # TODO(davetcoleman): check if keys already exist. if they do, prompt user to be sure they want to override them...
  #read -p "Do you really want to re-generate SSH keys? (y/n) " REGENERATE_KEYS
  #if [ "$REGENERATE_KEYS" == "y" ]; then

      sudo apt install -y openssh-server xclip || echo -e "\e[00;31mAPT-GET FAILED\e[00m"

      ssh-keygen -t rsa -b 4096 -C "$GITHUB_EMAIL"

      # Adding your SSH key to the ssh-agent
      eval "$(ssh-agent -s)"
      mkdir -p ~/.ssh
      ssh-add ~/.ssh/id_rsa

      # copy public key to various websites
      #cat ~/.ssh/id_rsa.pub | pbcopy  # OSX
      xclip -sel clip < ~/.ssh/id_rsa.pub # Linux

      google-chrome 'https://github.com/settings/ssh' &
      google-chrome 'https://bitbucket.org/' &
      echo "Your public SSH key has been copied to the clipboard - we recommend you add it to Github and optionally Bitbucket now."
      read -p "Press any key to continue."
  #fi
}

################################################################################
# Setup Hub and Gitlfs
################################################################################

hub_setup()
{
  echo "Running hub_setup"
  pushd .

  # alias | grep hub
  # unalias git  # git is an alias for hub in my config

  # Install Hub from precompiled binary
  if [[ "$UBUNTU_VERSION" = "xenial" || "$UBUNTU_VERSION" = "trusty" ]]; then
    TMP_DIR=$(mktemp -d)
    wget https://github.com/github/hub/releases/download/v2.10.0/hub-linux-amd64-2.10.0.tgz -O $TMP_DIR/hub.tgz
    cd $TMP_DIR
    tar xvfz hub.tgz
    cd hub-linux-amd64-2.10.0
    sudo ./install
    cd ~
    # Cleanup
    rm -rf $TMP_DIR
  elif [ "$UBUNTU_VERSION" = "xenial" ]; then
    sudo add-apt-repository ppa:cpick/hub -y
    sudo apt update -y -qq
    sudo apt install hub -y -qq
  elif [ "$UBUNTU_VERSION" = "bionic" ]; then
    sudo snap install hub --classic
  fi

  # Install Git-LFS
  TMP_DIR=$(mktemp -d)
  wget https://github.com/git-lfs/git-lfs/releases/download/v2.7.1/git-lfs-linux-amd64-v2.7.1.tar.gz -O $TMP_DIR/gitlfs.tar.gz
  cd $TMP_DIR
  tar -xvf gitlfs.tar.gz
  sudo ./install.sh
  cd ~

  # Cleanup
  rm -rf $TMP_DIR

  popd
}

################################################################################
# Setup Github
################################################################################

github_setup()
{
  echo "Running github_setup"
  # git is an alias for hub. ignore errors if there is no alias.
  #unalias git &>/dev/null

  # This should already be filled out
  if [ "$GITHUB_NAME" == "" ]; then
    read -p "Your name (e.g. John Doe): " GITHUB_NAME
  fi

  if [ "$GITHUB_EMAIL" == "" ]; then
    read -p "Email (e.g. email@domain.com) for use with Github:" GITHUB_EMAIL
  fi

  git config --global user.name "$GITHUB_NAME"
  git config --global user.email "$GITHUB_EMAIL"
  git config --global include.path "/home/$USER/misc/config/.gitconfig"
  git config --global alias.co checkout
  git config --global alias.br branch
  git config --global alias.ci commit
  git config --global alias.st status
  git config --global alias.cp cherry-pick
  git config --global alias.lg "log --pretty=format:'%C(yellow)Commit %H %n Author: %C(reset)%an  %ae %n Date:   %cd %n %n %w(80,4,4)%s %n %n %w(80,4,4)%b'" # git log: uses commit instead of author date
  git config --global alias.ll "log --pretty=format:'%C(yellow)%h %C(reset)%<(20,trunc)%an %<(6,trunc)%cr   %s'" # git log (line): tweak of git log --pretty=online
}

################################################################################
# Set up Verb Github and Gerrit
################################################################################

verb_install()
{
  pushd .
  read -p "Your name (e.g. John Doe): " GITHUB_NAME
  read -p "Verb Surgical USERNAME (e.g. USERNAME@verbsurgical.com, NOT EMAIL): " emailUserName
  git config --global user.name "$GITHUB_NAME"
  git config --global user.email "$emailUserName@verbsurgical.com"
  git config --global review.ssh://gerrit.verbsurgicaleng.com:29418/.username emailUserName

  ## SSH
  mkdir -p $HOME/.ssh
  cd $HOME/.ssh
  ssh-keygen -t rsa -b 2048 -C $(whoami)-$(date +%Y%m%d)-$(hostname)-verbeng -f id_rsa.$(hostname)-verbeng

  ## SSH Key
  # Preserve the blank line!
  mkdir -p $HOME/.ssh
  cat <<EOF >> $HOME/.ssh/config

Host gerrit.verbsurgicaleng.com
User $emailUserName
Port 29418
IdentityFile ~/.ssh/id_rsa.$(hostname)-verbeng
EOF

  gedit $HOME/.ssh/id_rsa.$(hostname)-verbeng.pub
  google-chrome "https://gerrit.verbsurgicaleng.com/g/#/dashboard/self"
  read -p "Now add key to Gerrit. Ready to test ssh?" $dummy
  ssh -p 29418 gerrit.verbsurgicaleng.com

  google-chrome "https://github.com/settings/keys"
  read -p "Now add to github"

  echo "Done with setup, now run verb_control_install_1"
  popd
}

################################################################################
# Install Docker
################################################################################

docker_install()
{
  # Install Docker
  sudo apt install -y curl
  curl -sSL https://get.docker.com/ | sh
  sudo usermod -aG docker $(whoami)
  # Test:
  sudo docker run hello-world
}

################################################################################
# Ccache is a useful tool for recompiling and making compiling faster see
# https://ccache.dev for more details
################################################################################

ccache_install()
{
  sudo apt install ccache
}


################################################################################
# Install sublime text editor
################################################################################

sublime_install()
{
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
  echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
  sudo apt update
  sudo apt install sublime-text
}

################################################################################
# Install protobuf from source because Ubuntu 16.04 does not have Protobuf 3
################################################################################

protobuf_install()
{
  # OR TRY: https://launchpad.net/~maarten-fonville/+archive/ubuntu/protobuf

  # Make sure you grab the latest version
  curl -OL https://github.com/google/protobuf/releases/download/v3.2.0/protoc-3.2.0-linux-x86_64.zip

  # Unzip
  unzip protoc-3.2.0-linux-x86_64.zip -d protoc3

  # Move protoc to /usr/local/bin/
  sudo mv protoc3/bin/* /usr/local/bin/

  # Move protoc3/include to /usr/local/include/
  sudo mv protoc3/include/* /usr/local/include/

  # Optional: change owner
  sudo chown dave /usr/local/bin/protoc
  sudo chown -R dave /usr/local/include/google
}

################################################################################
# Install scancode: a tool to find liscense within a codebase
################################################################################

scancode_install()
{
  # Scan A Project For Open Source Licenses
  #Copied from https://github.com/nexB/scancode-toolkit

  pushd .
  sudo apt install python-dev bzip2 xz-utils zlib1g libxml2-dev libxslt1-dev
  cd ~/Desktop
  mkdir scancode-toolkit
  cd scancode-toolkit
  wget https://github.com/nexB/scancode-toolkit/releases/download/v2.2.1/scancode-toolkit-2.2.1.zip
  unzip scancode-toolkit-2.2.1.zip
  cd scancode-toolkit-2.2.1
  ./scancode --help

  # Usage:
  #~/Desktop/scan_oss/scancode-toolkit-2.2.1/scancode --format html trajopt_ros/ result.html
  popd
}

################################################################################
# Install basic tools within a Docker container
################################################################################

install_min_command_line()
{
    # Basic unix stuff
    core_install

    # instead of emacsinstall
    sudo apt -o Acquire::ForceIPv4=true install -y emacs less ssh git-core bash-completion tree || echo -e "\e[00;31mAPT-GET FAILED\e[00m"

    github_setup

    # add ssh key
    ssh_install
}

################################################################################
# Install VMWare
################################################################################

vmware_install()
{
  # License keys: https://docs.google.com/document/d/1KdjolRQNgjQhTV8Nz7dEAPUL7pgLfPFJznFMKKIF4qg/edit

  # Download v15 (Andy's license)
  sudo apt install gnome-themes-standard

  google-chrome https://my.vmware.com/en/web/vmware/free#desktop_end_user_computing/vmware_workstation_player/15_0|PLAYER-1500|product_downloads
  read -p "Download to /Downloads folder. Press any key to continue"
  sudo sh VMware-Player-14.1.3-9474260.x86_64.bundle

  # Uninstall:
  #sudo vmware-installer -u vmware-player
}

################################################################################
# Install Transmission Torrent
################################################################################

transmission_install()
{
  sudo apt install transmission
}

################################################################################
# Desk break reminder
################################################################################

function workraveinstall()
{
  sudo apt-get install -y workrave || echo -e "\e[00;31mAPT-GET FAILED\e[00m"

  # Add workrave configuration
  ln -s ~/misc/config/.workrave/workrave.ini ~/.workrave/workrave.ini

  # set workrave to auto start
  # TODO: delete autostart file
  # REMOVED(dave) - I think this was causing a duplicate start "Is Workrave already running?"
  #mkdir -p ~/.config/autostart
  #cp ~/misc/install/ubuntu/autostart/workrave.desktop ~/.config/autostart/workrave.desktop
}

################################################################################
# Open source computer aided design
################################################################################

freecad_install()
{
  # https://www.freecadweb.org/wiki/Install_on_Unix#Stable_PPA_with_GUI
  sudo add-apt-repository ppa:freecad-maintainers/freecad-stable
  sudo apt update
  sudo apt install freecad freecad-doc && sudo apt upgrade
}

################################################################################
# Ensure environment variables are set otherwise strict bash script will fail
################################################################################

check_env_variables_set()
{
  if [ -n "${BASHRC_ENV-}" ]; then # not empty
    # nothing
    echo -n ""
  else # unset, create default value
    BASHRC_ENV=''
  fi

  if [ -n "${BASHRC_NAME-}" ]; then # not empty
    # nothing
    echo -n ""
  else # unset, create default value
    BASHRC_NAME=''
  fi
}

