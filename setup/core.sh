#!/bin/bash
# Exit on any failure
set -e

DIR=$1

echo "Installing prereqs..."
sudo apt update
sudo apt upgrade -y
sudo apt install -y --no-install-recommends python python-pip gcc gfortran build-essential g++ make cmake autoconf wget unzip git openssh-server software-properties-common libncurses5-dev libxml2-dev libxslt1-dev libyaml-dev bzip2 curl python-dev libsqlite3-dev

echo "Installing nvm/node..."
sudo pip install libsass
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
nvm install node

echo "Installing git..."
sudo add-apt-repository ppa:git-core/ppa -y
sudo apt update
sudo apt install -y git

curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt install -y git-lfs
git lfs install

mkdir -p ~/.config/git
ln -sf $DIR/dots/git/gitignore ~/.config/git/ignore
ln -sf $DIR/dots/git/gitconfig ~/.gitconfig

# so we can push without logging in
ssh -vT git@github.com

echo "Installing fzf..."
echo "Say NO to auto-completion for performance"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

sudo apt install -y --no-install-recommends wget silversearcher-ag

# rust & fd
curl -sf -L https://static.rust-lang.org/rustup.sh | sh
source ~/.cargo/env
cargo install fd-find ripgrep


echo "Installing math libs..."
sudo apt install -y libatlas-base-dev liblapack-dev libopenblas-dev libopenblas-base libatlas3-base


echo "Installing Python3..."
sudo apt -y install python3 python3-setuptools python-pip python3-pip

# pyenv for easier version management
sudo apt -y install tk-dev
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv

# activate pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

# install python
env PYTHON_CFLAGS=-fPIC PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 3.6.6
pyenv global 3.6.6

# for vim syntax checking
# make sure this installs under the installed pyenv
pip install pyflakes

# ipython config
mkdir -p ~/.ipython/profile_default
ln -sf $DIR/dots/misc/ipython_config.py ~/.ipython/profile_default/ipython_config.py


echo "Installing Vim..."
# Lua, python interps, and X11/system clipboard support
sudo apt install -y \
    lua5.1 liblua5.1-dev \
    python-dev python3-dev \
    libx11-dev libxtst-dev libxt-dev libsm-dev libxpm-dev

mkdir /tmp/vim && cd $_
wget https://github.com/vim/vim/archive/v8.0.1489.zip
unzip v*.zip
cd vim*
./configure --with-features=huge --enable-luainterp=yes --enable-pythoninterp=yes --enable-python3interp=yes --enable-gui=no --with-x --with-lua-prefix=/usr
make -s && sudo make install
cd $DIR

# Overwrite vi
sudo ln -sf /usr/local/bin/vim /usr/bin/vi
sudo ln -sf /usr/local/bin/vim /usr/bin/vim
sudo ln -sf /usr/bin/vim /etc/alternatives/editor

# mypy for python type annotations
sudo pip3 install mypy

# config
rm -rf ~/.vim
ln -sf $DIR/vim ~/.vim
ln -sf $DIR/vim/vimrc ~/.vimrc

# minpac for plugin management
mkdir -p ~/.vim/pack/minpac/opt
git clone https://github.com/k-takata/minpac.git ~/.vim/pack/minpac/opt/minpac
