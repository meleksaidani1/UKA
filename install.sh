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

    mkdir -p "$MODPATH/system" || exit 1

    ZIPFILE="/path/to/your/module.zip"  # Replace this with the actual path to your ZIP file

    if [ ! -f "$ZIPFILE" ]; then
        echo "The ZIPFILE '$ZIPFILE' does not exist."
        exit 1
    fi

    echo "- Checking and extracting files"

    tar xJf "$ZIPFILE" -C "$MODPATH/system" bin.tar.xz >/dev/null || exit 1
    tar xJf "$ZIPFILE" -C "$MODPATH" uninstall.sh >/dev/null || exit 1
    tar xJf "$ZIPFILE" -C "/data" binary.tar.xz >/dev/null || exit 
