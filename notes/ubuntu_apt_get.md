# Ubuntu Apt-Get Commands

## Fix broken apt-get

    see apt_get_repair.sh

## Clear old kernals from boot drive to make space for new ones

See current kernel:

    uname -r

Delete older ones from:

    cd /boot
    ls -lah .
    rm *3.19.0-51*  (or whatever version)

### Auto:

    sudo apt-get autoremove --purge

## See where files are installed from debian

    dpkg -L DEBIAN_PKG_NAME

## See package version number

    dpkg -l DEBIAN_PKG_NAME

## Fix Broken Dependencies

    http://askubuntu.com/questions/140246/how-do-i-resolve-unmet-dependencies-after-adding-a-ppa

## See what packages are installed

    apt-cache policy PACKAGE_NAME

## If apt-get running slow, disable ipv6

    sudo apt-get -o Acquire::ForceIPv4=true update

Or other commands beyond ``update``

## Remove an apt repository

    cd /etc/apt/sources.list.d

Then delete the stuff

## Find where a file was installed from:

https://superuser.com/questions/10997/find-what-package-a-file-belongs-to-in-ubuntu-debian

    dpkg -S /usr/bin/ls
