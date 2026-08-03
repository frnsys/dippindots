# Setup

```bash
sudo zypper in cross-avr-gcc14 cross-arm-none-gcc14 avrdude avr-libc dfu-programmer dfu-util protobuf21-devel
cargo install --git https://github.com/frnsys/kbl
```

## QMK

```bash
git clone --depth 1 --recurse-submodules https://github.com/qmk/qmk_firmware.git /opt/qmk
cd /opt/qmk
pip install -r requirements.txt

curl -fsSL https://install.qmk.fm | sh
```

## ZMK

```bash
git clone --depth 1 https://github.com/zmkfirmware/zmk.git /opt/zmk

# See https://zmk.dev/docs/development/local-toolchain/setup/native
cd /opt/zmk

# Need to pin to 0.3 for the Keebart Corne.
git fetch --tags
git checkout v0.3

pip3 install --user -U west
west init -l app/
west update
west zephyr-export
pip3 install --user -r zephyr/scripts/requirements-base.txt

# Install Zephyr SDK:
# https://docs.zephyrproject.org/3.5.0/develop/getting_started/index.html#install-zephyr-sdk
wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.3/zephyr-sdk-0.16.3_linux-x86_64.tar.xz
tar xvf zephyr-sdk-0.16.3_linux-x86_64.tar.xz
sudo mv zephyr-sdk-0.16.3 /opt/zephyr
cd /opt/zephyr/ && ./setup.sh
```

## Updating ZMK

```bash
cd /opt/zmk
git pull
west update
```

# `aurora/sweep`

I maintain my layout in `.kbl`, which is compiled to `keymap.c` using `kbl` (see the setup instructions).

```bash
~/.dots/dots/kbd/flash.sh qmk splitkb/aurora/sweep
```

Then hold the Boot button on the RP2040 while plugging it in for it to show up as a USB disk.

# `urchin`

Build and flash each side independently:

```bash
~/.dots/dots/kbd/flash.sh zmk urchin left
~/.dots/dots/kbd/flash.sh zmk urchin right
```

## `corne` (Corne Choc Pro)

ZMK module (`corne-zmk-module`) is from <https://github.com/Keebart/zmk-config>.
