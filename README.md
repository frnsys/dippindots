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

Then `dots/fish` is setup to launch `river`, and `dots/river` is setup to immediately lock the device. The lockscreen I use has a virtual keyboard.


## Device-specific details
### Tuxedo Pulse 14 Gen4

To preserve battery life, [it's suggested](https://www.tuxedocomputers.com/en/Infos/Help-Support/Frequently-asked-questions/What-is-Flexicharger-) to go into the BIOS (via `F2` or `Del`) and enable "FlexiCharger" (if available) and otherwise set the "start charge" to 40% and "stop charge" to 80%. When you need full battery power you can turn off FlexiCharger beforehand.

[To avoid screen flickers](https://www.tuxedocomputers.com/en/FAQ-TUXEDO-Pulse-14-Gen4.tuxedo), add `amdgpu.dcdebugmask=0x10` to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`, and then run `sudo update-bootloader`.


## Screenshots

![11/2016](shots/11_2016.png)

![09/2016](shots/09_2016.png)

![12/2015](shots/12_2015.png)
