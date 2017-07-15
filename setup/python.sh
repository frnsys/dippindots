DIR=$1

tput setaf 5
echo "Installing Python3, pip, and virtualenv..."
tput sgr0

sudo apt -y install python3 python3-setuptools python-pip
sudo easy_install3 pip
sudo pip3 install virtualenv

# for vim syntax checking
sudo pip3 install pyflakes

# ipython config
mkdir -p ~/.ipython/profile_default
ln -sf $DIR/dots/ipython/ipython_config.py ~/.ipython/profile_default/ipython_config.py
