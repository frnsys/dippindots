# Android phone setup
## Ad Blocking

Set the private DNS to `dns.adguard-dns.com`.

Check that ads are blocked at <https://d3ward.github.io/toolz/adblock>; make sure any browser ad-blockers are disabled to test the DNS server.
## Termux

Install Termux and Termux-API from their GitHub releases.

I setup a basic neovim environment for text editing; more complicated tasks can be done from a Linux VM, described in the next section.

```bash
pkg update
pkg upgrade
pkg install tur-repo
pkg install termux-api
pkg install termux-exec

# Copy the contents of `termux.properties` to `~/.termux/termux.properties`.

# Setup file access
termux-setup-storage

# To change the termux font:
# Note: Requires restarting termux to take effect.
cp /usr/share/fonts/truetype/static/CascadiaCodePL-Light.ttf /data/data/com.termux/files/home/.termux/font.ttf

# Set up your git SSH keys as well.
pkg install git

# Install enough for a good neovim env.
pkg install clang make cmake
pkg install fzf ripgrep fd zoxide silversearcher-ag bat
pkg install neovim
pkg install fish
pkg install yazi
```

It's also worth running this command to disable the system "copied to clipboard" notification, which otherwise appears every time you e.g. copy something in `nvim`.

```bash
# Try "ignore" instead of "deny" if it doesn't work.
adb shell appops set com.android.systemui READ_CLIPBOARD deny
```


### Linux VM

Termux + Termux X11 + `proot-distro` + OpenSUSE Tumbleweed. This has more overhead than running programs directly in Termux (above) but is ofc more capable given that you're hosting an entire Linux environment.

Install _Termux X11_ from its GitHub releases. Note that it must be installed from the same provider as Termux (e.g. GitHub or f-droid) to avoid compatibility problems.

```bash
# Setup for X11.
pkg install x11-repo termux-x11-nightly

# Setup for GPU/hardware acceleration.
# Basically Kitty uses OpenGL, whereas Android/Termux uses Vulkan. Zink provides a compatibility layer between the two.
#
# Note this was tested for Qualcomm Snapdragon and may need to be different on e.g. Google Tensor/Mali GPUs.
pkg install vulkan-tools mesa-zink

# At time of writing `mesa-vulkan-icd-wrapper` is not yet included as a Termux package.
# See <https://reddit.com/r/termux/comments/1gmnf7s/qualcomm_drivers_its_here/>
# You can download the package here:
# https://github.com/xMeM/termux-packages/actions/runs/11740090264/artifacts/2162371633
# and install manually:
pkg in ./mesa-vulkan-icd-wrapper-dbg_24.2.5-7_aarch64.deb

# If `kitty` has slow/choppy performance
# it probably means something is wrong with the
# hardware acceleration.
#
# Other things to try before running `kitty`:
# MESA_LOADER_DRIVER_OVERRIDE=zink
# MESA_VK_WSI_PRESENT_MODE=mailbox
# vblank_mode=0 # and/or try `vsync no` in `kitty.conf`

# Install OpenSUSE Tumbleweed.
pkg install proot-distro
proot-distro install opensuse

# Login to the VM
proot-distro login opensuse --shared-tmp

# After fish is installed you can instead run:
proot-distro login opensuse --shared-tmp -- /usr/bin/fish

# Prepare to install packages
zypper refresh
zypper dup

# Initial core requirements
zypper in openssh neovim git fish

# Note that I had a problem where git ssh would cause this error:
# > Bad owner or permissions on /etc/crypto-policies/back-ends/openssh.config
#
# The only way around it was to create an empty ssh config file
# and configure git to use that for its ssh command:
touch ~/.ssh/config
git config --global core.sshCommand "ssh -F ~/.ssh/config"

# WM/graphics setup:
# No Wayland support yet so can't exactly replicate the laptop setup,
# so instead go for bspwm.
# The idea is to just SSH into the main machine/dev environment (mothership),
# so we only really need `kitty` as the "frontend", e.g. it's tab management.
# We still need a WM to manage the `kitty` window (e.g. sizing); and because
# `kitty` is GPU-accelerated we also installed `Mesa`.
zypper in Mesa glibc libcanberra0 libXcursor1 bspwm
zypper in kitty kitty-terminfo fontconfig saja-cascadia-code-fonts

# Misc other dependencies for neovim plugins, etc
zypper in bat gcc gcc-c++ make cmake automake autoconf clang lld
zypper in zoxide fzf yazi fd ripgrep the_silver_searcher
```

For the `bspwm` config:

```bash
# ~/.config/bspwm/bspwmrc
#!/usr/bin/bash
kitty --start-as=fullscreen &
```

and don't forget to:

```bash
chmod +x ~/.config/bspwm/bspwmrc
```

Then to get everything running:

```bash
# Start X11 from within termux; not the proot distro.
termux-x11 :0 >/dev/null &

# Then login to the VM and run:
env DISPLAY :=0 kitty
```

Then you can launch the Termux X11 app.

To connect to the mothership you also need the Wireguard Android app and to setup a cloud relay.
