DIR=$1

sudo add-apt-repository ppa:git-core/ppa -y
sudo apt update
sudo apt install -y git

mkdir -p ~/.config/git
ln -sf $DIR/dots/gitignore ~/.config/git/ignore
ln -sf $DIR/dots/gitconfig ~/.gitconfig

# so we can push without logging in
ssh -vT git@github.com
