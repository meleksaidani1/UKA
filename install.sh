#!/bin/bash

# Functions
is_mounted() {
    mountpoint -q "$1"
}

moun_t() {
    local job="$1"
    if is_mounted "$job"; then
        mount -o rw,remount "$job"
    else
        mount "$job"
        mount -o rw,remount "$job"
    fi
}

on_install() {
    echo "- Mounting /system, /data, and rootfs"

    sys_mount="/data/data/com.termux/files/usr"
    # Assuming sys_mount should be the Termux root directory

    if [ ! -d "$sys_mount" ]; then
        echo "Aborting! Failed to find system mountpoint!"
        exit 1
    fi

    echo "- Creating necessary directories"
    mkdir -p "$MODPATH/system" || { echo "Failed to create system directory"; exit 1; }
    mkdir -p "/data/local" || { echo "Failed to create local directory"; exit 1; }

    echo "- Checking and extracting files"
    if [ ! -f "$ZIPFILE" ]; then
        echo "The ZIPFILE '$ZIPFILE' does not exist."
        exit 1
    fi

    tar xJf "$ZIPFILE" -C "$MODPATH/system" bin.tar.xz || { echo "Failed to extract bin.tar.xz"; exit 1; }
    tar xJf "$ZIPFILE" -C "$MODPATH" uninstall.sh || { echo "Failed to extract uninstall.sh"; exit 1; }
    tar xJf "$ZIPFILE" -C "/data" binary.tar.xz || { echo "Failed to extract binary.tar.xz"; exit 1; }
    tar xJf "$ZIPFILE" -C "/data/local" python31.tar.xz || { echo "Failed to extract python31.tar.xz"; exit 1; }
    tar xJf "$ZIPFILE" -C "/data/local" aik.tar.xz || { echo "Failed to extract aik.tar.xz"; exit 1; }

    echo "- Creating working folders"
    folder_list="UnpackerContexts UnpackerPayload UnpackerPreloader UnpackerQfil UnpackerSuper UnpackerSystem UnpackerUpdateApp"
    for folder in $folder_list; do
        mkdir -p "/data/local/$folder" || { echo "Failed to create /data/local/$folder"; exit 1; }
    done

    echo "- Creating working files"
    /data/local/binary/make_ext4fs -l 268435456 /data/local/AIK-mobile/bin/ramdisk.img >/dev/null || { echo "Failed to create ramdisk.img"; exit 1; }

    echo "- Done!"
}

set_permissions() {
    # Set permissions if needed
    chmod -R 755 "$MODPATH/system/bin"
}

# Execute installation process
on_install
set_permissions
