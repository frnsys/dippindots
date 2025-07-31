#!/bin/bash

set -e

KEYBOARD=$1
KEYMAP="francis"
QMK_DIR="/opt/qmk"
KBL_LAYOUT=${KEYBOARD}.kbl

KM_DIR="$QMK_DIR/keyboards/${KEYBOARD}/keymaps/${KEYMAP}"
mkdir -p "$KM_DIR"

kbl qmk $KBL_LAYOUT > "$KM_DIR/keymap.c"
cp common/config.h "$KM_DIR/config.h"
cp common/rules.mk "$KM_DIR/rules.mk"

cd $QMK_DIR
FIRMWARE=$(qmk compile -c -kb ${KEYBOARD} -km ${KEYMAP} | tail -1 | cut -d' ' -f2)
cd -

echo "$QMK_DIR/$FIRMWARE"
