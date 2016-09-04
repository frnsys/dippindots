# DippinDots

These are my personal dotfiles for Linux (Lubuntu).
Please feel free to use/modify them as you like!

You should also have your Github SSH keys (`id_rsa` and `id_rsa.pub`) in
`~/.ssh/` so login-less (SSH) Github access can be setup. You may need
to set proper permissions:

    chmod 700 ~/.ssh
    chmod 644 ~/.ssh/id_rsa.pub
    chmod 600 ~/.ssh/id_rsa
    chmod 600 ~/.ssh/config

## Usage

    git clone https://github.com/frnsys/dippindots.git ~/.dippindots
    cd ~/.dippindots
    ./dippindots.sh
