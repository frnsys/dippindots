DIR=$1

tput setaf 5
echo -e "\nInstalling utilties..."
tput sgr0

sudo apt-get install --no-install-recommends dos2unix curl jq gnupg htop wget dnsutils imagemagick nmap httpie silversearcher-ag -y
sudo pip install youtube-dl

# newer tmux
sudo apt-get install libevent1-dev -y
wget https://github.com/tmux/tmux/releases/download/2.3/tmux-2.3.tar.gz /tmp/tmux-2.3.tar.gz
cd /tmp
tar -xzvf tmux-2.3.tar.gz
cd tmux-*
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
