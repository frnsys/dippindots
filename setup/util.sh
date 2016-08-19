DIR=$1

tput setaf 5
echo -e "\nInstalling utilties..."
tput sgr0

sudo apt-get install --no-install-recommends dos2unix tmux curl jq gnupg htop wget dnsutils imagemagick nmap httpie silversearcher-ag -y
sudo pip install youtube-dl

git clone https://github.com/clvv/fasd.git /tmp/fasd
cd /tmp/fasd
sudo make install
cd $DIR
