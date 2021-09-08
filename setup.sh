#!/bin/bash
# Exit on any failure
set -e

DIR=$(pwd)

# =============== WELCOME =================================
if [[ ! $(lsb_release -a 2>/dev/null | grep Ubuntu) ]]; then
	echo "DippinDots is meant for use with Ubuntu-based Linux distros. Goodbye!"
    exit 1
fi

read -rep "This will overwrite your existing dotfiles. Do you want to continue? (y/n) " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo -e "\nExiting..."
	exit 1
fi

read -rep "Do you want to install apps? (y/n) " -n 1
APPS=$REPLY


# ===============  CORE  ================================
echo "Installing prereqs..."
sudo apt update
sudo apt upgrade -y
sudo apt install -y --no-install-recommends python3 python3-pip gcc gfortran build-essential g++ make cmake autoconf wget unzip git openssh-server software-properties-common libncurses5-dev libxml2-dev libxslt1-dev libyaml-dev bzip2 curl python-dev libsqlite3-dev

echo "Installing nvm/node..."
sudo pip install libsass
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
nvm install node

echo "Installing git..."
sudo add-apt-repository ppa:git-core/ppa -y
sudo apt update
sudo apt install -y git

curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt install -y git-lfs
git lfs install

mkdir -p ~/.config/git
ln -sf $DIR/dots/git/gitignore ~/.config/git/ignore
ln -sf $DIR/dots/git/gitconfig ~/.gitconfig

# so we can push without logging in
ssh -vT git@github.com

echo "Installing fzf..."
echo "Say NO to auto-completion for performance"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

sudo apt install -y --no-install-recommends wget silversearcher-ag

# rust & fd
curl -sf -L https://static.rust-lang.org/rustup.sh | sh
source ~/.cargo/env
cargo install fd-find ripgrep
rustup toolchain add nightly

# dependencies for rust features in vim/ale
rustup component add rust-src --toolchain nightly
rustup component add clippy-preview --toolchain nightly
curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz -o /tmp/rust-analyzer.gz
gunzip /tmp/rust-analyzer.gz
sudo mv /tmp/rust-analyzer /usr/local/bin/rust-analyzer
sudo chmod +x /usr/local/bin/rust-analyzer

echo "Installing math libs..."
sudo apt install -y libatlas-base-dev liblapack-dev libopenblas-dev libopenblas-base libatlas3-base

echo "Installing Python3..."
sudo apt -y install python3 python3-setuptools python3-pip

# pyenv for easier version management
sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv

# activate pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

# install python
env PYTHON_CFLAGS=-fPIC PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 3.6.6
pyenv global 3.6.6

# for vim syntax checking
# make sure this installs under the installed pyenv
pip install pyflakes

# ipython config
mkdir -p ~/.ipython/profile_default
ln -sf $DIR/dots/python/ipython_config.py ~/.ipython/profile_default/ipython_config.py

echo "Installing Vim..."
# Lua, python interps, and X11/system clipboard support
sudo apt install -y \
    lua5.1 liblua5.1-dev \
    python-dev python3-dev \
    libx11-dev libxtst-dev libxt-dev libsm-dev libxpm-dev

mkdir /tmp/vim && cd $_
wget https://github.com/vim/vim/archive/v8.2.2488.zip
unzip v*.zip
cd vim*
./configure --with-features=huge --enable-luainterp=yes --enable-pythoninterp=yes --enable-python3interp=yes --enable-gui=no --with-x --with-lua-prefix=/usr
make -s && sudo make install
cd $DIR

# Overwrite vi
sudo ln -sf /usr/local/bin/vim /usr/bin/vi
sudo ln -sf /usr/local/bin/vim /usr/bin/vim
sudo ln -sf /usr/bin/vim /etc/alternatives/editor
mkdir ~/.vim/.backup

# TODO replace vi with nvim
wget https://github.com/neovim/neovim/archive/refs/tags/v0.5.0.tar.gz -O /tmp/neovim.tar.gz
cd /tmp
tar -xzvf neovim.tar.gz
cd neovim-*
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
sudo ln -sf /usr/local/bin/nvim /usr/bin/vi
sudo ln -sf /usr/local/bin/nvim /usr/bin/vim
sudo ln -sf /usr/bin/vim /etc/alternatives/editor
cd $DIR

# mypy for python type annotations
sudo pip3 install mypy

# config
rm -rf ~/.vim
ln -sf $DIR/dots/vim ~/.vim
ln -sf $DIR/dots/vim/vimrc ~/.vimrc
ln -sf $DIR/dots/vim/init.vim ~/.config/nvim/init.vim

# minpac for plugin management
# in vim, call:
# call minpac#update()
mkdir -p ~/.vim/pack/minpac/opt
git clone https://github.com/k-takata/minpac.git ~/.vim/pack/minpac/opt/minpac


# ===============  APPS  ================================
if [[ ! $APPS =~ ^[Yy]$ ]]; then
    sudo apt update

    # bluetooth
    # see ~/notes/linux/bluetooth.md
    sudo apt install -y bluez libbluetooth3 libbluetooth-dev blueman pulseaudio-module-bluetooth bluez-tools
    pactl load-module module-bluetooth-discover

    # utils
    sudo apt install -y --no-install-recommends alsa-utils acpi bc cryptsetup dhcpcd5 dos2unix curl jq gnupg htop wget dnsutils imagemagick silversearcher-ag tree
    sudo pip install youtube-dl

    # xsel - clipboard
    # xclip - clipboard, used by imgclip script
    # xdotool - simulating interactions with the GUI
    # i3lock - locking the screen
    # libnotify-bin - for `notify-send` to create notifications
    # unclutter - hide cursor after inactivity
    # gdebi - easier installation of deb packages
    sudo apt install -y --no-install-recommends xorg
    sudo apt install -y xsel xclip xdotool i3lock libnotify-bin unclutter gdebi deluged deluge-console oathtool avahi-daemon redshift

    # deluged config
    ln -sf $DIR/dots/misc/deluged.conf ~/.config/deluge/core.conf

    # latest libinput
    # trackpad config
    git clone https://gitlab.freedesktop.org/libinput/libinput /tmp/libinput
    cd /tmp/libinput/
    sudo apt install -y meson ninja-build
    sudo apt install -y libmtdev-dev libevdev-dev
    meson --prefix=/usr -Ddocumentation=false -Ddebug-gui=false -Dlibwacom=false -Dtests=false builddir/
    ninja -C builddir/
    sudo ninja -C builddir/ install
    sudo cp $DIR/dots/misc/01-libinput.conf /usr/share/X11/xorg.conf.d/
    cd $DIR

    # picom compositor
    # sudo apt install -y libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-
    # render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libxcb-glx0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libpcre2-dev  libevdev-dev uthash-dev libev-dev libx11-xcb-dev
    # git clone https://github.com/yshui/picom /tmp/picom
    # cd /tmp/picom
    # git checkout v8
    # meson --buildtype=release . build
    # ninja -C build
    # sudo ninja -C build install
    # ln -sf $DIR/dots/misc/picom.conf ~/.config/picom.conf

    # backlight
    sudo cp $DIR/bin/glow /usr/bin/glow
    ln -sf $DIR/dots/misc/redshift.conf ~/.config/redshift.conf

    # pandoc
    sudo apt install -y --no-install-recommends texlive lmodern texlive-latex-extra texlive-fonts-extra cm-super texlive-generic-recommended
    wget https://github.com/jgm/pandoc/releases/download/2.7.1/pandoc-2.7.1-1-amd64.deb -O /tmp/pandoc.deb
    sudo gdebi --n /tmp/pandoc.deb

    # map capslock to super
    # use right alt as compose key
    sudo sed -i 's/XKBOPTIONS=""/XKBOPTIONS="compose:ralt,caps:super"/' /etc/default/keyboard

    # larger font for boot tty
    sudo sed -i 's/FONTFACE=.*/FONTFACE="Terminus"/' /etc/default/console-setup
    sudo sed -i 's/FONTSIZE=.*/FONTSIZE="14x28"/' /etc/default/console-setup

    # lid close/switch
    # to enable `systemctl hybrid-sleep`,
    # which is durable to power loss,
    # you must disable secure boot in the BIOS.
    sudo apt install -y pm-utils xautolock
    # TODO auto replace?
    # sudo vi /etc/systemd/logind.conf
    # add:
    # HandleLidSwitch=hybrid-sleep
    # systemctl restart systemd-logind.service
    # Note that idle detection doesn't work w/o a DE
    # Instead using xautolock, see ~/.xinitrc

    # don't automatically kill user processes
    # like tmux on logout
    sudo sed -i 's/#KillUserProcesses=no/KillUserProcesses=no/' /etc/systemd/logind.conf

    # auto-lock screen on sleep
    # https://wiki.archlinux.org/index.php/Power_management#Suspend.2Fresume_service_files
    sudo cp $DIR/bin/lock /usr/bin/lock
    sudo cp $DIR/dots/services/lock@.service /etc/systemd/system/lock@.service
    sudo chown root:root /etc/systemd/system/lock@.service
    systemctl enable lock@ftseng.service

    # dmenu-pango-imlib
    git clone https://github.com/Cloudef/dmenu-pango-imlib /tmp/dmenu
    cd /tmp/dmenu
    sudo apt install -y libxinerama-dev libimlib2-dev libxcb-xinerama0-dev libxft-dev libpango1.0-dev libssl-dev
    sudo make clean install
    cd $DIR

    # maim/slop (scrot replacement)
    sudo apt install -y libglm-dev libgl1-mesa-dev libgles2-mesa-dev mesa-utils-extra libxrandr-dev libxcomposite-dev libglew-dev
    git clone https://github.com/naelstrof/slop.git /tmp/slop
    cd /tmp/slop
    cmake -DCMAKE_OPENGL_SUPPORT=true -DSLOP_UNICODE=false ./
    make && sudo make install
    git clone https://github.com/naelstrof/maim.git /tmp/maim
    cd /tmp/maim
    cmake ./
    make && sudo make install
    cd $DIR

    # feh - image viewer/wallpaper manager
    # librsvg for viewing svgs with feh
    sudo apt install -y feh librsvg2-bin

    # webp imlib2 loader for feh
    sudo apt install -y libimlib2-dev libwebp-dev pkg-config
    git clone https://github.com/gawen947/imlib2-webp.git /tmp/webp
    cd /tmp/webp
    make
    sudo make install
    cd $DIR

    # build the latest ncmpcpp
    sudo apt install -y libboost-all-dev libfftw3-dev doxygen libncursesw5-dev libtag1-dev libcurl4-openssl-dev libmpdclient-dev libtool
    git clone https://github.com/arybczak/ncmpcpp.git /tmp/ncmpcpp
    cd /tmp/ncmpcpp
    git checkout 0.9.2
    ./autogen.sh
    autoreconf --force --install
    BOOST_LIB_SUFFIX="" ./configure --enable-visualizer --enable-outputs --with-taglib --with-fftw
    make
    sudo make install
    cd $DIR
    ln -sf $DIR/dots/ncmpcpp ~/.ncmpcpp

    sudo apt install -y mpd mpc
    mkdir ~/.mpd/
    touch ~/.mpd/{mpd.db,mpd.log,mpd.pid,mpd.state}
    ln -sf $DIR/dots/mpd/mpd.conf ~/.mpd/mpd.conf

    # build latest libass for ffmpeg and mpv
    sudo apt install -y libfribidi-dev libfontconfig1-dev
    git clone --depth=1 https://github.com/libass/libass.git /tmp/libass
    cd /tmp/libass
    ./autogen.sh
    ./configure --enable-shared
    make
    sudo make install

    # ffmpeg
    sudo apt install -y autoconf automake build-essential libfreetype6-dev libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texi2html zlib1g-dev libx264-dev libmp3lame-dev libfdk-aac-dev libvpx-dev libopus-dev libpulse-dev yasm
    git clone --depth=1 --branch n4.3.1 git://source.ffmpeg.org/ffmpeg.git /tmp/ffmpeg
    cd /tmp/ffmpeg

    # a detour for x265
    wget https://bitbucket.org/multicoreware/x265_git/downloads/x265_3.3.tar.gz -O /tmp/ffmpeg/x265.tar.gz
    cd /tmp/ffmpeg
    tar -xzvf x265.tar.gz
    cd x265_*/build/linux
    CFLAGS=-fPIC PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="/usr/local/ffmpeg" -DENABLE_SHARED:bool=on ../../source
    make
    sudo make install

    # compile ffmpeg
    cd /tmp/ffmpeg
    PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="/usr/local/ffmpeg/lib/pkgconfig" ./configure \
      --prefix="/usr/local/ffmpeg" \
      --extra-cflags="-I/usr/local/ffmpeg/include" \
      --extra-ldflags="-L/usr/local/ffmpeg/lib" \
      --bindir="/usr/local/bin" \
      --cc="gcc -m64 -fPIC" \
      --enable-pic \
      --enable-gpl \
      --enable-x86asm \
      --enable-libass \
      --enable-libfdk-aac \
      --enable-libfreetype \
      --enable-libmp3lame \
      --enable-libopus \
      --enable-libtheora \
      --enable-libvorbis \
      --enable-libvpx \
      --enable-libx264 \
      --enable-libx265 \
      --enable-libpulse \
      --enable-nonfree \
      --enable-openssl \
      --enable-shared
    make
    sudo make install
    sudo sh -c "echo '/usr/local/ffmpeg/lib' > /etc/ld.so.conf.d/ffmpeg.conf"
    sudo ldconfig
    cd $DIR

    sudo add-apt-repository -y ppa:mc3man/mpv-tests
    sudo apt install -y mpc mpv
    ln -sf $DIR/dots/mpv ~/.config/mpv

    # for mpv hardware acceleration
    sudo apt install i965-va-driver

    # bspwm - window manager
    sudo apt install -y xcb libxcb-util0-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev  libxcb-xtest0-dev libasound2-dev libxcb-ewmh-dev
    git clone https://github.com/baskerville/xdo /tmp/xdo
    git clone https://github.com/baskerville/bspwm.git /tmp/bspwm
    git clone https://github.com/baskerville/sxhkd.git /tmp/sxhkd
    cd /tmp/xdo && make && sudo make install
    cd /tmp/bspwm && make && sudo make install
    cd /tmp/sxhkd && make && sudo make install
    cd $DIR
    ln -sf $DIR/dots/bspwm  ~/.config/bspwm
    ln -sf $DIR/dots/sxhkd  ~/.config/sxhkd

    # lemonbar - status bar/panel
    ln -sf $DIR/dots/lemonbar  ~/.config/lemonbar
    sudo ln -sf ~/.config/lemonbar/panel /usr/bin/panel
    sudo ln -sf ~/.config/lemonbar/panel_bar /usr/bin/panel_bar
    sudo ln -sf ~/.config/lemonbar/panel_autohide /usr/bin/panel_autohide
    git clone https://github.com/baskerville/sutils.git /tmp/sutils
    git clone https://github.com/baskerville/xtitle.git /tmp/xtitle
    # git clone https://github.com/LemonBoy/bar.git /tmp/bar
    git clone https://github.com/drscream/lemonbar-xft /tmp/bar
    cd /tmp/sutils && make && sudo make install
    cd /tmp/xtitle && make && sudo make install
    cd /tmp/bar && make && sudo make install
    echo 'export PANEL_FIFO="/tmp/panel-fifo"' | sudo tee -a /etc/profile
    cd $DIR

    # alacritty - terminal
    sudo add-apt-repository -y ppa:mmstick76/alacritty
    sudo apt install -y alacritty
    ln -sf $DIR/dots/alacritty ~/.config/alacritty
    cd $DIR

    # dunst - notifications
    sudo apt install -y libxss-dev libxdg-basedir-dev libxinerama-dev libxft-dev libcairo2-dev libdbusmenu-glib-dev libgtk2.0-dev
    wget https://github.com/dunst-project/dunst/archive/v1.3.1.zip -O /tmp/dunst.zip
    cd /tmp/
    unzip dunst.zip
    cd dunst-*
    make
    sudo make install
    ln -sf $DIR/dots/dunst  ~/.config/dunst

    # other defaults
    ln -sf $DIR/dots/xinitrc ~/.xinitrc
    ln -sf $DIR/dots/Xresources ~/.Xresources

    # flash player
    sudo apt install -y pepperflashplugin-nonfree
    sudo update-pepperflashplugin-nonfree --install

    # ranger
    sudo apt install -y --no-install-recommends highlight atool caca-utils w3m w3m-img poppler-utils ffmpegthumbnailer
    pip3 install ueberzug ranger-fm
    ln -sf $DIR/dots/ranger/rc.conf ~/.config/ranger/rc.conf
    ln -sf $DIR/dots/ranger/rifle.conf ~/.config/ranger/rifle.conf
    ln -sf $DIR/dots/ranger/scope.sh ~/.config/ranger/scope.sh

    # install some cool apps :D
    # ncdu          -- ncurses disk usage
    # keepassx      -- password management
    # adb           -- for interfacing with android phones
    # xournal       -- for annotating pdfs
    # pavucontrol   -- for managing sound
    sudo apt install -y --no-install-recommends android-tools-adb ncdu keepassx xournal pavucontrol firefox chromium-browser

    # mupdf-gl
    wget https://www.mupdf.com/downloads/archive/mupdf-1.18.0-source.tar.xz -O /tmp/mupdf.tar.xz
    cd /tmp
    tar -xf mupdf.tar.xz
    cd mupdf-*
    # change background color
    sed -i 's/glClearColor(0.3f, 0.3f, 0.3f, 1);/glClearColor(0.125f, 0.125f, 0.125f, 1);/' platform/gl/gl-main.c
    # change keybindings
    sed -i "s/case 'j'/case 'foo'/" platform/gl/gl-main.c # j: scroll down
    sed -i "s/case ' '/case 'j'/" platform/gl/gl-main.c
    sed -i "s/case 'foo'/case ' '/" platform/gl/gl-main.c
    sed -i "s/case 'k'/case 'foo'/" platform/gl/gl-main.c # k: scroll up
    sed -i "s/case 'b'/case 'k'/" platform/gl/gl-main.c
    sed -i "s/case 'foo'/case 'b'/" platform/gl/gl-main.c
    sed -i "s/case '\.'/case 'J'/" platform/gl/gl-main.c  # J: page down
    sed -i "s/case ','/case 'K'/" platform/gl/gl-main.c   # K: page up
    make && sudo make prefix=/usr/local install
    cd $DIR

    # for scripts that watch filesystem for changes
    cargo install watchexec

    # geckodriver
    wget https://github.com/mozilla/geckodriver/releases/download/v0.23.0/geckodriver-v0.23.0-linux64.tar.gz -O /tmp/geckodriver.tar.gz
    cd /tmp
    tar -xzvf geckodriver.tar.gz
    chmod +x geckodriver
    sudo mv geckodriver /usr/local/bin/
    cd $DIR

    # adb-sync
    git clone https://github.com/google/adb-sync /tmp/adb-sync
    sudo cp /tmp/adb-sync/adb-sync /usr/local/bin/

    # for ~/.bin/keepass
    sudo pip install pykeepass
    sudo apt install -y python-gtk2

    # vpn
    sudo apt install -y openvpn stunnel4 resolvconf
    sudo sed -i "s/ENABLED=0/ENABLED=1/" /etc/default/stunnel4
    sudo service stunnel4 start

    # autostart/stop vpn on wifi up/down
    sudo cp $DIR/dots/services/network/airvpn_up /etc/networkd-dispatcher/routable.d/airvpn
    sudo cp $DIR/dots/services/network/airvpn_down  /etc/networkd-dispatcher/no-carrier.d/airvpn

    # signal desktop client
    curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
    echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee -a /etc/apt/sources.list.d/signal-xenial.list
    sudo apt update && sudo apt install -y signal-desktop

    # signal-cli
    # used by daemon script
    # has to be built from source at the moment
    sudo apt install -y openjdk-8-jre openjdk-8-jdk gradle
    git clone https://github.com/AsamK/signal-cli.git /tmp/signal-cli
    cd /tmp/signal-cli
    ./gradlew build
    ./gradlew installDist
    sudo cp -r build/install/signal-cli /opt/signal-cli
    sudo ln -sf /opt/signal-cli/bin/signal-cli /usr/local/bin/signal-cli
    cd $DIR

    # GTK/QT themeing
    sudo apt install -y gnome-accessibility-themes
    rm -rf ~/.icons
    ln -sf $DIR/assets/icons ~/.icons
    ln -sf $DIR/dots/misc/gtkrc ~/.gtkrc-2.0
    ln -sf $DIR/dots/misc/gtkrc  ~/.config/gtk-3.0/settings.ini
    echo -e "[Qt]\nstyle=GTK+" >> ~/.config/Trolltech.conf

    # setup fonts
    sudo ln -sf /etc/fonts/conf.avail/50-user.conf /etc/fonts/conf.d/50-user.conf
    sudo apt install -y fonts-inconsolata xfonts-terminus ttf-mscorefonts-installer
    mkdir -p ~/.config/fontconfig
    ln -sf $DIR/assets/fonts ~/.fonts
    ln -sf $DIR/dots/misc/fonts.conf ~/.fonts.conf
    ln -sf $DIR/dots/misc/fonts.conf ~/.config/fontconfig/fonts.conf
    mkfontdir ~/.fonts
    mkfontscale ~/.fonts
    xset +fp ~/.fonts/
    xset fp rehash
    fc-cache -fv

    sudo mkdir /usr/share/fonts/truetype/robotomono
    sudo wget --content-disposition -P /usr/share/fonts/truetype/robotomono https://github.com/google/fonts/blob/master/apache/robotomono/static/RobotoMono-{Bold,BoldItalic,Italic,Light,LightItalic,Medium,MediumItalic,Regular,Thin,ThinItalic}.ttf?raw=true
    sudo fc-cache -fv

    # wallpapers
    ln -sf $DIR/assets/walls ~/.walls
    ln -sf ~/.walls/1.jpg ~/.wall.jpg
    chmod 644 ~/.wall.jpg

    # for easily updating system time to current time zone
    # to preview, run `tzupdate -p`
    # to make the change, run `sudo tzupdate`
    sudo pip3 install tzupdate

    # TODO remove?
    # this was necessary to get sound and video working on the C720 (sound and video was only playable by root)
    sudo adduser ftseng audio
    sudo adduser ftseng pulse-access
    sudo adduser ftseng video

    # firefox config
    # Make sure to disable `media.peerconnection.enabled` in about:config
    # to prevent WebRTC IP leaks
    # Also disabled hardware acceleration,
    # had issues with slow painting otherwise
    # You also need to set `toolkit.legacyUserProfileCustomizations.stylesheets` to true in about:config
    # Also set: `browser.fullscreen.autohide` to false.
    mkdir -p ~/.mozilla/firefox/profile.default/chrome
    ln -sf $DIR/dots/firefox/userChrome.css ~/.mozilla/firefox/profile.default/chrome/userChrome.css
    ln -sf $DIR/dots/firefox/userContent.css ~/.mozilla/firefox/profile.default/chrome/userContent.css
    sed -i 's/Path=.*/Path=profile.default/' ~/.mozilla/firefox/profiles.ini
    # extensions
    # https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/
    # hili

    # Change default browser
    sudo update-alternatives --config x-www-browser
    sudo update-alternatives --config gnome-www-browser

    # xrectsel for region selection (for recording regions)
    git clone https://github.com/lolilolicon/xrectsel.git /tmp/xrectsel
    cd /tmp/xrectsel
    ./bootstrap
    ./configure --prefix /usr
    make
    sudo make install
    cd $DIR

    # for screen recordings
    sudo apt install -y imagemagick recordmydesktop gifsicle

    # symlink notes and sites
    ln -sf $DIR/dots/port ~/.port

    # backup config
    ln -s $DIR/dots/bkup ~/.bkup

    # muttrc
    sudo apt install -y xsltproc libidn11-dev libsasl2-dev libnotmuch-dev notmuch --no-install-recommends
    sudo pip install isync urlscan # isync is mbsync
    git clone https://github.com/neomutt/neomutt.git /tmp/neomutt
    cd /tmp/neomutt
    git checkout neomutt-20180716
    ./configure --disable-doc --ssl --sasl --notmuch
    make
    sudo make install
    sudo ln -s /usr/bin/neomutt /usr/bin/mutt
    ln -sf $DIR/dots/email/muttrc ~/.muttrc
    ln -sf $DIR/dots/email/mailcap ~/.mailcap
    ln -sf $DIR/dots/email/mbsyncrc ~/.mbsyncrc
    ln -sf $DIR/dots/email/notmuch-config ~/.notmuch-config
    ln -sf $DIR/dots/email/signature ~/.signature
    sudo ln -sf $DIR/dots/email/view_html.sh /usr/local/bin/view_html
    sudo ln -sf $DIR/dots/email/view_mht.py /usr/local/bin/view_mht
    sudo ln -sf $DIR/dots/email/update_nm.sh /usr/local/bin/update_nm
    cd $DIR

    mkdir ~/.mail
    sudo cp $DIR/dots/email/mbsync.{service,timer} /etc/systemd/user/
    systemctl --user daemon-reload
    systemctl --user enable mbsync.timer
    systemctl --user start mbsync.timer

    # calendar
    pip3 install vdirsyncer[google]
    mkdir -p ~/.config/vdirsyncer
    mkdir -p ~/.config/vdirsyncer/tokens
    sudo ln -sf $(which vdirsyncer) /usr/local/bin/vdirsyncer
    ln -sf $DIR/dots/calendar/vdirsyncer ~/.config/vdirsyncer/config
    vdirsyncer discover
    sudo cp $DIR/dots/calendar/vdirsyncer.{service,timer} /etc/systemd/user/
    systemctl --user daemon-reload
    systemctl --user enable vdirsyncer.timer
    systemctl --user start vdirsyncer.timer
    # check timers with `systemctl list-timers --all --user`

    # for pypi
    ln -sf $DIR/dots/python/pypirc ~/.pypirc

    # better chinese character support
    sudo apt install -y fonts-noto-cjk

    # chinese pinyin input
    # Hit CTRL+SPACE+LEFT_SHIFT, in that order
    sudo apt install -y fcitx fcitx-googlepinyin

    # fixes for 5G wifi
    # set networking card region
    sudo apt install -y bcmwl-kernel-source
    sudo sed -i -e 's/REGDOMAIN=.*/REGDOMAIN=US/g' /etc/default/crda

    # for thinkpads
    # tlp for better battery life
    # also provides utility commands `bluetooth` and `wifi`
    # which are used elsewhere in scripts
    sudo add-apt-repository -y ppa:linrunner/tlp
    sudo apt update
    sudo apt install tlp --no-install-recommends
    sudo apt install acpi-call-dkms
    # replacement for tm-smapi-dkms
    git clone https://github.com/teleshoes/tpacpi-bat /tmp/tpacpi-bat
    cd /tmp/tpacpi-bat
    ./install.pl

    # Use more familiar network interface names (wlan0, eth0)
    # Some parts of the dotfiles expect names like wlan0
    GRUB_PARAMS="net.ifnames=0 biosdevname=0 acpi_osi=linux acpi_backlight=vendor"
    sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"$GRUB_PARAMS\"/" /etc/default/grub
    sudo update-grub
    sudo update-initramfs -u

    # Setup passwordless sudo/root for certain commands
    sudo cp $DIR/dots/misc/00_anarres /etc/sudoers.d/

    # Remove default home directories ("Desktop", etc)
    sudo sed -i 's/enabled=True/enabled=False/' /etc/xdg/user-dirs.conf

    # Not sure why these lines are in startx,
    # but they interfere with notifications for apps like Slack
    sudo sed -i 's/unset DBUS_SESSION_BUS_ADDRESS/#unset DBUS_SESSION_BUS_ADDRESS/' /usr/bin/startx
    sudo sed -i 's/unset SESSION_MANAGER/#unset SESSION_MANAGER/' /usr/bin/startx

    # for USB input devices
    sudo apt install linux-image-generic
    sudo update-initramfs -k all -c
    # then reboot

    # NOTE: import GPG private key
    # see ~/docs/keys/note.md for password hint
    # requires the `~/docs` directory has been restored
    # gpg --import ~/docs/keys/private.key
    # then:
    # gpg --edit-key <KEY_ID>
    # gpg> trust
    # and set to ultimate trust
fi


# ===============  SYMLINK  =================================
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


# ===============  FINISH  =================================
sudo apt-get autoremove -y
source ~/.bash_profile
echo "Done"
