# Setup

```bash
sudo zypper in cross-avr-gcc14 cross-arm-none-gcc14 avrdude avr-libc dfu-programmer dfu-util
cargo install --git https://github.com/frnsys/kbl
```

## QMK

```bash
git clone --depth 1 --recurse-submodules https://github.com/qmk/qmk_firmware.git /opt/qmk
cd /opt/qmk
pip install -r requirements.txt
```

## ZMK

```bash
git clone --depth 1 https://github.com/zmkfirmware/zmk.git /opt/zmk

# See https://zmk.dev/docs/development/local-toolchain/setup/native
cd /opt/zmk
pip3 install --user -U west
west init -l app/
west update
west zephyr-export
pip3 install --user -r zephyr/scripts/requirements-base.txt
```

# `smallcat`

I maintain my layout in `.kbl`, which is compiled to `keymap.c` using `kbl` (see the setup instructions).

```bash
~/.dots/dots/kbd/flash.sh qmk splitkb/aurora/sweep
```

Then hold the Boot button on the RP2040 while plugging it in for it to show up as a USB disk.

# `urchin`

Build and flash each side independently:

```bash
~/.dots/dots/kbd/flash.sh zmk urchin left
~/.dots/dots/kbd/flash.sh zmk urchin right
```
