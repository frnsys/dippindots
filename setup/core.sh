DIR=$1

echo "Installing prereqs..."
sudo apt update
sudo apt upgrade -y
sudo apt install -y --no-install-recommends python gcc gfortran build-essential g++ make cmake autoconf wget git openssh-server python-software-properties software-properties-common libncurses5-dev libxml2-dev libxslt1-dev libyaml-dev bzip2 curl python-dev libsqlite3-dev

sudo pip install libsass
sudo apt install -y nodejs npm


echo "Installing git..."
sudo add-apt-repository ppa:git-core/ppa -y
sudo apt update
sudo apt install -y git

mkdir -p ~/.config/git
ln -sf $DIR/dots/gitignore ~/.config/git/ignore
ln -sf $DIR/dots/gitconfig ~/.gitconfig

# so we can push without logging in
ssh -vT git@github.com

# If Git isn't installed by now, something messed up
if [[ ! "$(type -P git)" ]]; then
  tput setaf 1
  echo "Git should be installed. It isn't. Aborting."
  tput sgr0
  exit 1
fi


echo "Installing utils..."
sudo apt install -y libevent-dev
wget https://github.com/tmux/tmux/releases/download/2.4/tmux-2.4.tar.gz -O /tmp/tmux-2.4.tar.gz
cd /tmp
tar -xzvf tmux-2.4.tar.gz
cd tmux-2.4
./configure
make
sudo make install
cd $DIR

git clone https://github.com/clvv/fasd.git /tmp/fasd
cd /tmp/fasd
sudo make install
cd $DIR

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

sudo apt install -y --no-install-recommends wget silversearcher-ag

# rust & fd
curl -sf -L https://static.rust-lang.org/rustup.sh | sh
cargo install fd-find


echo "Installing math libs..."
sudo apt install -y libatlas-base-dev liblapack-dev libopenblas-dev libopenblas-base libatlas3-base


echo "Installing Python3, pip, and virtualenv..."
sudo apt -y install python3 python3-setuptools python-pip
sudo easy_install3 pip
sudo pip3 install virtualenv

# for vim syntax checking
sudo pip3 install pyflakes

# ipython config
mkdir -p ~/.ipython/profile_default
ln -sf $DIR/dots/ipython/ipython_config.py ~/.ipython/profile_default/ipython_config.py


echo "Installing Vim..."
sudo apt install -y \
    # Lua
    lua6.1 liblua5.1-dev \
    # ctags
    exuberant-ctags \
    # for the python interps
    python-dev python3-dev \
    # X11, allows using system clipboard with vim.
    libx11-dev libxtst-dev libxt-dev libsm-dev libxpm-dev

mkdir /tmp/vim && cd $_
wget ftp://ftp.ca.vim.org/pub/vim/unix/vim-8.0.tar.bz2
tar xvjf vim-*.tar.bz2
cd vim*
./configure --with-features=huge --enable-luainterp=yes --enable-pythoninterp=yes --enable-python3interp=yes --enable-gui=no --with-x --with-lua-prefix=/usr
make -s && sudo make install
cd $DIR

# Overwrite vi
sudo ln -sf /usr/local/bin/vim /usr/bin/vi
sudo ln -sf /usr/local/bin/vim /usr/bin/vim

# Jedi for jedi-vim (python completion)
sudo pip install jedi

# config
rm -rf ~/.vim
ln -sf $DIR/vim ~/.vim
ln -sf $DIR/vim/vimrc ~/.vimrc

# using vim-plug for plugin management
# it should auto-install plugins on first launch
