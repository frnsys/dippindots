DIR=$1

tput setaf 5
echo "Installing Python2, Python3, pip, and virtualenv..."
tput sgr0

sudo apt-get install python3 python-pip -y
sudo pip install virtualenv

sudo apt-get install python3-setuptools -y
sudo easy_install3 pip
sudo pip3 install virtualenv

# the following are required for some python libraries
sudo apt-get install libsqlite3-dev libbz2-dev tk8.6-dev libffi-dev libssl-dev

# build from source with shared libraries
PYVERSION=3.5.2
wget https://www.python.org/ftp/python/${PYVERSION}/Python-${PYVERSION}.tar.xz -O /tmp/Python-${PYVERSION}.tar.xz
cd /tmp
tar xfv Python-${PYVERSION}.tar.xz
cd Python-${PYVERSION}
./configure --prefix=/usr/local --enable-shared

# make this way so the binary knows where to find the shared libs
LD_RUN_PATH=/usr/local/lib make
sudo make install

# for vim syntax checking
sudo pip3.5 install pyflakes

# ipython config
mkdir -p ~/.ipython/profile_default
ln -sf $DIR/dots/ipython/ipython_config.py ~/.ipython/profile_default/ipython_config.py
