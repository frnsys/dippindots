DIR=$1

tput setaf 5
echo "Installing Vim..."
tput sgr0

# Lua
sudo apt-get install lua5.1 liblua5.1-dev -y

# X11, allows using system clipboard with vim.
sudo apt-get install libx11-dev libxtst-dev libxt-dev libsm-dev libxpm-dev -y

# ctags
sudo apt-get install exuberant-ctags

# Python for the python interps
sudo apt-get install python-dev python3-dev -y

mkdir /tmp/vim && cd $_
wget ftp://ftp.ca.vim.org/pub/vim/unix/vim-7.4.tar.bz2
tar xvjf vim-7.4.tar.bz2
cd vim*
./configure --with-features=huge --enable-luainterp=yes --enable-pythoninterp=yes --enable-python3interp=yes --enable-gui=gtk2 --with-x --with-lua-prefix=/usr
make -s && sudo make install
cd $DIR

# Overwrite vi
sudo ln -sf /usr/local/bin/vim /usr/bin/vi
sudo ln -sf /usr/local/bin/vim /usr/bin/vim

# Jedi for jedi-vim (python completion)
sudo pip install jedi

# using vim-plug for plugin management
# it should auto-install plugins on first launch
