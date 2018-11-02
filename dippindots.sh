#!/bin/bash
# Exit on any failure
set -e

DIR=$(pwd)

# =============== WELCOME =================================
read -rep "This will overwrite your existing dotfiles. Do you want to continue? (y/n) " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo -e "\nExiting..."
	exit 1
fi

read -rep "Do you want to install apps? (y/n) " -n 1
APPS=$REPLY


# ===============  OS CHECK  ================================
if [[ ! $(lsb_release -a 2>/dev/null | grep Ubuntu) ]]; then
	echo "DippinDots is meant for use with Ubuntu-based Linux distros. Goodbye!"
    exit 1
fi


# ===============  SETUP  ================================
bash setup/core.sh $DIR

if [[ ! $APPS =~ ^[Yy]$ ]]; then
    bash setup/apps $DIR
fi

sudo apt-get autoremove -y


# ===============  SYMLINK  =================================
echo "Symlinking dotfiles..."
bash setup/dots.sh $DIR


# ===============  FIN!  =================================
source ~/.bash_profile
echo "All done!"
