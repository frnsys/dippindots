# DippinDots

These are my personal dotfiles for Linux (OpenSUSE Tumbleweed on a Legion Go).
Please feel free to use/modify them as you like!

## Usage

For a fresh Tumbleweed install I select the "server" preset.

    sudo zypper install git-core make
    git clone https://github.com/frnsys/dippindots.git ~/.dots
    make

Some things are best setup after everything else is installed and the system has been rebooted. Search for `POST-INSTALL` in `Makefile` for instructions.

Other system settings (e.g. hiding the boot menu) can be accessed via `sudo -E yast2`.

Because I use a touchscreen, I want to be able to login without a physical keyboard. To do that I setup autologin:

```bash
sudo VISUAL=/usr/local/bin/nvim systemctl edit getty@tty1

# Add:
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin francis --noclear %I $TERM
```

Then `dots/fish` is setup to launch the WM, which then runs `dots/init` which immediately locks the device. The lockscreen I use has a virtual keyboard.

## Screenshots

![11/2016](shots/11_2016.png)

![09/2016](shots/09_2016.png)

![12/2015](shots/12_2015.png)
