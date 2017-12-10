DIR=$1

tput setaf 5
echo -e "\nInstalling some more goodies..."
tput sgr0

# NOTE: `dhcpcd5` can conflict with `wicd-curses`,
# but is needed for usb tethering.
# see the wicd comments below for how to work around this
sudo apt install -y alsa-utils acpi bc cryptsetup dhcpcd5

# bluetooth
# see ~/notes/linux/bluetooth.md
sudo apt install -y bluez libbluetooth3 libbluetooth-dev blueman pulseaudio-module-bluetooth
pactl load-module module-bluetooth-discover

# utils
sudo apt install -y --no-install-recommends dos2unix curl jq gnupg htop wget dnsutils imagemagick nmap httpie silversearcher-ag
sudo pip install youtube-dl

# feh - image viewer/wallpaper manager
# xsel - clipboard
# dunst - notifications
# xdotool - simulating interactions with the GUI
# i3lock - locking the screen
# libnotify-bin - for `notify-send` to create notifications
# unclutter - hide cursor after inactivity
# xbacklight - control screen brightness
# gdebi - easier installation of deb packages
# compton - for window/bar transparency and shadows
# sm - large text screen messages
sudo apt update
sudo apt install -y --no-install-recommends xorg
sudo apt install -y feh xsel dunst xdotool i3lock libnotify-bin unclutter xbacklight gdebi deluged deluge-console compton oathtool pandoc avahi-daemon redshift sm

# map capslock to super
# use right alt as compose key
sudo sed -i 's/XKBOPTIONS=""/XKBOPTIONS="compose:ralt,caps:super"/' /etc/default/keyboard

# to enable `systemctl hybrid-sleep`,
# which is durable to power loss,
# you must disable secure boot in the BIOS.

# TODO auto replace?
# sudo vi /etc/systemd/logind.conf
# add:
# HandleLidSwitch=hybrid-sleep

# auto-lock screen on sleep
# https://wiki.archlinux.org/index.php/Power_management#Suspend.2Fresume_service_files
sudo cp $DIR/bin/lock /usr/bin/lock
sudo cp $DIR/dots/misc/lock@.service /etc/systemd/system/lock@.service
sudo chown root:root /etc/systemd/system/lock@.service
systemctl enable lock@ftseng.service

# not using a DE or session manager,
# so manually check idle time for sleeping
sudo apt install -y xprintidle

# dmenu-pango-imlib
git clone https://github.com/Cloudef/dmenu-pango-imlib /tmp/dmenu
cd /tmp/dmenu
sudo apt install -y libxinerama-dev libimlib2-dev libxcb-xinerama0-dev libxft-dev libpango1.0-dev
sudo make clean install
cd $DIR

# maim/slop (scrot replacement)
sudo apt install -y libglm-dev libgl1-mesa-dev libgles2-mesa-dev mesa-utils-extra libxrandr-dev libxcomposite-dev
git clone https://github.com/naelstrof/slop.git /tmp/slop
cd /tmp/slop
cmake -DCMAKE_OPENGL_SUPPORT=true -DSLOP_UNICODE=false ./
make && sudo make install
git clone https://github.com/naelstrof/maim.git /tmp/maim
cd /tmp/maim
cmake ./
make && sudo make install
cd $DIR

# build the latest ncmpcpp
sudo apt install -y libboost-all-dev libfftw3-dev doxygen libncursesw5-dev libtag1-dev libcurl4-openssl-dev libmpdclient-dev libtool
git clone git@github.com:arybczak/ncmpcpp.git /tmp/ncmpcpp
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
  #--pkg-config-flags="--static" \
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

# stream2chromecast
sudo git clone https://github.com/frnsys/stream2chromecast.git /usr/local/share/stream2chromecast
sudo ln -sf /usr/local/share/stream2chromecast/stream2chromecast.py /usr/local/bin/stream2chromecast

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

# urxvt - terminal
sudo apt install -y rxvt-unicode-256color
git clone https://github.com/muennich/urxvt-perls.git /tmp/urxvt-perls
sudo mv /tmp/urxvt-perls/* /usr/lib/urxvt/perl/
git clone https://github.com/majutsushi/urxvt-font-size.git /tmp/urxvt-font-size
sudo mv /tmp/urxvt-font-size/font-size /usr/lib/urxvt/perl/font-size

# wicd - managing network connections
sudo apt install -y wicd wicd-cli wicd-curses
sudo ln -sf /run/resolvconf/resolv.conf /var/lib/wicd/resolv.conf.orig
# IMPORTANT:
# - open `wicd-curses`
# - hit `P` to open preferences
# - switch to the `External Programs` tab
# - ensure that `dhclient` is selected as the DHCP client
# if automatic, it might use `dhcpcd`, which has issues staying connected,
# resulting in a `DEAUTH_LEAVING` message in `dmesg`.

# dunst (notifications) config
ln -sf $DIR/dots/dunst  ~/.config/dunst

# other defaults
ln -sf $DIR/dots/xinitrc ~/.xinitrc
ln -sf $DIR/dots/Xresources ~/.Xresources

# update the repositories
sudo apt update

# flash player
sudo apt install -y pepperflashplugin-nonfree
sudo update-pepperflashplugin-nonfree --install

# ranger
# note: For raster image previews (NOT ascii previews) with w3m-image to work,
# you have to use xterm or urxvt
sudo apt install -y ranger highlight atool caca-utils w3m w3m-img poppler-utils
ranger --copy-config=scope
ln -sf $DIR/dots/ranger/rc.conf ~/.config/ranger/rc.conf
ln -sf $DIR/dots/ranger/rifle.conf ~/.config/ranger/rifle.conf

# install some cool apps :D
# zathura       -- keyboard-driven pdf viewer
# ncdu          -- ncurses disk usage
# keepassx      -- password management
# adb           -- for interfacing with android phones
# xournal       -- for annotating pdfs
# pavucontrol   -- for managing sound
sudo apt install -y --no-install-recommends zathura android-tools-adb ncdu keepassx xournal pavucontrol firefox chromium-browser

# for ~/.bin/keepass
sudo pip2 install pykeepass
sudo apt install -y python-gtk2

# vpn
sudo apt install -y openvpn stunnel4
sudo sed -i "s/ENABLED=0/ENABLED=1/" /etc/default/stunnel4
sudo service stunnel4 start

# autostart/stop vpn on wifi up/down
sudo cp $DIR/dots/misc/network/airvpn_up /etc/network/if-up.d/airvpn
sudo cp $DIR/dots/misc/network/airvpn_down /etc/network/if-post_down/airvpn

# GTK/QT themeing
sudo apt install -y gnome-accessibility-themes
rm -rf ~/.icons
ln -sf $DIR/assets/icons ~/.icons
ln $DIR/dots/gtkrc-2.0 ~/.gtkrc-2.0
ln $DIR/dots/gtkrc-3.0  ~/.config/gtk-3.0/settings.ini
echo -e "[Qt]\nstyle=GTK+" >> ~/.config/Trolltech.conf

# setup fonts
sudo ln -sf /etc/fonts/conf.avail/50-user.conf /etc/fonts/conf.d/50-user.conf
sudo apt install -y fonts-inconsolata xfonts-terminus
ln -sf $DIR/assets/fonts ~/.fonts
ln -sf $DIR/dots/fonts.conf ~/.fonts.conf
mkfontdir ~/.fonts
mkfontscale ~/.fonts
xset +fp ~/.fonts/
xset fp rehash
fc-cache -fv

# wallpapers
ln -sf $DIR/assets/walls ~/.walls
ln -sf ~/.walls/0.jpg ~/.wall.jpg
chmod 644 ~/.wall.jpg

# for easily updating system time to current time zone
# to preview, run `tzupdate -p`
# to make the change, run `sudo tzupdate`
sudo pip2 install git+https://github.com/cdown/tzupdate

# TODO remove?
# power management stuff
# note:
# /etc/systemd/logind.conf
#   HandleLidSwitch=suspend
#   HandlePowerKey=ignore

# TODO remove?
# this was necessary to get sound and video working on the C720 (sound and video was only playable by root)
sudo adduser ftseng audio
sudo adduser ftseng pulse-access
sudo adduser ftseng video

# firefox config
mkdir -p ~/.mozilla/firefox/profile.default/chrome
ln -sf $DIR/dots/firefox/userChrome.css ~/.mozilla/firefox/profile.default/chrome/userChrome.css
sed -i 's/Path=.*/Path=profile.default/' ~/.mozilla/firefox/profiles.ini

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

# monitor position preferences
ln -sf $DIR/dots/mons ~/.mons

# TODO remove?
# fixes some heinous c720 touchpad stuff
sudo cp $DIR/dots/misc/50-synaptics.conf /usr/share/X11/xorg.conf.d/50-synaptics.conf
sudo chown root:root /usr/share/X11/xorg.conf.d/50-synaptics.conf

# TODO remove?
# brightness adjustment fix
sudo cp $DIR/dots/misc/20-intel.conf /usr/share/X11/xorg.conf.d/20-intel.conf
sudo chown root:root /usr/share/X11/xorg.conf.d/20-intel.conf

# TODO remove?
# usb mouse fix
sudo mv /usr/share/X11/xorg.conf.d/20-mouse.conf /usr/share/X11/xorg.conf.d/20-mouse.conf.disabled

# better chinese character support
sudo apt install -y fonts-noto-cjk

# fixes for 5G wifi
# set networking card region
sudo apt install -y bcmwl-kernel-source
sudo sed -i -e 's/REGDOMAIN=.*/REGDOMAIN=US/g' /etc/default/crda

# tlp for better battery life
sudo add-apt-repository ppa:linrunner/tlp
sudo apt update
sudo apt install tlp --no-install-recommends

# for thinkpads
# sudo add-apt-repository ppa:morgwai/tpbat
# sudo apt update
# sudo apt install acpi-call-dkms
# sudo apt install tpacpi-bat # replacement for tm-smapi-dkms
