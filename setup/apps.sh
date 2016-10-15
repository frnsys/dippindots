DIR=$1

tput setaf 5
echo -e "\nInstalling some more goodies..."
tput sgr0
# note: some of this is tailored for my Lubuntu 14.04 (HugeGreenBug's distro) C720 laptop, beware!

# feh - image viewer/wallpaper manager
# xsel - clipboard
# dunst - notifications
# xdotool - simulating interactions with the GUI
# i3lock - locking the screen
# libnotify-bin - for `notify-send` to create notifications
# unclutter - hide cursor after inactivity
# xbacklight - control screen brightness
# hfsprogs - hfs+ file system support
# gdebi - easier installation of deb packages
# dhcpcd - for android usb tethering
# compton - for window/bar transparency and shadows
sudo apt-get update
sudo apt-get install xorg --no-install-recommends -y
sudo apt-get install feh xsel dunst xdotool i3lock libnotify-bin unclutter xbacklight hfsprogs gdebi dhcpcd deluged deluge-console compton -y

# auto-lock screen on sleep
sudo cp $DIR/dots/misc/00_screen /etc/pm/sleep.d/00_screen

# plymouth (splash) config
sudo apt-get install plymouth-theme-text
sudo update-alternatives --install /lib/plymouth/themes/default.plymouth default.plymouth /lib/plymouth/themes/text.plymouth 10
sudo update-alternatives --set default.plymouth /lib/plymouth/themes/text.plymouth
sudo update-initramfs -u

# rofi
git clone git@github.com:DaveDavenport/rofi.git /tmp/rofi
cd /tmp/rofi
git submodule update --init
sudo apt-get install -y libxkbcommon-x11-dev libxcb-util0-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev xutils-dev
sudo add-apt-repository -y 'deb http://debian.jpleau.ca/ jessie-backports main contrib non-free'
sudo apt-get update
sudo apt-get install -y --force-yes libxkbcommon-dev
git clone --recursive https://github.com/Airblader/xcb-util-xrm.git /tmp/xrm
cd /tmp/xrm
./autogen.sh --prefix=/usr
make
sudo make install
cd /tmp/rofi
autoreconf -i
mkdir build
cd build
../configure
make
sudo make install
cd $DIR

# build the latest ncmpcpp
# NOTE more recent versions of ncmpcpp do not work well with mopidy
# therefore installing from apt. ncmpcpp version 0.5.10 works alright.
# tested versions 0.6.6 and above which all did not work properly with mopidy.
sudo apt-get install ncmpcpp
ln -sf $DIR/dots/ncmpcpp ~/.ncmpcpp

# mopidy
# you must fill out config auth info yourself!
sudo apt-get install gstreamer1.0-libav gstreamer1.0-alsa
sudo apt-get install python-gst-1.0 \
    gir1.2-gstreamer-1.0 gir1.2-gst-plugins-base-1.0 \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly \
    gstreamer1.0-tools
sudo wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/jessie.list
sudo apt-get update
sudo apt-get install libspotify12 libspotify-dev
sudo pip2 install mopidy mopidy-soundcloud mopidy-spotify mopidy-local-sqlite
cp -r $DIR/dots/mopidy ~/.config/mopidy

# mpc
sudo apt-get install mpc -y

# build latest libass for ffmpeg and mpv
sudo apt-get install libfribidi-dev
git clone --depth=1 https://github.com/libass/libass.git /tmp/libass
cd /tmp/libass
./autogen.sh
./configure
make
sudo make install

# ffmpeg
sudo apt-get -y --force-yes install autoconf automake build-essential libfreetype6-dev libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texi2html zlib1g-dev libx264-dev libmp3lame-dev libfdk-aac-dev libvpx-dev libopus-dev libpulse-dev yasm
git clone --depth=1 git://source.ffmpeg.org/ffmpeg.git /tmp/ffmpeg
cd /tmp/ffmpeg

# a detour for x265
sudo apt-get install cmake
wget https://bitbucket.org/multicoreware/x265/downloads/x265_2.0.tar.gz -O /tmp/ffmpeg/x265.tar.gz
cd /tmp/ffmpeg
tar -xzvf x265.tar.gz
cd x265_*/build/linux
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
make
sudo make install

# compile ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --bindir="/usr/local/bin" \
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
  --enable-openssl
make
sudo make install
rm -rf ~/ffmpeg_build
cd $DIR

# build the latest mpv
git clone --depth=1 https://github.com/mpv-player/mpv-build.git /tmp/mpv
cd /tmp/mpv
./rebuild -j4
sudo ./install
cd $DIR

# bspwm - window manager
sudo apt-get install xcb libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev -y
git clone https://github.com/baskerville/bspwm.git /tmp/bspwm
git clone https://github.com/baskerville/sxhkd.git /tmp/sxhkd
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

# inkscape
sudo apt-get install -y inkscape
sudo ln -sf $DIR/dots/inkscape/default.xml /usr/share/inkscape/keys/default.xml
sudo ln -sf $DIR/dots/inkscape/icons.svg /usr/share/inkscape/icons/icons.svg

# urxvt - terminal
sudo apt-get install rxvt-unicode-256color -y
git clone https://github.com/muennich/urxvt-perls.git /tmp/urxvt-perls
sudo mv /tmp/urxvt-perls/* /usr/lib/urxvt/perl/
git clone https://github.com/majutsushi/urxvt-font-size.git /tmp/urxvt-font-size
sudo mv /tmp/urxvt-font-size/font-size /usr/lib/urxvt/perl/font-size

# ranger - file browser
# note: For raster image previews (NOT ascii previews) with w3m-image to work,
# you have to use xterm or urxvt
sudo apt-get install ranger highlight atool caca-utils w3m w3m-img poppler-utils -y
ranger --copy-config=scope
mkdir ~/.config/ranger/colorschemes
ln -sf $DIR/dots/ranger/euphrasia.py ~/.config/ranger/colorschemes/euphrasia.py
ln -sf $DIR/dots/ranger/rc.conf ~/.config/ranger/rc.conf

# wicd - managing network connections
sudo apt-get install wicd wicd-cli wicd-curses -y
sudo ln -sf /run/resolvconf/resolv.conf /var/lib/wicd/resolv.conf.orig

# dunst (notifications) config
ln -sf $DIR/dots/dunst  ~/.config/dunst

# other defaults
ln -sf $DIR/dots/xinitrc ~/.xinitrc
ln -sf $DIR/dots/Xresources ~/.Xresources

# update the repositories
sudo apt-get update

# flash player
sudo apt-get install pepperflashplugin-nonfree -y
sudo update-pepperflashplugin-nonfree --install

# install some cool apps :D
# zathura       -- keyboard-driven pdf viewer
# ncdu          -- ncurses disk usage
# keepassx      -- password management
# adb           -- for interfacing with android phones
# gcolor2       -- color picker
sudo apt-get install --no-install-recommends --yes zathura android-tools-adb ncdu keepassx gcolor2

# for ~/.bin/keepass
sudo pip2 install gtk
git clone git@github.com:brettviren/python-keepass.git /tmp/python-keepass
cd /tmp/python-keepass
sudo python2 setup.py install
cd $DIR

# vpn
sudo apt-get install -y openvpn stunnel4
sudo sed -i "s/ENABLED=0/ENABLED=1/" /etc/default/stunnel4
sudo service stunnel4 start

# autostart/stop vpn on wifi up/down
sudo cp $DIR/dots/misc/network/airvpn_up /etc/network/if-up.d/airvpn
sudo cp $DIR/dots/misc/network/airvpn_down /etc/network/if-post_down/airvpn

# chrome for netflix
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
sudo gdebi /tmp/chrome.deb

# scim, a modern version of sc (spreadsheet calculator)
cd /tmp
git clone https://github.com/andmarti1424/scim.git
cd scim/src
make && sudo make install
cd $DIR

# lxappearance for managing GTK themeing
sudo apt-get install lxappearance -y
git clone https://github.com/horst3180/arc-theme --depth 1 /tmp/arc
cd /tmp/arc
./autogen.sh --prefix=/usr
rm -rf ~/.icons
ln -sf $DIR/assets/icons ~/.icons
ln $DIR/dots/gtkrc-2.0 ~/.gtkrc-2.0

# setup fonts
sudo ln -sf /etc/fonts/conf.avail/50-user.conf /etc/fonts/conf.d/50-user.conf
sudo apt-get install fonts-inconsolata xfonts-terminus -y
ln -sf $DIR/assets/fonts ~/.fonts
ln -sf $DIR/dots/fonts.conf ~/.fonts.conf
mkfontdir ~/.fonts
mkfontscale ~/.fonts
xset +fp ~/.fonts/
xset fp rehash
fc-cache -fv

# wallpapers
ln -sf $DIR/assets/wallpapers ~/.wallpapers
ln -sf ~/.wallpapers/0.jpg ~/.wallpaper.jpg
chmod 644 ~/.wallpaper.jpg

# for easily updating system time to current time zone
# to preview, run `tzupdate -p`
# to make the change, run `sudo tzupdate`
sudo pip2 install git+https://github.com/cdown/tzupdate

# power management stuff
# note:
# /etc/systemd/logind.conf
#   HandleLidSwitch=suspend
#   HandlePowerKey=ignore

# this was necessary to get sound and video working on the C720 (sound and video was only playable by root)
sudo adduser ftseng audio
sudo adduser ftseng pulse-access
sudo adduser ftseng video

# firefox config
mkdir -p ~/.mozilla/firefox/profile.default/chrome
mkdir -p ~/.vimperator/colors
ln -sf $DIR/dots/firefox/userChrome.css ~/.mozilla/firefox/profile.default/chrome/userChrome.css
ln -sf $DIR/dots/firefox/userContent.css ~/.mozilla/firefox/profile.default/chrome/userContent.css
ln -sf $DIR/dots/firefox/vimperatorrc ~/.vimperatorrc
ln -sf $DIR/dots/firefox/colors.vimp ~/.vimperator/colors/colors.vimp

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
sudo apt-get install imagemagick recordmydesktop gifsicle

# clean: remove unwanted stuff (lubuntu 14.04)
# run this last as it will remove `network-manager` and we'll lose the internet connection
rm -rf ~/.sylpheed*
sudo apt-get purge mtpaint pidgin xchat* sylpheed* abiword* gnumeric* transmission* audacious* lightdm openbox network-manager xfce4-notifyd nautilus* whoopsie -y
sudo apt-get autoremove -y

# symlink notes and sites
ln -sf $DIR/dots/port ~/.port

# backup config
ln -s $DIR/dots/bkup ~/.bkup

# to setup the compose key
# for the AltGr prompt, select "default for keyboard"
# for the compose prompt, select right alt
sudo dpkg-reconfigure keyboard-configuration
# usage: press the compose key (e.g right alt), no need to hold it down, then
# press ", e for ë
# press ~, e for ẽ
# press ^, o for ô
# press ', a for á
# press `, a for à
# press =, e for €
# press -, l for £
# full reference: https://help.ubuntu.com/community/GtkComposeTable
