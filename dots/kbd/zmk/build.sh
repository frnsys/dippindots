#!/bin/bash

set -e

KEYBOARD=$1 # e.g. `urchin`
HALF=$2 # "left" or "right"
BOARD=nice_nano
ZMK_DIR=/opt/zmk/app
BUILD_DIR=/tmp/$KEYBOARD
MODULE=modules/${KEYBOARD}-zmk-module

build_half() {
    west build -p -d $BUILD_DIR/build/$1 -b $BOARD -- -DSHIELD=${KEYBOARD}_$1 -DZMK_CONFIG="$BUILD_DIR" -DZMK_EXTRA_MODULES="$BUILD_DIR/module"
    cp $BUILD_DIR/build/$1/zephyr/zmk.uf2 $BUILD_DIR/$1.uf2
    echo "$BUILD_DIR/$1.uf2"
}

rm -rf "$BUILD_DIR"
mkdir "$BUILD_DIR"

cp -r "$MODULE" "$BUILD_DIR/module"
cp config.conf "$BUILD_DIR/${KEYBOARD}.conf"
kbl zmk ${KEYBOARD}.kbl > "$BUILD_DIR/${KEYBOARD}.keymap"

cd $ZMK_DIR
build_half $HALF
