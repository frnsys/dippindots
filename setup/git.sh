DIR=$1

sudo add-apt-repository ppa:git-core/ppa -y
sudo apt-get update
sudo apt-get install git -y

mkdir ~/.config/git
ln -sf $DIR/dots/gitignore ~/.config/git/ignore
ln -sf $DIR/dots/gitconfig ~/.config

# so we can push without logging in
ssh -vT git@github.com
