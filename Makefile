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
laptop: thinkpad tweaks screen
apps: utils browser vpn torrents android documents dev

# ---

prereqs:
	@echo "Installing prereqs..."
	sudo zypper in gcc gcc-c++ make cmake automake autoconf clang lld wget zip unzip openssh-server bzip2 curl ninja meson opi unar

	sudo zypper in avahi
	sudo systemctl enable --now avahi-daemon

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
	mise use --global python@3.11

git:
	@echo "Installing git..."
	sudo zypper in git git-lfs gitui
	git lfs install

	mkdir -p ~/.config/git
	ln -sf $(dir)/dots/git/gitignore ~/.config/git/ignore
	ln -sf $(dir)/dots/git/gitconfig ~/.gitconfig

tools:
	# TODO install via zypper?
	@echo "Installing fzf..."
	@echo "Say NO to auto-completion for performance"
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install

	sudo zypper in jq htop tree the_silver_searcher gnupg ncdu powertop dfc ffmpeg
	cargo install fd-find ripgrep zoxide

utils:
	sudo zypper in yast2-control-center-qt
	sudo zypper in sqlitebrowser rclone yt-dlp
	cargo install pastel

	# Colorpicker
	sudo zypper in Mesa-libGLESv3-devel xcursor-themes hyprutils-devel
	git clone --depth 1  git@github.com:hyprwm/hyprpicker.git /tmp/hyprpicker
	cd /tmp/hyprpicker \
		&& cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build \
		&& cmake --build ./build --config Release --target hyprpicker \
		&& sudo cmake --install ./build

	opi signal-desktop

	eval `ssh-agent -s` && ssh-add
	cargo install --git ssh://git@github.com/frnsys/kpass.git
	cargo install --git ssh://git@github.com/frnsys/agenda.git

	sudo zypper in -y flatpak

	# for easily updating system time to current time zone
	# to preview, run `tzupdate -p`
	# to make the change, run `sudo tzupdate`
	pip3 install -U tzupdate

dev:
	sudo zypper in -y podman # podman for docker
	flatpak install flathub io.podman_desktop.PodmanDesktop
	cargo install just
	cargo install cross
	cargo install bacon
	cargo install wasm-pack wasm-bindgen-cli
	cargo install cargo-expand cargo-machete
	cargo install mdbook mdbook-toc
	cargo install tailspin # tspin; log viewer

editor:
	@echo "Installing neovim..."
	sudo zypper in bat
	wget https://github.com/neovim/neovim/archive/refs/tags/v0.10.2.tar.gz -O /tmp/neovim.tar.gz
	cd /tmp; tar -xzvf neovim.tar.gz; \
		cd neovim-*; make CMAKE_BUILD_TYPE=Release && sudo make install \
			&& sudo ln -sf /usr/local/bin/nvim /usr/bin/vi \
			&& sudo ln -sf /usr/local/bin/nvim /usr/bin/vim \
			&& sudo ln -sf /usr/bin/vim /etc/alternatives/editor
	ln -sf $(dir)/dots/nvim ~/.config/nvim

network:
	sudo zypper rm --clean-deps NetworkManager wpa_supplicant
	sudo zypper install iwd dhcp-client systemd-network
	sudo bash -c 'echo -e "[General]\nEnableNetworkConfiguration=true" > /etc/iwd/main.conf'
	sudo systemctl enable --now systemd-resolved
	sudo systemctl enable --now iwd

	# Set group for access to iwd, etc.
	# Requires logout/login for changes to take effect.
	sudo groupadd netdev
	sudo usermod -aG netdev francis

	# iwd tui
	cargo install impala

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

	git clone --depth 1 git@github.com:trizen/pipe-viewer.git /tmp/pipe-viewer
	sudo zypper in perl-Module-Build perl-Data-Dump perl-File-ShareDir perl-Gtk3 perl-JSON
	opi perl-LWP-UserAgent-Cached
	cd /tmp/pipe-viewer \
		&& perl Build.PL --gtk \
		&& sudo ./Build installdeps \
		&& sudo ./Build install

audio:
	sudo zypper in python312-pulsemixer pavucontrol alsa-utils

	# bluetooth
	sudo zypper in bluez bluetuith

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
	eval `ssh-agent -s` && ssh-add
	cargo install --git ssh://git@github.com/frnsys/vu.git
	sudo zypper in ImageMagick ImageMagick-extra
	sudo zypper in libwebpdecoder3 libwebp-devel libwebp-tools

fm:
	sudo zypper in poppler-tools ffmpegthumbnailer jq
	cargo install --git https://github.com/sxyazi/yazi yazi-fm
	ln -sf $(dir)/dots/yazi  ~/.config/yazi

wm:
	# swaybg and swaylock for background and lock screen
	sudo zypper in swaybg swaylock swayidle

	# Monitor power state control
	sudo zypper in wlopm

	# kanshi for display management
	# Get output/monitor connector names
	# grep . /sys/class/drm/*/status
	sudo zypper in kanshi
	mkdir -p ~/.config/kanshi
	ln -s $(dir)/dots/kanshi ~/.config/kanshi/config

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
	eval `ssh-agent -s` && ssh-add
	sudo zypper in gtk3-devel gtk-layer-shell-devel atk
	cargo +nightly install --git ssh://git@github.com/frnsys/sema.git

notifications:
	sudo zypper in mako libnotify-tools
	mkdir ~/.config/mako
	ln -sf $(dir)/dots/mako ~/.config/mako/config

terminal:
	sudo zypper in kitty kitty-terminfo
	mkdir ~/.config/kitty
	ln -sf $(dir)/dots/kitty ~/.config/kitty/kitty.conf

browser:
	sudo zypper in MozillaFirefox

	# Fonts with better character support
	# You may need to enable these as the default fonts
	# in `about:preferences`.
	sudo zypper in google-noto-fonts google-noto-sans-cjk-fonts

	# POST-INSTALL:
	# -------------
	# Firefox config
	# In `about:config`, set:
	#   - `media.peerconnection.enabled` to false to prevent WebRTC IP leaks
	#   - `toolkit.legacyUserProfileCustomizations.stylesheets` to true
	#   - `browser.fullscreen.autohide` to false
	#   - `dom.input.fallbackUploadDir` to `~/downloads` to stop it from trying to upload from `~/Desktop`
	#   - `browser.download.lastDir` to `~/downloads`
	# Also disabled hardware acceleration, had issues with slow painting otherwise
	mkdir -p ~/.mozilla/firefox/profile.default/chrome
	ln -sf $(dir)/dots/firefox/userChrome.css ~/.mozilla/firefox/profile.default/chrome/userChrome.css
	ln -sf $(dir)/dots/firefox/userContent.css ~/.mozilla/firefox/profile.default/chrome/userContent.css

	# POST-INSTALL:
	# -------------
	# NOTE this file might not exist until you launch firefox:
	# sed -i 's/Path=.*/Path=profile.default/' ~/.mozilla/firefox/profiles.ini
	# install extensions:
	# 	- https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/

	# Google Chrome
	opi chrome

vpn:
	# POST-INSTALL:
	# -------------
	# mullvad account login
	opi mullvadvpn
	sudo systemctl enable --now mullvad-daemon.service

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
		terminus-bitmap-fonts \
		inter-fonts \
		fira-code-fonts \
		adobe-sourcesans3-fonts \
		adobe-sourcecodepro-fonts \
		symbols-only-nerd-fonts

	mkdir -p ~/.config/fontconfig
	ln -sf $(dir)/assets/fonts ~/.fonts
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

	mkfontdir ~/.fonts
	mkfontscale ~/.fonts
	fc-cache -fv

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

	# Firmware updates
	sudo zypper in fwupd
	fwupdmgr refresh && fwupdmgr update && fwupdmgr get-updates

	# TODO Lower swappiness to avoid disk thrashing
	# echo "vm.swappiness = 10" | sudo tee -a /etc/sysctl.conf

android:
	sudo zypper in android-tools
	git clone https://github.com/google/adb-sync /tmp/adb-sync
	sudo cp /tmp/adb-sync/adb-sync /usr/local/bin/

torrents:
	sudo zypper in deluge
	sudo opi -n nicotine-plus
	mkdir ~/.config/deluge
	ln -sf $(dir)/dots/misc/deluged.conf ~/.config/deluge/core.conf

documents:
	sudo zypper in zathura zathura-plugin-pdf-poppler
	mkdir ~/.config/zathura
	ln -sf $(dir)/dots/zathura ~/.config/zathura/zathurarc
	cargo install inlyne
	sudo zypper in libreoffice-calc libreoffice-gtk3

screen:
	sudo usermod -aG video ${USER}
	sudo zypper in brightnessctl gammastep

other:
	ln -sf $(dir)/dots/bash ~/.bash_profile
	ln -sf $(dir)/bin ~/.bin

	# symlink notes and sites
	ln -sf $(dir)/dots/port ~/.config/port.yml
