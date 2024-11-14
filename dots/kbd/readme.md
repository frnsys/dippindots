```bash
git clone --depth 1 --recurse-submodules https://github.com/qmk/qmk_firmware.git
cd qmk_firmware
pip install -r requirements.txt

sudo zypper in cross-avr-gcc14 cross-arm-none-gcc14 avrdude avr-libc dfu-programmer dfu-util
```

Then symlink the layouts to the correct directory. Assuming `qmk_firmware` is installed to `/opt/qmk_firmware`, and the layout name is `francis`:

```bash
ln -s ~/.dots/dots/kdb/bkb-dilemma /opt/qmk_firmware/keyboards/bastardkb/dilemma/3x5_3/keymaps/francis
```

Then you need to compile and flash the layout to the keyboard.

```bash
qmk compile -c -kb bastardkb/dilemma/3x5_3 -km francis

# This results in a file like `bastardkb_dilemma_3x5_3_francis.uf2`,
# which requires you plug the left half of the keyboard in by itself,
# double-press the little reset button (to the left of the cable plug),
# then use `lsblk` to check that the keyboard is available to mount as a disk (should be 128M).
# Then you can do:
sudo mount /dev/sda1 /mnt/usb
cp bastardkb_dilemma_3x5_3_francis.uf2 /mnt/usb/
sudo umount /mnt/usb

# and repeat for the other half.
```
