#!/bin/bash

KIND=$1
shift 1

DISK="/dev/sda"
MOUNT_POINT="/mnt/usb"

set -e

# Get sudo access
sudo echo

# Last line is the firmware file.
FIRMWARE=$(cd $KIND && ./build.sh "$@" | tee /dev/tty | tail -n1)
echo "Firmware: $FIRMWARE"

echo "Waiting for disk $DISK to become available..."
while [ ! -e "$DISK" ]; do
    sleep 1
done

echo "Disk $DISK found. Mounting to $MOUNT_POINT..."
sudo mount "$DISK" "$MOUNT_POINT"

if mountpoint -q "$MOUNT_POINT"; then
    echo "Disk mounted successfully."

    echo "Copying file $FIRMWARE to $MOUNT_POINT/..."
    sudo cp "$FIRMWARE" "$MOUNT_POINT/"

    echo "Unmounting disk $DISK..."
    sudo umount "$MOUNT_POINT"
    echo "Finished."
else
    echo "Failed to mount disk $DISK."
fi

exit 0
