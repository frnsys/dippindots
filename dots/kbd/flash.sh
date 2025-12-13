#!/bin/bash

KIND=$1
shift 1

DISK_OPTS=(/dev/sda /dev/sdb)
MOUNT_POINT="/mnt/usb"

set -e

# Get sudo access
sudo echo

# Record which disks already exist
declare -A present
for d in "${DISK_OPTS[@]}"; do
    if [ -e "$d" ]; then
        present["$d"]=1
    fi
done

# Last line is the firmware file.
FIRMWARE=$(cd $KIND && ./build.sh "$@" | tee /dev/tty | tail -n1)
echo "Firmware: $FIRMWARE"

echo "Waiting for disk to become available..."
while :; do
    for d in "${DISK_OPTS[@]}"; do
        if [ ! "${present[$d]}" ] && [ -e "$d" ]; then
            DISK="$d"
            break 2
        fi
    done
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
