#!/bin/bash
DIR=$(pwd)

# =============== WELCOME =================================
tput setaf 6
echo "Welcome to DippinDots, the dotfiles of the future!"
tput setaf 2
echo "Starting up..."
tput sgr0

tput setaf 3
read -rep "This will overwrite your existing dotfiles. Do you want to continue?. (y/n) " -n 1
tput sgr0
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo -e "\nExiting..."
	exit 1
fi

tput setaf 2
echo "Select which setup scripts you want to include:"
tput sgr0
declare -a available=(python ruby node vim nvim util math apps)
declare -a selections=()
for s in "${available[@]}"; do
    read -rep "Include ${s}? (y/n) " -n 1
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        selections=("${selections[@]}" "${s}")
    fi
done

# ===============  OS CHECK  ================================
tput setaf 4
echo -e "\nChecking OS..."
tput sgr0
if [[ $(lsb_release -a 2>/dev/null | grep Ubuntu) ]]; then
    tput setaf 3
    echo "Running setup for ~Ubuntu"
    tput sgr0

else
    tput setaf 1
	echo "DippinDots is meant for use with Ubuntu-based Linux distros. Goodbye!"
    tput sgr0
    exit 1
fi

# =============== GIT =================================
bash setup/git.sh $DIR

# If Git isn't installed by now, something messed up
if [[ ! "$(type -P git)" ]]; then
  tput setaf 1
  echo "Git should be installed. It isn't. Aborting."
  tput sgr0
  exit 1
fi

# ===============  SETUP  ===================================
tput setaf 5
echo "Running setup..."
tput sgr0
bash setup/pre.sh
for s in "${selections[@]}"; do
    bash setup/${s}.sh $DIR
done
sudo apt-get autoremove -y


# ===============  SYMLINK  =================================
tput setaf 5
echo "Symlinking dotfiles..."
tput sgr0

# Clear out old files
rm -rf ~/.vim

# Symlink files
ln -sf $DIR/vim ~/.vim
ln -sf $DIR/vim/vimrc ~/.vimrc
ln -sf $DIR/dots/bash/bash_profile ~/.bash_profile
ln -sf $DIR/dots/bash/bashrc ~/.bashrc
ln -sf $DIR/dots/bash/inputrc ~/.inputrc
ln -sf $DIR/bin ~/.bin
ln -sf $DIR/dots/tmux/tmux.conf ~/.tmux.conf

mkdir ~/.config/git
ln -sf $DIR/dots/gitignore ~/.config/git/ignore

if [ ! -f /etc/environment ]; then
    # Create an empty env file.
    echo "Creating an empty environment variables file at /etc/environment..."
    sudo touch /etc/environment
fi

# =============== FIN! =================================
source ~/.bash_profile
tput setaf 4
echo "All done!"
tput sgr0
