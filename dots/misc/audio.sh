#!/bin/bash

pw-mon -o -N | while read -r line; do
    if [[ $line == *"running"* ]]; then
        sudo hda-verb /dev/snd/hwC0D0 0x1d SET_PIN_WIDGET_CONTROL 0x0
    fi
done
