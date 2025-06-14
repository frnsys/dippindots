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

KM_DIR="$QMK_DIR/keyboards/${KEYBOARD}/keymaps/${KEYMAP}"
mkdir -p "$KM_DIR"

kbl $KBL_LAYOUT > "$KM_DIR/keymap.c"
cp common/config.h "$KM_DIR/config.h"
cp common/rules.mk "$KM_DIR/rules.mk"

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
