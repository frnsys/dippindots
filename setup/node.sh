DIR=$1

if [[ ! "$(type -P node)" ]]; then
    tput setaf 5
    echo "Installing Node..."
    tput sgr0

    mkdir /tmp/nodejs && cd $_
    wget -N http://nodejs.org/dist/node-latest.tar.gz
    tar xzvf node-latest.tar.gz && cd `ls -rd node-v*`
    ./configure
    sudo make install -s
    cd $DIR
else
    tput setaf 2
    echo "Node found! Moving on..."
    tput sgr0
fi
