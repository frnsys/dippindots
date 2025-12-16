SHELL := /bin/bash
dir = ~/.dots

all: base de media apps laptop
base: prereqs git langs rust shell tools editor network other
de: wm notifications menu theme terminal scrots fm
media: audio images video music
laptop: tweaks screen
apps: utils browser vpn torrents android documents dev

# ---

prereqs:
	@echo "Installing prereqs..."
	sudo zypper in gcc gcc-c++ make cmake automake autoconf clang lld wget zip unzip openssh-server bzip2 curl ninja meson opi unar ntp

	timedatectl set-ntp true
	sudo systemctl enable --now ntpd

	sudo zypper in avahi
	sudo systemctl enable --now avahi-daemon
	sudo firewall-cmd --permanent --zone=public --add-port=5353/udp
	sudo firewall-cmd --permanent --zone=public --add-protocol=igmp
	sudo firewall-cmd --permanent --zone=public --add-service=ssdp
	sudo firewall-cmd --permanent --zone=public --add-service=mdns

rust:
	@echo "Installing rust..."
	sudo zypper in rustup
	rustup toolchain add nightly
	rustup component add rust-src --toolchain nightly
	rustup component add clippy --toolchain nightly
	rustup component add rust-analyzer --toolchain nightly
	rustup override set nightly
	rustup default nightly
	rustup target add wasm32-unknown-unknown
	sudo zypper in mold

langs:
	@echo "Installing python & node..."
	curl https://mise.run | sh
	eval "$(~/.local/bin/mise activate bash)"
	mise use --global node@20
	mise use --global python@3.12

git:
	@echo "Installing git..."
	sudo zypper in git git-lfs gitui
	git lfs install

	mkdir -p ~/.config/git
	ln -sf $(dir)/dots/git/gitignore ~/.config/git/ignore
	ln -sf $(dir)/dots/git/gitconfig ~/.gitconfig

tools:
	sudo zypper in -y libopenssl-devel
	sudo zypper in -y fzf jq htop tree gnupg ncdu dfc ffmpeg fd ripgrep

	# Usage: `cargo install-update -a`
	cargo install cargo-update

utils:
	# Note: Run with `sudo -EH yast2`.
	sudo zypper in yast2-control-center-qt
	sudo zypper in sqlitebrowser rclone yt-dlp
	sudo zypper in xcursor-themes hyprpicker

	opi signal-desktop

	cargo install --git https://github.com/frnsys/kpass.git
	cargo install --git https://github.com/frnsys/agenda.git

	sudo zypper in -y flatpak

dev:
	sudo zypper in -y podman # podman for docker
	sudo flatpak install flathub io.podman_desktop.PodmanDesktop
	sudo zypper in -y just
	cargo install cross
	cargo install bacon
	cargo install wasm-pack wasm-bindgen-cli
	cargo install cargo-expand cargo-machete
	cargo install mdbook mdbook-toc

	pip install pyright

	# A bit of a necessity with rust-analyzer,
	# as on large projects it can hog all memory and cause the
	# system to lock up.
	sudo zypper in -y earlyoom
	sudo systemctl enable --now earlyoom

editor:
	@echo "Installing neovim..."
	sudo zypper in bat wl-clipboard
	wget https://github.com/neovim/neovim/archive/refs/tags/nightly.tar.gz -O /tmp/neovim.tar.gz
	cd /tmp; tar -xzvf neovim.tar.gz; \
		cd neovim-*; make CMAKE_BUILD_TYPE=Release && sudo make install \
			&& sudo ln -sf /usr/local/bin/nvim /usr/bin/vi \
			&& sudo ln -sf /usr/local/bin/nvim /usr/bin/vim \
			&& sudo ln -sf /usr/bin/vim /etc/alternatives/editor
	ln -sf $(dir)/dots/nvim ~/.config/nvim

network:
	# nmtui should already be installed by default.
	sudo zypper install dhcp-client systemd-network systemd-resolved

	# Set group for access to network management.
	# Requires logout/login for changes to take effect.
	sudo groupadd netdev
	sudo usermod -aG netdev francis

	sudo systemctl enable --now systemd-networkd
	sudo systemctl enable --now systemd-resolved

music:
	sudo zypper in ncmpcpp mpd mpclient
	ln -sf $(dir)/dots/ncmpcpp ~/.ncmpcpp
	mkdir ~/.mpd/
	touch ~/.mpd/{mpd.db,mpd.log,mpd.pid,mpd.state}
	ln -sf $(dir)/dots/mpd ~/.mpd/mpd.conf

	# disable as the system instance conflicts with the user instance
	sudo systemctl disable --now mpd
	systemctl enable --now --user mpd

video:
	opi codecs

	sudo zypper in mpv
	ln -sf $(dir)/dots/mpv ~/.config/mpv

	# mpvc for controlling mpv
	git clone --depth 1 https://github.com/lwilletts/mpvc.git /tmp/mpvc
	cd /tmp/mpvc && sudo make install

	# For syncing/aligning subtitles
	cargo install alass-cli

audio:
	sudo zypper in alsa-utils bluez bluetuith
	sudo flatpak install flathub com.saivert.pwvucontrol

shell:
	sudo zypper in fish
	mkdir ~/.config/fish
	ln -s $(dir)/dots/fish ~/.config/fish/config.fish

menu:
	sudo zypper in bemenu

scrots:
	# for screenshots & screen recordings
	sudo zypper in grim slurp gifsicle wf-recorder

images:
	cargo install --git https://github.com/frnsys/vu.git
	sudo zypper in ImageMagick ImageMagick-extra
	sudo zypper in libwebpdecoder3 libwebp-devel libwebp-tools

	sudo flatpak install flathub com.github.PintaProject.Pinta
	flatpak -u override --filesystem=~/.config/gtk-4.0:ro
	flatpak -u override com.github.PintaProject.Pinta --filesystem=~

fm:
	sudo zypper in -y poppler-tools ffmpegthumbnailer jq
	cargo install yazi-fm
	ln -sf $(dir)/dots/yazi  ~/.config/yazi

wm:
	sudo zypper in swaybg swayidle

	# Lockscreen with virtual keyboard,
	# for touchscreen.
	sudo zypper in gtklock gtk3-devel
	git clone git@github.com:frnsys/gtklock-virtkb-module.git /tmp/gtklock
	cd /tmp/gtklock && make && sudo make install

	# WM
	sudo zypper in niri xdg-desktop-portal-gnome wlr-randr xwayland-satellite

	# For file dialogs. See <https://github.com/YaLTeR/niri/wiki/Important-Software#portals>
	sudo zypper in nautilus

	# Inhibit idle while audio is playing
	sudo zypper in libpulse-devel wayland-devel wayland-protocols-devel SwayAudioIdleInhibit

	mkdir ~/.config/niri
	ln -s $(dir)/dots/niri ~/.config/niri/config.kdl

notifications:
	sudo zypper in mako libnotify-tools
	mkdir ~/.config/mako
	ln -sf $(dir)/dots/mako ~/.config/mako/config

terminal:
	sudo zypper in kitty kitty-terminfo
	mkdir ~/.config/kitty
	ln -sf $(dir)/dots/kitty ~/.config/kitty/kitty.conf

browser:
	sudo zypper in ca-certificates-steamtricks ca-certificates-cacert \
		ca-certificates-mozilla ca-certificates-mozilla-prebuilt \
		ca-certificates

	sudo zypper in qutebrowser
	mkdir -p ~/.config/qutebrowser
	mkdir -p ~/.local/share/qutebrowser
	ln -sf $(dir)/dots/qute/config.yml ~/.config/qutebrowser/autoconfig.yml
	ln -sf $(dir)/dots/qute/userscripts ~/.local/share/qutebrowser/userscripts
	ln -sf $(dir)/dots/qute/greasemonkey ~/.local/share/qutebrowser/greasemonkey
	xdg-settings set default-web-browser org.qutebrowser.qutebrowser.desktop

	git clone --depth 1 https://github.com/mozilla/pdf.js.git /tmp/pdfjs
	cd /tmp/pdfjs && npm install && npx gulp generic
	mv /tmp/pdfjs/build/generic ~/.local/share/qutebrowser/pdfjs

	pip install adblock

	# For syncing tabs from Firefox Android
	wget https://github.com/Mikescher/firefox-sync-client/releases/download/v1.9.0/ffsclient_linux-amd64 -O /tmp/ffsclient
	chmod +x /tmp/ffsclient
	sudo mv /tmp/ffsclient /usr/local/bin/ffsclient
	# Then login with `ffsclient login`

	# Google Chrome
	opi chrome

vpn:
	# See bin/vpn.
	# Install VPN configs to `/etc/wireguard`.
	sudo zypper in wireguard-tools

theme:  # wallpaper, fonts, etc
	# GTK/QT themeing
	# Note that the font defined here is
	# what sets the `system-ui` font in browsers
	sudo zypper in -y gnome-themes-accessibility
	mkdir -p ~/.config/{gtk-3.0,gtk-4.0}
	ln -sf $(dir)/dots/misc/gtk.css ~/.config/gtk-3.0/gtk.css
	ln -sf $(dir)/dots/misc/gtk.css ~/.config/gtk-4.0/gtk.css
	echo -e "[Qt]\nstyle=GTK+" >> ~/.config/Trolltech.conf

	# setup fonts
	sudo ln -sf /etc/fonts/conf.avail/50-user.conf /etc/fonts/conf.d/50-user.conf
	sudo zypper in -y \
		saja-cascadia-code-fonts \
		google-inconsolata-fonts \
		google-noto-coloremoji-fonts \
		google-noto-fonts \
		google-noto-sans-cjk-fonts \
		terminus-bitmap-fonts \
		inter-fonts \
		fira-code-fonts \
		adobe-sourcesans3-fonts \
		adobe-sourcecodepro-fonts \
		symbols-only-nerd-fonts \
		google-noto-fonts \
		google-noto-sans-cjk-fonts

	mkdir -p ~/.config/fontconfig
	ln -sf $(dir)/dots/misc/fonts.conf ~/.fonts.conf
	ln -sf $(dir)/dots/misc/fonts.conf ~/.config/fontconfig/fonts.conf

	git clone --depth 1 git@github.com:alexmyczko/fnt.git /tmp/fnt
	sudo zypper install -y lcdf-typetools chafa
	cd /tmp/fnt && sudo make install
	fnt update
	fnt install google-dmmono
	fnt install google-gabarito
	fnt install google-spacemono
	fnt install google-ibmplexsans
	fnt install google-nanummyeongjo
	fnt install fonts-fantasque-sans
	fnt install google-atkinsonhyperlegible
	fnt install google-atkinsonhyperlegiblemono

	sudo mkdir /usr/share/fonts/truetype/robotomono
	sudo wget --content-disposition -P /usr/share/fonts/truetype/robotomono https://github.com/googlefonts/RobotoMono/raw/main/fonts/ttf/RobotoMono-{Bold,BoldItalic,Italic,Light,LightItalic,Medium,MediumItalic,Regular,Thin,ThinItalic}.ttf
	sudo fc-cache -fv

	# wallpapers
	ln -sf $(dir)/walls ~/.walls
	ln -sf ~/.walls/1.jpg ~/.wall.jpg
	chmod 644 ~/.wall.jpg

	sudo zypper rm --clean-deps plymouth
	sudo zypper addlock plymouth

tweaks:
	sudo zypper in acpi powertop libinput-tools
	# sudo zypper in --no-recommends tlp
	# sudo systemctl enable --now tlp
	# sudo systemctl enable --now powertop

	# For AMD Vulkan
	sudo zypper in libvulkan_radeon

	# Firmware updates
	sudo zypper in fwupd
	# fwupdmgr refresh && fwupdmgr update && fwupdmgr get-updates

	# Lower swappiness to avoid disk thrashing
	echo "vm.swappiness = 10" | sudo tee -a /etc/sysctl.conf
	sudo sysctl -p

	# grub edits: the easiest way to do these is with `sudo yast`

	# For memory-limited systems,
	# enable zswap for better swap performance & lower disk I/O.
	# Add:
	#	zswap.enabled=1 zswap.compressor=lzo zswap.max_pool_percent=20

	# You could also enable zram, but in my benchmarks
	# having both simultaneously leads to performance drops
	# compared to having one or the other on its own;
	# and zswap performs better than zram on its own.
	# sudo zypper in systemd-zram-service
	# sudo systemctl enable --now zramswap

	# Other recommended grub settings:
	# GRUB_TIMEOUT=0
	# GRUB_HIDDEN_TIMEOUT=0

android:
	sudo zypper in android-tools
	git clone https://github.com/google/adb-sync /tmp/adb-sync
	sudo cp /tmp/adb-sync/adb-sync /usr/local/bin/

	sudo flatpak install flathub org.localsend.localsend_app
	sudo firewall-cmd --permanent --zone=public --add-port=53317/udp
	sudo firewall-cmd --permanent --zone=public --add-port=53317/tcp

torrents:
	sudo zypper in qbittorrent
	sudo opi -n nicotine-plus
	sudo firewall-cmd --permanent --zone=public --add-port=36767/udp
	sudo firewall-cmd --permanent --zone=public --add-port=36767/tcp

documents:
	# Build sioyek from source, as the dev branch is way ahead of the last official release
	sudo zypper in freeglut-devel
	sudo zypper in qt6-base-common-devel qt6-base-devel qt6-svg-devel qt6-quickwidgets-devel qt6-texttospeech-devel
	git clone https://github.com/ahrm/sioyek.git /tmp/sioyek
	cd /tmp/sioyek \
		&& git checkout development \
		&& git submodule update --init --recursive \
		&& QMAKE=qmake6 ./build_linux.sh
	sudo cp -r /tmp/sioyek/build /opt/sioyek
	sudo ln -s /opt/sioyek/sioyek /usr/local/bin/sioyek

	mkdir ~/.config/sioyek
	ln -sf $(dir)/dots/sioyek/keys_user.config ~/.config/sioyek/keys_user.config
	ln -sf $(dir)/dots/sioyek/prefs_user.config ~/.config/sioyek/prefs_user.config

	sudo zypper in libreoffice-calc libreoffice-gtk3

	wget https://github.com/artempyanykh/marksman/releases/latest/download/marksman-linux-x64 -O /tmp/marksman
	chmod +x /tmp/marksman
	sudo mv /tmp/marksman /usr/local/bin/marksman

screen:
	sudo usermod -aG video ${USER}
	sudo zypper in brightnessctl gammastep

other:
	ln -sf $(dir)/dots/ignore ~/.ignore
	ln -sf $(dir)/dots/bash ~/.bash_profile
	ln -sf $(dir)/bin ~/.bin

	# symlink notes and sites
	ln -sf $(dir)/dots/port ~/.config/port.yml
