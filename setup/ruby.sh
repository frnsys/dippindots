tput setaf 5
echo "Installing Ruby and Sass..."
tput sgr0

sudo apt-get install ruby ruby-dev -y
gem install sass
