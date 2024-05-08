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
base: prereqs git langs rust shell tools editor other
de: wm bar notifications menu theme terminal scrots fm
media: audio images video music
laptop: thinkpad tweaks screen
apps: apps browser vpn torrents android documents

# ---

prereqs:
	@echo "Installing prereqs..."
	sudo zypper in gcc make cmake automake autoconf clang lld wget unzip openssh-server bzip2 curl ninja meson opi unar

	# necessary for installing from git with cargo
	eval `ssh-agent -s`
	ssh-add ~/.ssh/id_rsa

rust:
	@echo "Installing rust..."
	curl -sf -L https://static.rust-lang.org/rustup.sh | sh
	export PATH=$PATH:~/.cargo/bin
	rustup toolchain add nightly
	rustup component add rust-src --toolchain nightly
	rustup component add clippy --toolchain nightly
	rustup component add rust-analyzer --toolchain nightly
	rustup override set nightly
	rustup default nightly
	source ~/.cargo/env
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

	# ssh access
	ssh -vT git@github.com

tools:
	@echo "Installing fzf..."
	@echo "Say NO to auto-completion for performance"
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install

	sudo zypper in jq htop tree the_silver_searcher gnupg ncdu powertop dfc ffmpeg

	cargo install fd-find ripgrep

apps:
	sudo zypper in wl-clipboard sqlitebrowser rclone yt-dlp
	cargo install pastel

	# Colorpicker
	opi hyprpicker

	# for easily updating system time to current time zone
	# to preview, run `tzupdate -p`
	# to make the change, run `sudo tzupdate`
	pip3 install -U tzupdate

	cargo install --git ssh://git@github.com/frnsys/agenda.git

	opi signal-desktop
	cargo install --git ssh://git@github.com/frnsys/kpass.git

	sudo zypper in flatpak
	flatpak install flathub com.unity.UnityHub

editor:
	@echo "Installing neovim..."
	sudo zypper in bat
	wget https://github.com/neovim/neovim/archive/refs/tags/nightly.tar.gz -O /tmp/neovim.tar.gz
	cd /tmp; tar -xzvf neovim.tar.gz; \
		cd neovim-*; make CMAKE_BUILD_TYPE=Release && sudo make install \
			&& sudo ln -sf /usr/local/bin/nvim /usr/bin/vi \
			&& sudo ln -sf /usr/local/bin/nvim /usr/bin/vim \
			&& sudo ln -sf /usr/bin/vim /etc/alternatives/editor
	ln -sf $(dir)/dots/nvim ~/.config/nvim

music:
	sudo zypper in ncmpcpp mpd mpclient
	ln -sf $(dir)/dots/ncmpcpp ~/.ncmpcpp
	mkdir ~/.mpd/
	touch ~/.mpd/{mpd.db,mpd.log,mpd.pid,mpd.state}
	ln -sf $(dir)/dots/mpd ~/.mpd/mpd.conf

	# disable as the system instance conflicts with the user instance
	sudo systemctl disable --now mpd

video:
	opi codecs

	sudo zypper in mpv
	ln -sf $(dir)/dots/mpv ~/.config/mpv

	# mpvc for controlling mpv
	git clone --depth 1 https://github.com/lwilletts/mpvc.git /tmp/mpvc
	cd /tmp/mpvc && sudo make install

	git clone git@github.com:trizen/pipe-viewer.git /tmp/pipe-viewer
	sudo zypper in perl-Module-Build perl-Data-Dump perl-File-ShareDir perl-Gtk3 perl-JSON
	opi perl-LWP-UserAgent-Cached
  	cd /tmp/pipe-viewer \
		&& perl Build.PL --gtk \
    	&& sudo ./Build installdeps \
    	&& sudo ./Build install

audio:
	sudo zypper in python312-pulsemixer pavucontrol

	# bluetooth
	# see ~/notes/linux/bluetooth.md
	sudo zypper in bluez bluetuith

	# For for X1 Nano G1
	# where there is crackling/static
	# when headphones are plugged in in.
	# sudo hda-verb /dev/snd/hwC0D0 0x1d SET_PIN_WIDGET_CONTROL 0x0
	sudo zypper in hda-verb
	sudo cp $(dir)/dots/misc/audio_fix.service /etc/systemd/system/hdaverb.service
	sudo systemctl enable hdaverb

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
	cargo install --git ssh://git@github.com/frnsys/vu.git
	sudo zypper in ImageMagick ImageMagick-extra

fm:
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
	mkdir -p ~/.config/kanshi && touch ~/.config/kanshi/config

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
	git clone --depth 1 'https://git.sr.ht/~novakane/rivercarro' /tmp/rivercarro && \
		cd /tmp/rivercarro && \
		git submodule update --init && \
		sudo zig build -Doptimize=ReleaseSafe --prefix /usr/local install

	mkdir ~/.config/river
	ln -s $(dir)/dots/river ~/.config/river/init

bar:
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
	sudo zypper in google-noto-fonts

	# firefox config
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
	sed -i 's/Path=.*/Path=profile.default/' ~/.mozilla/firefox/profiles.ini # NOTE this file might not exist until you launch firefox
	# extensions
	# - https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/

	# Google Chrome
	opi chrome

vpn:
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
	sudo zypper in -y google-inconsolata-fonts google-noto-coloremoji-fonts terminus-bitmap-fonts
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

	sudo zypper rm plymouth-*

thinkpad:
	# tlp for better battery life
	# also provides utility commands `bluetooth` and `wifi`
	# which are used elsewhere in scripts
	sudo zypper in tlp tlpui tp_smapi-kmp-default acpi
	sudo systemctl enable --now tlp.service

tweaks:
	# Firmware updates
	sudo zypper in fwupd
	fwupdmgr refresh && fwupdmgr update && fwupdmgr get-updates

	# Setup passwordless sudo/root for certain commands
	# TODO still necessary?
	# sudo cp $(dir)/dots/misc/00_anarres /etc/sudoers.d/

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
	flatpak install flathub org.onlyoffice.desktopeditors

screen:
	sudo usermod -aG video ${USER}
	sudo zypper in brightnessctl gammastep

other:
	ln -sf $(dir)/dots/bash ~/.bash_profile
	ln -sf $(dir)/bin ~/.bin

	# symlink notes and sites
	ln -sf $(dir)/dots/port ~/.port
