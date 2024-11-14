# Android phone setup
## Keyboard

Using _Unexpected Keyboard_ with a custom layout, defined in `kb-layout.xml`. It's a version of QWERTY modified so that there are fewer keys per row (and thus wider keys) and to be more symbol-friendly than the default Android keyboard.

## Linux VM

Termux + Termux X11 + `proot-distro` + OpenSUSE Tumbleweed

Install both _Termux_ and _Termux X11_ from GitHub releases. Note that they both must be installed from the same provider (e.g. GitHub or f-droid) to avoid compatibility problems.

Then setup Termux:

```bash
pkg update
pkg upgrade
pkg install tur-repo

# Copy the contents of `termux.properties` to `~/.termux/termux.properties`.

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

# No Wayland support yet so can't exactly replicate the laptop setup,
# so instead go for bspwm.
# The idea is to just SSH into the main machine/dev environment (mothership),
# so we only really need `kitty` as the "frontend", e.g. it's tab management.
# We still need a WM to manage the `kitty` window (e.g. sizing); and because
# `kitty` is GPU-accelerated we also installed `Mesa`.
# `wireguard` is needed for connecting to the mothership.
zypper refresh
zypper dup
zypper in Mesa openssh wireguard-tools fontconfig fish kitty kitty-terminfo neovim bspwm glibc libcanberra libxcursor adduser sudo caja-cascadia-code-fonts
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