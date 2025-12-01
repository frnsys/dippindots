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

# Copy the contents of `termux.properties` to `~/.termux/termux.properties`.
# Copy the contents of `colors.properties` to `~/.termux/colors.properties`.

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
