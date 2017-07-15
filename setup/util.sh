DIR=$1

tput setaf 5
echo -e "\nInstalling utilties..."
tput sgr0

sudo apt install -y --no-install-recommends dos2unix curl jq gnupg htop wget dnsutils imagemagick nmap httpie silversearcher-ag
sudo pip install youtube-dl

# newer tmux
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
