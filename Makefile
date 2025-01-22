# NOTE: import GPG private key
# see ~/docs/keys/note.md for password hint
# requires the `~/docs` directory has been restored
# gpg --import ~/docs/keys/private.key
# then:
# gpg --edit-key <KEY_ID>
# gpg> trust
# and set to ultimate trust

SHELL := /bin/bash
dir = ~/.dots

all: base de media apps laptop
base: prereqs git langs rust shell tools editor network other
de: wm bar notifications menu theme terminal scrots fm
media: audio images video music
laptop: tweaks screen
apps: utils browser vpn torrents android documents dev

# ---

prereqs:
	@echo "Installing prereqs..."
	sudo zypper in gcc gcc-c++ make cmake automake autoconf clang lld wget zip unzip openssh-server bzip2 curl ninja meson opi unar

	sudo zypper in avahi
	sudo systemctl enable --now avahi-daemon
	sudo firewall-cmd --permanent --zone=public --add-port=5353/udp
 	sudo firewall-cmd --permanent --zone=public --add-protocol=igmp
	sudo firewall-cmd --permanent --zone=public --add-service=ssdp
	sudo firewall-cmd --permanent --zone=public --add-service=mdns

rust:
	@echo "Installing rust..."
	curl -sf -L https://static.rust-lang.org/rustup.sh | sh
	export PATH=$PATH:~/.cargo/bin
	source ~/.cargo/env
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
	sudo zypper in fzf jq htop tree the_silver_searcher gnupg ncdu powertop dfc ffmpeg
	cargo install fd-find ripgrep zoxide

utils:
	# Note: Run with `sudo -EH yast2`.
	sudo zypper in yast2-control-center-qt
	sudo zypper in sqlitebrowser rclone yt-dlp
	sudo zypper in xcursor-themes hyprpicker

	opi signal-desktop

	cargo install --git https://github.com/frnsys/kpass.git
	cargo install --git https://github.com/frnsys/agenda.git
	cargo install --git https://github.com/frnsys/stash.git

	sudo zypper in -y flatpak

dev:
	sudo zypper in -y podman # podman for docker
	flatpak install flathub io.podman_desktop.PodmanDesktop
	cargo install just
	cargo install cross
	cargo install bacon
	cargo install wasm-pack wasm-bindgen-cli
	cargo install cargo-expand cargo-machete
	cargo install mdbook mdbook-toc

editor:
	@echo "Installing neovim..."
	sudo zypper in bat wl-clibpoard
	wget https://github.com/neovim/neovim/archive/refs/tags/v0.10.3.tar.gz -O /tmp/neovim.tar.gz
	cd /tmp; tar -xzvf neovim.tar.gz; \
		cd neovim-*; make CMAKE_BUILD_TYPE=Release && sudo make install \
			&& sudo ln -sf /usr/local/bin/nvim /usr/bin/vi \
			&& sudo ln -sf /usr/local/bin/nvim /usr/bin/vim \
			&& sudo ln -sf /usr/bin/vim /etc/alternatives/editor
	ln -sf $(dir)/dots/nvim ~/.config/nvim

network:
	sudo zypper install iwd dhcp-client systemd-network

	# iwd tui
	cargo install impala

	# Set group for access to iwd, etc.
	# Requires logout/login for changes to take effect.
	sudo groupadd netdev
	sudo usermod -aG netdev francis

	sudo systemctl enable --now systemd-networkd
	sudo systemctl enable --now systemd-resolved
	sudo systemctl enable --now iwd
	sudo bash -c 'echo -e "[General]\nEnableNetworkConfiguration=true" > /etc/iwd/main.conf'

	# WARN: You should first check that the new network setup works.
	sudo zypper rm --clean-deps NetworkManager wpa_supplicant

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

	# Better way of browsing YouTube.
	git clone --depth 1 git@github.com:trizen/pipe-viewer.git /tmp/pipe-viewer
	sudo zypper in perl-Module-Build perl-Data-Dump perl-File-ShareDir perl-Gtk3 perl-JSON
	opi perl-LWP-UserAgent-Cached
	cd /tmp/pipe-viewer \
		&& perl Build.PL --gtk \
		&& sudo ./Build installdeps \
		&& sudo ./Build install

audio:
	sudo zypper in pavucontrol alsa-utils bluez bluetuith

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

fm:
	sudo zypper in poppler-tools ffmpegthumbnailer jq
	cargo install --git https://github.com/sxyazi/yazi yazi-fm
	ln -sf $(dir)/dots/yazi  ~/.config/yazi

wm:
	sudo zypper in swaybg swayidle

	# Onscreen keyboard.
	cargo install --git https://github.com/frnsys/kway.git

	# Lockscreen with virtual keyboard,
	# for touchscreen.
	sudo zypper in gtklock
	git clone git@github.com:frnsys/gtklock-virtkb-module.git /tmp/gtklock
	cd /tmp/gtklock && make && sudo make install

	# Monitor power state control
	sudo zypper in wlopm

	# kanshi for display management
	# Get output/monitor connector names
	# grep . /sys/class/drm/*/status
	sudo zypper in kanshi
	mkdir -p ~/.config/kanshi
	ln -s $(dir)/dots/kanshi ~/.config/kanshi/config
	sudo zypper in wlr-randr

	sudo zypper in xwayland river xdg-desktop-portal-wlr

	# Inhibit idle while audio is playing
	sudo zypper in libpulse-devel wayland-devel wayland-protocols-devel
	git clone --depth 1 git@github.com:ErikReider/SwayAudioIdleInhibit.git /tmp/inhibit-idle && \
		cd /tmp/inhibit-idle && \
		meson setup build && \
		ninja -C build && \
		sudo meson install -C build

	# River layout system
	sudo zypper in zig wayland-devel wayland-protocols-devel
	cargo install --git https://github.com/pkulak/filtile

	mkdir ~/.config/river
	ln -s $(dir)/dots/river ~/.config/river/init

bar:
	sudo zypper in gtk3-devel gtk-layer-shell-devel atk
	cargo +nightly install --git https://github.com/frnsys/sema.git

notifications:
	sudo zypper in mako libnotify-tools
	mkdir ~/.config/mako
	ln -sf $(dir)/dots/mako ~/.config/mako/config

terminal:
	sudo zypper in kitty kitty-terminfo
	mkdir ~/.config/kitty
	ln -sf $(dir)/dots/kitty ~/.config/kitty/kitty.conf

browser:
	sudo zypper in ca-certificates-steamtricks ca-certificates-cacert ca-certificates-mozilla ca-certificates-mozilla-prebuilt ca-certificates-letsencrypt ca-certificates

	sudo zypper in qutebrowser
	ln -sf $(dir)/dots/qute/config.yml ~/.config/qutebrowser/autoconfig.yml
	ln -sf $(dir)/dots/qute/userscripts ~/.local/share/qutebrowser/userscripts
	ln -sf $(dir)/dots/qute/greasemonkey ~/.local/share/qutebrowser/greasemonkey

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
	fnt install google-ibmplexsans
	fnt install google-nanummyeongjo
	fnt install fonts-fantasque-sans

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
	sudo zypper in tuned acpi libinput-tools
	sudo systemctl enable --now tuned

	# Firmware updates
	sudo zypper in fwupd
	fwupdmgr refresh && fwupdmgr update && fwupdmgr get-updates

	# Lower swappiness to avoid disk thrashing
	echo "vm.swappiness = 10" | sudo tee -a /etc/sysctl.conf
	sudo sysctl -p

	# For memory-limited systems,
	# enable zswap for better swap performance & lower disk I/O.
	# Add:
	# 	zswap.enabled=1 zswap.compressor=lzo zswap.max_pool_percent=20
	# To `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`;
	# then run `grub2-mkconfig -o /boot/grub2/grub.cfg`.

	# You could also enable zram, but in my benchmarks
	# having both simultaneously leads to performance drops
	# compared to having one or the other on its own;
	# and zswap performs better than zram on its own.
	# sudo zypper in systemd-zram-service
	# sudo systemctl enable --now zramswap

	# If the initial terminal font is too small,
	# add this to `/etc/vconsole.conf`:
	# FONT=ter-v32n.psfu

android:
	sudo zypper in android-tools
	git clone https://github.com/google/adb-sync /tmp/adb-sync
	sudo cp /tmp/adb-sync/adb-sync /usr/local/bin/

	flatpak install flathub org.localsend.localsend_app
	sudo firewall-cmd --permanent --zone=public --add-port=53317/udp
    sudo firewall-cmd --permanent --zone=public --add-port=53317/tcp

torrents:
	sudo zypper in deluge
	sudo opi -n nicotine-plus
	mkdir ~/.config/deluge
	ln -sf $(dir)/dots/misc/deluged.conf ~/.config/deluge/core.conf
	sudo firewall-cmd --permanent --zone=public --add-port=36767/udp
	sudo firewall-cmd --permanent --zone=public --add-port=36767/tcp

documents:
	# mupdf rather than poppler as it supports epubs.
	sudo zypper in zathura zathura-plugin-pdf-mupdf
	mkdir ~/.config/zathura
	ln -sf $(dir)/dots/zathura ~/.config/zathura/zathurarc
	sudo zypper in libreoffice-calc libreoffice-gtk3

screen:
	sudo usermod -aG video ${USER}
	sudo zypper in brightnessctl gammastep

other:
	ln -sf $(dir)/dots/bash ~/.bash_profile
	ln -sf $(dir)/bin ~/.bin

	# symlink notes and sites
	ln -sf $(dir)/dots/port ~/.config/port.yml
