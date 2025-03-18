# Setup

```bash
git clone --depth 1 --recurse-submodules https://github.com/qmk/qmk_firmware.git
cd qmk_firmware
pip install -r requirements.txt

sudo zypper in cross-avr-gcc14 cross-arm-none-gcc14 avrdude avr-libc dfu-programmer dfu-util

cargo install --git https://github.com/frnsys/kbl
```

Then symlink the layouts to the correct directory. Assuming `qmk_firmware` is installed to `/opt/qmk_firmware`, and the layout name is `francis`:

```bash
mkdir /opt/qmk_firmware/keyboards/smallcat/keymaps
ln -s ~/.dots/dots/kdb/smallcat /opt/qmk_firmware/keyboards/smallcat/keymaps/francis

ln -s ~/.dots/dots/kdb/aurora-sweep /opt/qmk_firmware/keyboards/splitkb/aurora/sweep/keymaps/francis
ln -s ~/.dots/dots/kdb/bkb-dilemma /opt/qmk_firmware/keyboards/bastardkb/dilemma/3x5_3/keymaps/francis
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

# BastardKB Dilemma

```bash
cd /opt/qmk_firmware
qmk compile -c -kb bastardkb/dilemma/3x5_3 -km francis
sudo mount /dev/sda1 /mnt/usb
sudo cp bastardkb_dilemma_3x5_3_francis.uf2 /mnt/usb/
sudo umount /mnt/usb
```

Double-press the reset button for the controller to be read as a disk.
