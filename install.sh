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

# Set your module's path
MODPATH="/data/data/com.termux/files/home/UKA_5.27_magisk_sign"

on_install() {
    echo "- Mounting /system, /data, and rootfs"

    sys_mount="/data/data/com.termux/files/usr"
    # Assuming sys_mount should be the Termux root directory

    if [ ! -d "$sys_mount" ]; then
        echo "Aborting! Failed to find system mountpoint!"
        exit 1
    fi

    echo "- Moving files to /system, /data"

    mkdir -p "$MODPATH/system" || exit 1

    # Modify paths accordingly based on your ZIPFILE structure
    tar xJf "$ZIPFILE" -C "$MODPATH/system" bin.tar.xz >/dev/null
    tar xJf "$ZIPFILE" -C "$MODPATH" uninstall.sh >/dev/null
    tar xJf "$ZIPFILE" -C "/data" binary.tar.xz >/dev/null
    tar xJf "$ZIPFILE" -C "/data/local" python31.tar.xz >/dev/null
    tar xJf "$ZIPFILE" -C "/data/local" aik.tar.xz >/dev/null

    # Create working folders
    echo "- Creating working folders"

    folder_list="UnpackerContexts UnpackerPayload UnpackerPreloader UnpackerQfil UnpackerSuper UnpackerSystem UnpackerUpdateApp"
    for folder in $folder_list; do
        mkdir -m 755 -p "/data/local/$folder" || exit 1
    done

    echo "- Creating working files"
    /data/local/binary/make_ext4fs -l 268435456 /data/local/AIK-mobile/bin/ramdisk.img >/dev/null || exit 1

    echo "- Done!"
}

set_permissions() {
    # Set permissions if needed
    chmod -R 755 "$MODPATH/system/bin"
}

# Execute installation process
on_install
set_permissions
