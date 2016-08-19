DIR=$1

tput setaf 5
echo "Installing Neovim..."
tput sgr0

sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim
pip install neovim

# Jedi for jedi-vim (python completion)
sudo pip install jedi

# Reuse vim stuff for neovim
ln -sf $DIR/vim ~/.nvim
ln -sf $DIR/vim/vimrc ~/.nvimrc
