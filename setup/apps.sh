#!/bin/bash
# Exit on any failure
set -e

DIR=$1

tput setaf 5
echo -e "\nInstalling some more goodies..."
tput sgr0

sudo apt update

# bluetooth
# see ~/notes/linux/bluetooth.md
sudo apt install -y bluez libbluetooth3 libbluetooth-dev blueman pulseaudio-module-bluetooth bluez-tools
pactl load-module module-bluetooth-discover

# utils
sudo apt install -y --no-install-recommends alsa-utils acpi bc cryptsetup dhcpcd5 dos2unix curl jq gnupg htop wget dnsutils imagemagick silversearcher-ag xbacklight tree
sudo pip install youtube-dl

# feh - image viewer/wallpaper manager
# xsel - clipboard
# xdotool - simulating interactions with the GUI
# i3lock - locking the screen
# libnotify-bin - for `notify-send` to create notifications
# unclutter - hide cursor after inactivity
# gdebi - easier installation of deb packages
sudo apt install -y --no-install-recommends xorg
sudo apt install -y feh xsel xdotool i3lock libnotify-bin unclutter gdebi deluged deluge-console oathtool avahi-daemon redshift

# deluged config
ln -sf $DIR/dots/deluged.conf ~/.config/deluge/core.conf

# trackpad config
sudo cp $DIR/dots/misc/01-libinput.conf /usr/share/X11/xorg.conf.d/

# seems necessary for xbacklight for thinkpads,
# which use `intel_brightness` (in `/sys/class/backlight`)
sudo apt install -y xserver-xorg-video-intel
sudo cp $DIR/dots/misc/20-intel.conf /usr/share/X11/xorg.conf.d/
ln -sf $DIR/dots/redshift.conf ~/.config/redshift.conf

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

# lid close/switch behavior
# to enable `systemctl hybrid-sleep`,
# which is durable to power loss,
# you must disable secure boot in the BIOS.
sudo apt install -y pm-utils
# TODO auto replace?
# sudo vi /etc/systemd/logind.conf
# add:
# HandleLidSwitch=hybrid-sleep
# systemctl restart systemd-logind.service

# don't automatically kill user processes
# like tmux on logout
sudo sed -i 's/#KillUserProcesses=no/KillUserProcesses=no/' /etc/systemd/logind.conf

# auto-lock screen on sleep
# https://wiki.archlinux.org/index.php/Power_management#Suspend.2Fresume_service_files
sudo cp $DIR/bin/lock /usr/bin/lock
sudo cp $DIR/dots/misc/lock@.service /etc/systemd/system/lock@.service
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
git checkout 0.7.7
./autogen.sh
autoreconf --force --install
BOOST_LIB_SUFFIX="" ./configure --enable-visualizer --enable-outputs --enable-unicode --with-taglib --with-fftw
make
sudo make install
cd $DIR
ln -sf $DIR/dots/ncmpcpp ~/.ncmpcpp

sudo apt install -y mpd mpc
mkdir ~/.mpd/
touch ~/.mpd/{mpd.db,mpd.log,mpd.pid,mpd.state}
ln -sf $DIR/dots/mpd.conf ~/.mpd/mpd.conf

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
git clone --depth=1 git://source.ffmpeg.org/ffmpeg.git /tmp/ffmpeg
cd /tmp/ffmpeg

# a detour for x265
wget https://bitbucket.org/multicoreware/x265/downloads/x265_2.0.tar.gz -O /tmp/ffmpeg/x265.tar.gz
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
sudo sh -c "echo '/usr/local/ffmpeg/lib' >> /etc/ld.so.conf"
sudo ldconfig
cd $DIR

sudo add-apt-repository -y ppa:mc3man/mpv-tests
sudo apt install -y mpc mpv
ln -sf $DIR/dots/mpv ~/.config/mpv

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
git clone https://github.com/baskerville/sutils.git /tmp/sutils
git clone https://github.com/baskerville/xtitle.git /tmp/xtitle
git clone https://github.com/LemonBoy/bar.git /tmp/bar
cd /tmp/sutils && make && sudo make install
cd /tmp/xtitle && make && sudo make install
cd /tmp/bar && make && sudo make install
echo 'export PANEL_FIFO="/tmp/panel-fifo"' | sudo tee -a /etc/profile
cd $DIR

# alacritty - terminal
sudo add-apt-repository -y ppa:mmstick76/alacritty
sudo apt install -y alacritty
mkdir -p ~/.config/alacritty
ln $DIR/dots/alacritty.conf ~/.config/alacritty/alacritty.conf
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
# zathura       -- keyboard-driven pdf viewer
# ncdu          -- ncurses disk usage
# keepassx      -- password management
# adb           -- for interfacing with android phones
# xournal       -- for annotating pdfs
# pavucontrol   -- for managing sound
sudo apt install -y --no-install-recommends zathura android-tools-adb ncdu keepassx xournal pavucontrol firefox chromium-browser
ln -sf $DIR/dots/zathurarc ~/.config/zathura/zathurarc

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
sudo pip2 install pykeepass
sudo apt install -y python-gtk2

# vpn
sudo apt install -y openvpn stunnel4 resolvconf
sudo sed -i "s/ENABLED=0/ENABLED=1/" /etc/default/stunnel4
sudo service stunnel4 start

# autostart/stop vpn on wifi up/down
sudo cp $DIR/dots/misc/network/airvpn_up /etc/networkd-dispatcher/routable.d/airvpn
sudo cp $DIR/dots/misc/network/airvpn_down  /etc/networkd-dispatcher/no-carrier.d/airvpn

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
ln $DIR/dots/gtkrc-2.0 ~/.gtkrc-2.0
ln $DIR/dots/gtkrc-3.0  ~/.config/gtk-3.0/settings.ini
echo -e "[Qt]\nstyle=GTK+" >> ~/.config/Trolltech.conf

# setup fonts
sudo ln -sf /etc/fonts/conf.avail/50-user.conf /etc/fonts/conf.d/50-user.conf
sudo apt install -y fonts-inconsolata xfonts-terminus ttf-mscorefonts-installer
ln -sf $DIR/assets/fonts ~/.fonts
ln -sf $DIR/dots/fonts.conf ~/.fonts.conf
mkfontdir ~/.fonts
mkfontscale ~/.fonts
xset +fp ~/.fonts/
xset fp rehash
fc-cache -fv

# wallpapers
ln -sf $DIR/assets/walls ~/.walls
ln -sf ~/.walls/1.jpg ~/.wall.jpg
chmod 644 ~/.wall.jpg

# for easily updating system time to current time zone
# to preview, run `tzupdate -p`
# to make the change, run `sudo tzupdate`
sudo pip2 install git+https://github.com/cdown/tzupdate

# TODO remove?
# this was necessary to get sound and video working on the C720 (sound and video was only playable by root)
sudo adduser ftseng audio
sudo adduser ftseng pulse-access
sudo adduser ftseng video

# firefox config
# Make sure to disable media.peerconnection.enabled in about:config
# to prevent WebRTC IP leaks
# Also disabled hardware acceleration,
# had issues with slow painting otherwise
mkdir -p ~/.mozilla/firefox/profile.default/chrome
ln -sf $DIR/dots/firefox/userChrome.css ~/.mozilla/firefox/profile.default/chrome/userChrome.css
ln -sf $DIR/dots/firefox/userContent.css ~/.mozilla/firefox/profile.default/chrome/userContent.css
sed -i 's/Path=.*/Path=profile.default/' ~/.mozilla/firefox/profiles.ini
# extensions
# https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/
# https://addons.mozilla.org/en-US/firefox/addon/zhongwen-chinese-english/

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
sudo pip install offlineimap urlscan
git clone https://github.com/neomutt/neomutt.git /tmp/neomutt
cd /tmp/neomutt
git checkout neomutt-20180716
./configure --disable-doc --ssl --sasl --notmuch
make
sudo make install
sudo ln -s /usr/bin/neomutt /usr/bin/mutt
ln -sf $DIR/dots/email/muttrc ~/.muttrc
ln -sf $DIR/dots/email/mailcap ~/.mailcap
ln -sf $DIR/dots/email/offlineimaprc ~/.offlineimaprc
ln -sf $DIR/dots/email/notmuch-config ~/.notmuch-config
ln -sf $DIR/dots/email/signature ~/.signature
sudo ln -sf $DIR/dots/email/view_html.sh /usr/local/bin/view_html
sudo ln -sf $DIR/dots/email/view_mht.py /usr/local/bin/view_mht
sudo ln -sf $DIR/dots/email/update_nm.sh /usr/local/bin/update_nm
cd $DIR

sudo cp $DIR/dots/email/offlineimap.service /etc/systemd/user/offlineimap.service
systemctl --user daemon-reload
systemctl --user enable offlineimap.service
systemctl --user start offlineimap.service

# calendar
pip3 install vdirsyncer[google]
pip3 install git+git://github.com/pimutils/khal.git
mkdir -p ~/.config/{vdirsyncer,khal}
mkdir -p ~/.config/vdirsyncer/tokens
sudo ln -sf $(which vdirsyncer) /usr/local/bin/vdirsyncer
ln -sf $DIR/dots/calendar/vdirsyncer ~/.config/vdirsyncer/config
ln -sf $DIR/dots/calendar/khal ~/.config/khal/config
vdirsyncer discover
sudo cp $DIR/dots/calendar/vdirsyncer.{service,timer} /etc/systemd/user/
systemctl --user daemon-reload
systemctl --user enable vdirsyncer.timer
systemctl --user start vdirsyncer.timer
# check timers with `systemctl list-timers --all --user`

# for pypi
ln -sf $DIR/dots/pypirc ~/.pypirc

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
sudo add-apt-repository ppa:linrunner/tlp
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
