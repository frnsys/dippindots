#!/bin/bash

set -e

export ZMK_COMBO_TIMEOUT=35

NAME=$1 # e.g. `urchin`
HALF=$2 # "left" or "right"

declare -A KEYBOARDS=(
    ["urchin"]="nice_nano"
    ["corne"]="corne_choc_pro_${HALF}"
)

declare -A SHIELDS=(
    ["urchin"]="urchin_${HALF}"
    ["corne"]="nice_view"
)

KEYBOARD="${KEYBOARDS[$NAME]}"
SHIELD="${SHIELDS[$NAME]}"
ZMK_DIR=/opt/zmk/app
BUILD_DIR=/tmp/$NAME
MODULE=modules/${NAME}-zmk-module

rm -rf "$BUILD_DIR"
mkdir "$BUILD_DIR"

cp -r "$MODULE" "$BUILD_DIR/module"
cp config.conf "$BUILD_DIR/${KEYBOARD}.conf"
kbl zmk ${NAME}.kbl > "$BUILD_DIR/${KEYBOARD}.keymap"

cd $ZMK_DIR
export ZEPHYR_TOOLCHAIN_VARIANT="zephyr"
west build -p -d $BUILD_DIR/build/$HALF -b $KEYBOARD -- -DSHIELD=$SHIELD -DZMK_CONFIG="$BUILD_DIR" -DZMK_EXTRA_MODULES="$BUILD_DIR/module" -DBOARD_ROOT="$BUILD_DIR/module"
cp ${BUILD_DIR}/build/${HALF}/zephyr/zmk.uf2 $BUILD_DIR/${HALF}.uf2
echo "${BUILD_DIR}/${HALF}.uf2"
