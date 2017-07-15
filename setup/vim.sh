DIR=$1

tput setaf 5
echo "Installing Vim..."
tput sgr0

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
