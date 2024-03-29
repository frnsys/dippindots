# NOTE: import GPG private key
# see ~/docs/keys/note.md for password hint
# requires the `~/docs` directory has been restored
# gpg --import ~/docs/keys/private.key
# then:
# gpg --edit-key <KEY_ID>
# gpg> trust
# and set to ultimate trust

SHELL := /bin/bash
dir = ~/.dippindots

headless: prereqs git langs rust headless-tools neovim misc-dots

laptop:\
	# deps
	prereqs git langs rust\

	# desktop environment
	wm bar notifications menu theme\

	# apps
	headless-tools gui-tools fm neovim\
		terminal browser vpn\
		signal torrents keepass android\
		documents \

	# media
	ffmpeg audio images mpv ncmpcpp scrots\

	# system config
	thinkpad tweaks screen language misc-dots

# ---

prereqs:
	@echo "Installing prereqs..."
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y --no-install-recommends python3 python3-pip python3-dev gcc gfortran build-essential g++ make cmake automake autoconf clang lld wget unzip git openssh-server software-properties-common libncurses5-dev libxml2-dev libxslt1-dev libyaml-dev bzip2 curl libsqlite3-dev gdebi libxcb-xinput-dev libxi-dev
	sudo apt install -y libatlas-base-dev liblapack-dev libopenblas-dev libopenblas-base libatlas3-base
	sudo apt install -y ninja-build
 	sudo pip3 install meson

	# Get rid of snap
	sudo rm -rf /var/cache/snapd/
	sudo apt autoremove --purge snapd
	rm -rf ~/snap
	echo "Package: snapd\nPin: release a=*\nPin-Priority: -10" | sudo tee -a /etc/apt/preferences.d/nosnap.pref
	sudo apt update

	# Get rid of some other unnecessary ubuntu server stuff
	sudo apt uninstall -y mdadm multipath-tools cloud-init

	# necessary for installing from git with cargo
	eval `ssh-agent -s`
	ssh-add ~/.ssh/id_rsa

headless-tools:
	@echo "Installing fzf..."
	@echo "Say NO to auto-completion for performance"
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install

	sudo apt install -y --no-install-recommends wget curl jq htop tree cryptsetup silversearcher-ag dhcpcd5 gnupg dnsutils ncdu net-tools iw wireless-tools powertop dfc rename
	cargo install fd-find ripgrep jless

	# For LAN/local hostname resolution
	sudo apt install -y avahi-daemon libnss-mdns

gui-tools:
	# libnotify-bin - for `notify-send` to create notifications
	# gdebi - easier installation of deb packages
	sudo apt install -y libnotify-bin gdebi wl-clipboard
	sudo apt install -y --no-install-recommends dos2unix sqlitebrowser rclone
	sudo pip3 install -U yt-dlp
	cargo install pastel

	# Colorpicker
	git clone --depth 1 git@github.com:hyprwm/hyprpicker.git /tmp/hyprpicker && \
		cd /tmp/hyprpicker && \
		cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build && \
		cmake --build ./build --config Release --target hyprpicker -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF` && \
		cmake --install ./build

	# for easily updating system time to current time zone
	# to preview, run `tzupdate -p`
	# to make the change, run `sudo tzupdate`
	sudo pip3 install -U tzupdate

	cargo install --git ssh://git@github.com/frnsys/agenda.git

git:
	@echo "Installing git..."
	sudo add-apt-repository ppa:git-core/ppa -y
	sudo apt update
	sudo apt install -y git

	curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
	sudo apt install -y git-lfs
	git lfs install

	mkdir -p ~/.config/git
	ln -sf $(dir)/dots/git/gitignore ~/.config/git/ignore
	ln -sf $(dir)/dots/git/gitconfig ~/.gitconfig

	# ssh access
	ssh -vT git@github.com

neovim:
	@echo "Installing neovim..."
	# Lua, python interps, and X11/system clipboard support
	sudo apt install -y \
		lua5.1 liblua5.1-dev \
		python3-dev \
		libx11-dev libxtst-dev libxt-dev \
		libsm-dev libxpm-dev \
		gettext fswatch

	# wget https://github.com/neovim/neovim/archive/refs/tags/v0.9.4.tar.gz -O /tmp/neovim.tar.gz
	wget https://github.com/neovim/neovim/archive/refs/tags/nightly.tar.gz -O /tmp/neovim.tar.gz
	cd /tmp; tar -xzvf neovim.tar.gz; \
		cd neovim-*; make CMAKE_BUILD_TYPE=RelWithDebInfo && sudo make install \
			&& sudo ln -sf /usr/local/bin/nvim /usr/bin/vi \
			&& sudo ln -sf /usr/local/bin/nvim /usr/bin/vim \
			&& sudo ln -sf /usr/bin/vim /etc/alternatives/editor
	ln -sf $(dir)/dots/nvim ~/.config/nvim

rust:
	@echo "Installing rust..."
	curl -sf -L https://static.rust-lang.org/rustup.sh | sh
	rustup toolchain add nightly
	rustup component add rust-src --toolchain nightly
	rustup component add clippy --toolchain nightly
	rustup override set nightly
	curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz -o /tmp/rust-analyzer.gz
	gunzip /tmp/rust-analyzer.gz
	sudo mv /tmp/rust-analyzer /usr/local/bin/rust-analyzer
	sudo chmod +x /usr/local/bin/rust-analyzer
	source ~/.cargo/env

langs:
	@echo "Installing python & node..."
	curl https://mise.run | sh
	eval "$(~/.local/bin/mise activate bash)"
	mise use --global node@20
	mise use --global python@3.11

ncmpcpp:
	# build the latest ncmpcpp
	sudo apt install -y libboost-all-dev libfftw3-dev doxygen libncursesw5-dev libtag1-dev libcurl4-openssl-dev libmpdclient-dev libtool
	git clone https://github.com/arybczak/ncmpcpp.git /tmp/ncmpcpp
	cd /tmp/ncmpcpp;\
		git checkout 0.9.2;\
		./autogen.sh;\
		autoreconf --force --install;\
		BOOST_LIB_SUFFIX="" ./configure --enable-visualizer --enable-outputs --with-taglib --with-fftw;\
		make && sudo make install
	ln -sf $(dir)/dots/ncmpcpp ~/.ncmpcpp

	sudo apt install -y mpd mpc
	mkdir ~/.mpd/
	touch ~/.mpd/{mpd.db,mpd.log,mpd.pid,mpd.state}
	ln -sf $(dir)/dots/mpd ~/.mpd/mpd.conf
	sudo systemctl disable --now mpd # prevent conflicts with user instance
	sudo systemctl stop mpd.socket

ffmpeg:
	sudo apt install -y autoconf automake build-essential libfreetype6-dev libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texi2html zlib1g-dev libx264-dev libmp3lame-dev libfdk-aac-dev libvpx-dev libopus-dev libpulse-dev yasm libvidstab-dev libtool libwebp-dev libssl-dev libdav1d-dev

	# libass
	sudo apt install -y libfribidi-dev libfontconfig1-dev libharfbuzz-dev
	git clone --depth=1 https://github.com/libass/libass.git /tmp/libass
	cd /tmp/libass && ./autogen.sh && ./configure --enable-shared\
		&& make && sudo make install

	# NOTE: you need to make sure your ffmpeg included libs (e.g. livavutil)
	# match those needed by mpv.
	git clone --depth=1 --branch n4.4.4 git://source.ffmpeg.org/ffmpeg.git /tmp/ffmpeg

	# x265
	wget https://bitbucket.org/multicoreware/x265_git/downloads/x265_3.5.tar.gz -O /tmp/ffmpeg/x265.tar.gz
	cd /tmp/ffmpeg; tar -xzvf x265.tar.gz
	cd /tmp/ffmpeg/x265_*/build/linux\
		&& CFLAGS=-fPIC cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="/usr/local/ffmpeg" -DENABLE_SHARED:bool=on ../../source\
		&& make && sudo make install

	# vidstab
	git clone https://github.com/georgmartius/vid.stab.git /tmp/ffmpeg/vid.stab
	cd /tmp/ffmpeg/vid.stab && cmake . && make && sudo make install

	# compile ffmpeg
	cd /tmp/ffmpeg && \
	PKG_CONFIG_PATH="/usr/local/ffmpeg/lib/pkgconfig" ./configure \
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
		--enable-libwebp \
		--enable-libdav1d \
		--enable-nonfree \
		--enable-openssl \
		--enable-shared \
		--enable-libvidstab \
		&& make && sudo make install\
		&& sudo sh -c "echo '/usr/local/ffmpeg/lib' > /etc/ld.so.conf.d/ffmpeg.conf"\
		&& sudo ldconfig

mpv:
	sudo apt install -y mpc mpv
	ln -sf $(dir)/dots/mpv ~/.config/mpv

	# mpvc for controlling mpv
	git clone --depth 1 https://github.com/lwilletts/mpvc.git /tmp/mpvc
	cd /tmp/mpvc && sudo make

audio:
	# Use pipewire. `pavucontrol` still works with pipewire.
	# Get a version of pipewire with support for the AAC bluetooth codec
	# sudo add-apt-repository ppa:aglasgall/pipewire-extra-bt-codecs
	sudo apt update
	sudo apt install -y --no-install-recommends alsa-utils pavucontrol pulseaudio-utils pipewire pipewire-pulse wireplumber pipewire-audio-client-libraries libspa-0.2-bluetooth
	sudo touch /usr/share/pipewire/media-session.d/with-pulseaudio # Use pipewire as pulseaudio
	sudo apt install -y pulsemixer

	# bluetooth
	# see ~/notes/linux/bluetooth.md
	sudo apt install -y bluez libbluetooth3 libbluetooth-dev bluez-tools blueman

menu:
	sudo apt install scdoc wayland-protocols libcairo-dev libpango1.0-dev libxkbcommon-dev libwayland-dev
	git clone --depth 1 git@github.com:Cloudef/bemenu.git /tmp/bemenu && \
		cd /tmp/bemenu && \
		make clients wayland && sudo make install PREFIX=/usr

scrots:
	# for screenshots
	sudo apt install -y grim slurp

	# for screen recordings
	sudo apt install -y gifsicle
	sudo apt install -y libavutil-dev libavcodec-dev libavformat-dev libswscale-dev libpulse-dev libavdevice-dev
	git clone --depth 1 git@github.com:ammen99/wf-recorder.git  /tmp/wf-recorder && \
		cd /tmp/wf-recorder && \
		meson build --prefix=/usr --buildtype=release && \
		ninja -C build && sudo ninja -C build install

images:
	cargo install --git ssh://git@github.com/frnsys/vu.git

	# imagemagick with AVIF support
	git clone https://aomedia.googlesource.com/aom /tmp/aom
	cd /tmp/aom && git checkout tags/v3.5.0\
		&& mkdir aom_build && cd aom_build\
		&& cmake .. && make && sudo make install

	sudo apt install -y libde265-dev
	wget "https://github.com/strukturag/libheif/archive/refs/tags/v1.14.0.tar.gz" -O /tmp/libheif.tar.gz
	cd /tmp/ && tar -xzvf libheif.tar.gz && mv libheif-* libheif
	cd /tmp/libheif/third-party && bash aom.cmd
	cd /tmp/libheif && ./autogen.sh && ./configure\
		&& make && sudo make install

	wget "https://github.com/ImageMagick/ImageMagick/archive/refs/tags/7.1.0-53.tar.gz" -O /tmp/imagemagick.tar.gz
	cd /tmp/ && tar -xzvf imagemagick.tar.gz
	cd /tmp/ImageMagick-*\
		&& ./configure --with-heic=yes\
		&& make && sudo make install
	sudo ldconfig

fm:
	cargo install --git https://github.com/sxyazi/yazi
	ln -sf $(dir)/dots/yazi  ~/.config/yazi

wm:
	# swaybg and swaylock for background and lock screen
	sudo apt install -y swaybg

	sudo apt install -y libgdk-pixbuf2.0-dev libxkbcommon-dev libpam0g-dev libcairo2-dev
	git clone --depth 1 git@github.com:swaywm/swaylock.git /tmp/swaylock && \
		cd /tmp/swaylock && \
		meson build && \
		ninja -C build && \
		sudo ninja -C build install

	# Monitor power state control
	git clone 'https://git.sr.ht/~leon_plickat/wlopm' /tmp/wlopm && \
		cd /tmp/wlopm && make && sudo make install

	# Inhibit idle while audio is playing
	git clone --depth 1 git@github.com:ErikReider/SwayAudioIdleInhibit.git /tmp/inhibit-idle && \
		cd /tmp/inhibit-idle && \
		meson build && \
		ninja -C build && \
		sudo meson install -C build

	# Build swayidle from source, the repo version is out-of-date.
	git clone --depth 1 git@github.com:swaywm/swayidle.git /tmp/swayidle && \
		cd /tmp/swayidle &&
		meson build && \
		ninja -C build && \
		sudo ninja -C build install

	# Need zig to build river
	wget https://ziglang.org/download/0.11.0/zig-linux-x86_64-0.11.0.tar.xz -O /tmp/zig.tar.xz && \
		cd /tmp/ && tar -xJvf zig.tar.xz && \
		cd zig-*

	# Dependencies for wlroots
	sudo apt install -y check seatd libseat-dev udev libdrm-dev libgbm-dev libxkbcommon-dev
	wget https://gitlab.freedesktop.org/libinput/libinput/-/archive/1.25.0/libinput-1.25.0.tar.gz -O /tmp/libinput.tar.gz && \
		cd /tmp/ && tar -xzvf libinput.tar.gz && \
		cd libinput-* && \
		meson setup build && \
		ninja -C build && \
		sudo ninja -C build install
	wget https://www.cairographics.org/releases/pixman-0.43.4.tar.gz -O /tmp/pixman.tar.gz && \
		cd /tmp/ && tar -xzvf pixman.tar.gz && \
		cd pixman-* && \
		meson setup build && \
		ninja -C build && \
		sudo ninja -C build install
	wget https://gitlab.freedesktop.org/emersion/libdisplay-info/-/archive/0.1.1/libdisplay-info-0.1.1.tar.bz2 -O /tmp/libdisplay-info.tar.bz2 && \
		cd /tmp/ && tar -xzvf libdisplay-info.tar.bz2 && \
		cd libdisplay-info-* && \
		meson setup build && \
		ninja -C build && \
		sudo ninja -C build install
	wget https://gitlab.freedesktop.org/emersion/libliftoff/-/archive/v0.4.1/libliftoff-v0.4.1.tar.bz2 -O /tmp/libliftoff.tar.bz2 && \
		cd /tmp/ && tar -xzvf libliftoff.tar.bz2 && \
		cd libliftoff-* && \
		meson setup build && \
		ninja -C build && \
		sudo ninja -C build install
	git clone git@github.com:vcrhonek/hwdata.git /tmp/hwdata && \
		cd /tmp/hwdata && ./configure && make download && sudo make install
	wget https://gitlab.freedesktop.org/wlroots/wlroots/-/archive/0.17.2/wlroots-0.17.2.zip -O /tmp/wlroots.zip && \
		cd /tmp/ && unzip wlroots.zip && \
		cd wlroots-* && \
		meson setup build && \
		ninja -C build && \
		sudo ninja -C build install

	# Wayland
	sudo apt install -y --no-install-recommends xsltproc xmlto libclang-cpp14 doxygen
	wget https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/1.34/downloads/wayland-protocols-1.34.tar.xz -O /tmp/wayland-protocols.tar.xz && \
		cd /tmp/ && tar -xJvf wayland-protocols.tar.xz && \
		cd wayland-protocols-* && \
		meson setup build && \
		ninja -C build && \
		sudo ninja -C build install
	wget https://gitlab.freedesktop.org/wayland/wayland/-/archive/1.22.0/wayland-1.22.0.tar.gz -O /tmp/wayland.tar.gz && \
		cd /tmp/ && tar -xzvf wayland.tar.gz && \
		cd wayland-1.22.0 && \
		meson setup build && \
		ninja -C build && \
		sudo ninja -C build install

	# Build river
	sudo apt install -y libevdev
	git clone --depth 1 https://codeberg.org/river/river.git /tmp/river && \
		cd /tmp/river && \
		git submodule update --init && \
		sudo /tmp/zig-*/zig build -Doptimize=ReleaseSafe --prefix /usr/local install

	# River layout system
	git clone --depth 1 'https://git.sr.ht/~novakane/rivercarro' /tmp/rivercarro && \
		cd /tmp/rivercarro && \
		git submodule update --init && \
		sudo /tmp/zig-*/zig build -Doptimize=ReleaseSafe --prefix /usr/local install

	mkdir ~/.config/river
	ln -s $(dir)/dots/river ~/.config/river/init

	# kanshi for display management
	# Get output/monitor connector names
	# grep . /sys/class/drm/*/status
	mkdir -p ~/.config/kanshi && touch ~/.config/kanshi/config
	git clone --depth 1 git@github.com:varlink/libvarlink.git /tmp/libvarlink && \
		cd /tmp/libvarlink && \
		meson setup build && \
		ninja -C build && \
		sudo ninja -C build install
	git clone --depth 1 'https://git.sr.ht/~emersion/libscfg' /tmp/libscfg && \
		cd /tmp/libscfg && \
		meson setup build && \
		ninja -C build && \
		sudo ninja -C build install
	git clone --depth 1 'https://git.sr.ht/~emersion/kanshi' /tmp/kanshi && \
		cd /tmp/kanshi && \
		meson setup build && \
		ninja -C build && \
		sudo ninja -C build install

bar:
	cargo install --git ssh://git@github.com/frnsys/sema.git

notifications:
	git clone --depth 1 git@github.com:emersion/mako.git /tmp/mako &&\
		cd /tmp/mako && \
		meson build && \
		ninja -C build && \
		sudo meson install -C build

	# https://github.com/emersion/mako/issues/257
	sudo apt install apparmor-utils
	sudo aa-disable /etc/apparmor.d/fr.emersion.Mako
	mkdir ~/.config/mako
	ln -s $(dir)/dots/mako ~/.config/mako/config

terminal:
	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
	ln -sf $(dir)/dots/kitty ~/.config/kitty/kitty.conf

browser:
	# Firefox Nightly
	wget "https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux64&lang=en-US" -O /tmp/firefox.tar.bz2
	cd /tmp/ && tar -xzvf firefox.tar.bz2
	sudo mv /tmp/firefox /opt/firefox
	sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox

	# Google Chrome
	wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmour -o /usr/share/keyrings/google_linux_signing_key.gpg
	sudo sh -c 'echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
	sudo apt update
	sudo apt install google-chrome-stable

	# firefox config
	# In `about:config`, set:
	#   - `media.peerconnection.enabled` to false to prevent WebRTC IP leaks
	#   - `toolkit.legacyUserProfileCustomizations.stylesheets` to true
	#   - `browser.fullscreen.autohide` to false
	#   - `ui.systemUsesDarkTheme` to 1 (you may have to manually add this preference)
	#   - `dom.input.fallbackUploadDir` to `~/downloads` to stop it from trying to upload from `~/Desktop`
	# Also disabled hardware acceleration, had issues with slow painting otherwise
	mkdir -p ~/.mozilla/firefox/profile.default/chrome
	ln -sf $(dir)/dots/firefox/userChrome.css ~/.mozilla/firefox/profile.default/chrome/userChrome.css
	ln -sf $(dir)/dots/firefox/userContent.css ~/.mozilla/firefox/profile.default/chrome/userContent.css
	sed -i 's/Path=.*/Path=profile.default/' ~/.mozilla/firefox/profiles.ini # NOTE this file might not exist until you launch firefox
	# extensions
	# - https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/
	# - hili

	# Change default browser
	sudo update-alternatives --config x-www-browser
	sudo update-alternatives --config gnome-www-browser

vpn: # wireguard & mullvad
	sudo apt install -y wireguard resolvconf
	wget "https://mullvad.net/fr/download/app/deb/latest" -O /tmp/mullvad.deb
	sudo gdebi /tmp/mullvad.deb

theme: # wallpaper, fonts, etc
	# GTK/QT themeing
	# Note that the font defined here is
	# what sets the `system-ui` font in browsers
	sudo apt install -y gnome-accessibility-themes
	mkdir ~/.config/{gtk-3.0,gtk-4.0}
	ln -sf $(dir)/dots/misc/gtk.css ~/.config/gtk-3.0/gtk.css
	ln -sf $(dir)/dots/misc/gtk.css ~/.config/gtk-4.0/gtk.css
	echo -e "[Qt]\nstyle=GTK+" >> ~/.config/Trolltech.conf
	gsettings set org.gnome.desktop.interface color-scheme prefer-dark

	# setup fonts
	sudo ln -sf /etc/fonts/conf.avail/50-user.conf /etc/fonts/conf.d/50-user.conf
	sudo apt install -y fonts-inconsolata xfonts-terminus ttf-mscorefonts-installer fonts-noto-color-emoji
	mkdir -p ~/.config/fontconfig
	ln -sf $(dir)/assets/fonts ~/.fonts
	ln -sf $(dir)/dots/misc/fonts.conf ~/.fonts.conf
	ln -sf $(dir)/dots/misc/fonts.conf ~/.config/fontconfig/fonts.conf
	mkfontdir ~/.fonts
	mkfontscale ~/.fonts
	fc-cache -fv

	sudo mkdir /usr/share/fonts/truetype/robotomono
	sudo wget --content-disposition -P /usr/share/fonts/truetype/robotomono https://github.com/googlefonts/RobotoMono/raw/main/fonts/ttf/RobotoMono-{Bold,BoldItalic,Italic,Light,LightItalic,Medium,MediumItalic,Regular,Thin,ThinItalic}.ttf?raw=true
	sudo fc-cache -fv

	# wallpapers
	ln -sf $(dir)/assets/walls ~/.walls
	ln -sf ~/.walls/1.jpg ~/.wall.jpg
	chmod 644 ~/.wall.jpg

thinkpad: # thinkpad-specific stuff
	# tlp for better battery life
	# also provides utility commands `bluetooth` and `wifi`
	# which are used elsewhere in scripts
	sudo add-apt-repository -y ppa:linrunner/tlp
	sudo apt update
	sudo apt install tlp --no-install-recommends
	sudo apt install acpi-call-dkms
	# replacement for tm-smapi-dkms
	git clone https://github.com/teleshoes/tpacpi-bat /tmp/tpacpi-bat
	cd /tmp/tpacpi-bat && ./install.pl

	sudo systemctl enable tlp.service

tweaks:
	# fixes for 5G wifi
	# set networking card region
	sudo apt install -y bcmwl-kernel-source
	sudo iw reg set US # Set CRDA region to US

	# Disable these for faster startup time
	sudo systemctl disable apt-daily.service
	sudo systemctl disable apt-daily-upgrade.service

	# Use more familiar network interface names (wlan0, eth0)
	# Some parts of the dotfiles expect names like wlan0
	sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"net.ifnames=0 biosdevname=0 acpi_osi=linux acpi_backlight=vendor\"/" /etc/default/grub
	sudo update-grub
	sudo update-initramfs -u

	# NOTE: You will need to edit `/etc/netplan/00-installer-config.wifi.yaml` and:
	# - Change the interface name to `wlan0`
	# - Add "optional: true" as part of its config, e.g.
	# 	...
	#	wlan0:
	#		optional: true
	#	...
	#	This will prevent waiting for the network blocking the startup sequence.

	# Setup passwordless sudo/root for certain commands
	sudo cp $(dir)/dots/misc/00_anarres /etc/sudoers.d/

	# Remove default home directories ("Desktop", etc)
	sudo sed -i 's/enabled=True/enabled=False/' /etc/xdg/user-dirs.conf

	# larger font for boot tty
	sudo sed -i 's/FONTFACE=.*/FONTFACE="Terminus"/' /etc/default/console-setup
	sudo sed -i 's/FONTSIZE=.*/FONTSIZE="14x28"/' /etc/default/console-setup

	# For for X1 Nano G1
	# where there is crackling/static
	# when headphones are plugged in in.
	sudo apt install -y alsa-tools
	# sudo hda-verb /dev/snd/hwC0D0 0x1d SET_PIN_WIDGET_CONTROL 0x0
	sudo cp $(dir)/dots/misc/audio_fix.service /etc/systemd/system/hdaverb.service
	sudo systemctl enable hdaverb

	# for USB input devices
	sudo apt install linux-image-generic
	sudo update-initramfs -k all -c
	# then reboot

android:
	sudo apt install -y android-tools-adb
	git clone https://github.com/google/adb-sync /tmp/adb-sync
	sudo cp /tmp/adb-sync/adb-sync /usr/local/bin/

torrents:
	sudo add-apt-repository ppa:deluge-team/stable
	sudo apt update
	sudo apt install -y deluged deluge-console nicotine
	mkdir ~/.config/deluge
	ln -sf $(dir)/dots/misc/deluged.conf ~/.config/deluge/core.conf

documents:
	# pandoc
	sudo apt install -y --no-install-recommends texlive lmodern cm-super texlive-latex-recommended texlive-latex-extra texlive-plain-generic texlive-xetex
	wget https://github.com/jgm/pandoc/releases/download/3.1.4/pandoc-3.1.4-1-amd64.deb -O /tmp/pandoc.deb
	sudo gdebi --n /tmp/pandoc.deb

	# Fix soul.sty so it can be used with xelatex/unicode
	sudo sed -i 's/\\newfont\\SOUL@tt{ectt1000}/\\font\\SOUL@tt=[RobotoMono-Regular.ttf]/' /usr/share/texlive/texmf-dist/tex/generic/soul/soul.sty

	# suckless tabbed
	sudo apt install zathura zathura-pdf-poppler suckless-tools

	# flatpak run org.onlyoffice.desktopeditors
	flatpak install flathub org.onlyoffice.desktopeditors

keepass:
	sudo apt install -y --no-install-recommends keepassx oathtool
	cargo install --git ssh://git@github.com/frnsys/kpass.git

language:
	# better chinese character support
	sudo apt install -y fonts-noto-cjk

	# chinese pinyin input
	# Hit CTRL+SPACE+LEFT_SHIFT, in that order
	sudo apt install -y fcitx fcitx-googlepinyin

signal:
	# signal desktop client
	wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > /tmp/signal-desktop-keyring.gpg
	cat /tmp/signal-desktop-keyring.gpg | sudo tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
	echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
		sudo tee -a /etc/apt/sources.list.d/signal-xenial.list
	sudo apt update && sudo apt install -y signal-desktop

screen:
	sudo usermod -aG video ${USER}
	git clone --depth 1 git@github.com:Hummer12007/brightnessctl.git /tmp/brightnessctl && \
		cd /tmp/brightnessctl && \
		./configure && make install
	sudo apt install -y gammastep # redshift

misc-dots:
	ln -sf $(dir)/dots/bash/bash_profile ~/.bash_profile
	ln -sf $(dir)/dots/bash/bashrc ~/.bashrc
	ln -sf $(dir)/dots/bash/inputrc ~/.inputrc
	ln -sf $(dir)/bin ~/.bin
	ln -s $(dir)/dots/Xdefaults ~/.Xdefaults

	# symlink notes and sites
	ln -sf $(dir)/dots/port ~/.port
