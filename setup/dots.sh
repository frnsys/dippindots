DIR=$1

# Symlink files
ln -sf $DIR/dots/bash/bash_profile ~/.bash_profile
ln -sf $DIR/dots/bash/bashrc ~/.bashrc
ln -sf $DIR/dots/bash/inputrc ~/.inputrc
ln -sf $DIR/bin ~/.bin
ln -sf $DIR/dots/tmux/tmux.conf ~/.tmux.conf

# Check for environment file
# NOTE: I have mine backed up in ~/docs
if [ ! -f /etc/environment ]; then
    # Create an empty env file.
    echo "Creating an empty environment variables file at /etc/environment..."
    sudo touch /etc/environment
fi
