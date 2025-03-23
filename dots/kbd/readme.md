# Setup

```bash
git clone --depth 1 --recurse-submodules https://github.com/qmk/qmk_firmware.git
cd qmk_firmware
pip install -r requirements.txt

sudo zypper in cross-avr-gcc14 cross-arm-none-gcc14 avrdude avr-libc dfu-programmer dfu-util

cargo install --git https://github.com/frnsys/kbl
```

Then you need to compile and flash the layout to the keyboard. This is done by plugging one half in at a time, setting the controller to be read as a USB disk, and then copying the compiled `.uf2` file to it. The `flash.sh` script is provided to simplify this a bit, see below for instructions.

Note that after the first flash you don't need to always flash both halves if you're only updating e.g. the layout. If the firmware is updated then you do need to apply it to both halves.

# `smallcat`

I maintain my layout in `.kbl`, which is compiled to `keymap.c` using `kbl` (see the setup instructions).

```bash
~/.dots/dots/kbd/flash.sh smallcat
```

Then hold the Boot button on the RP2040 while plugging it in for it to show up as a USB disk.

# Aurora Sweep

```bash
~/.dots/dots/kbd/flash.sh aurora-sweep
```

Double-press the reset button for the controller to be read as a disk.
