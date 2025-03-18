#!/bin/bash

KEYBOARD=$1
KEYMAP="francis"

DISK="/dev/sda1"
MOUNT_POINT="/mnt/usb"
QMK_DIR="/opt/qmk_firmware/"
KBL_LAYOUT=~/.dots/dots/kbd/${KEYBOARD}.kbl

set -e

# Get sudo access
sudo echo

if [[ "$KEYBOARD" == "aurora-sweep" ]]; then
  KEYBOARD="splitkb/aurora/sweep"
fi

kbl $KBL_LAYOUT > "$QMK_DIR/keyboards/${KEYBOARD}/keymaps/${KEYMAP}/keymap.c"
cd $QMK_DIR
FIRMWARE=$(qmk compile -c -kb ${KEYBOARD} -km ${KEYMAP} | tail -1 | cut -d' ' -f2)
cd -

echo "Waiting for disk $DISK to become available..."
while [ ! -e "$DISK" ]; do
    sleep 1
done

echo "Disk $DISK found. Mounting to $MOUNT_POINT..."
sudo mount "$DISK" "$MOUNT_POINT"

if mountpoint -q "$MOUNT_POINT"; then
    echo "Disk mounted successfully."

    echo "Copying file $QMK_DIR/$FIRMWARE to $MOUNT_POINT/..."
    sudo cp "$QMK_DIR/$FIRMWARE" "$MOUNT_POINT/"

    echo "Unmounting disk $DISK..."
    sudo umount "$MOUNT_POINT"
    echo "Finished."
else
    echo "Failed to mount disk $DISK."
fi

exit 0
