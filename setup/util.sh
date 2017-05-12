DIR=$1

tput setaf 5
echo -e "\nInstalling utilties..."
tput sgr0

sudo apt-get install --no-install-recommends dos2unix curl jq gnupg htop wget dnsutils imagemagick nmap httpie silversearcher-ag -y
sudo pip install youtube-dl

# newer tmux
sudo apt-get install libevent-dev -y
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
