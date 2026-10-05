#!/bin/sh
# Builds Voyager firmware from the keymap in this directory against ZSA's QMK
# fork, inside the QMK CLI container. Prints the path of the built .bin, which
# Keymapp flashes.
set -eu

# ZSA's QMK fork, firmware25 branch.
QMK_REPO=https://github.com/zsa/qmk_firmware.git
QMK_REF=e728f5309c20488498b62567b2715fdb4441353e
IMAGE=ghcr.io/qmk/qmk_cli

KEYMAP=dotfiles
SRC_DIR=$(cd "$(dirname "$0")" && pwd)
CACHE_DIR=${XDG_CACHE_HOME:-$HOME/.cache}/voyager
QMK_DIR=$CACHE_DIR/qmk_firmware
KEYMAP_DIR=$QMK_DIR/keyboards/zsa/voyager/keymaps/$KEYMAP

if [ ! -d "$QMK_DIR/.git" ]; then
    mkdir -p "$CACHE_DIR"
    git clone --filter=blob:none "$QMK_REPO" "$QMK_DIR"
fi
if ! git -C "$QMK_DIR" cat-file -e "$QMK_REF^{commit}" 2>/dev/null; then
    git -C "$QMK_DIR" fetch origin
fi
git -C "$QMK_DIR" checkout --quiet --detach "$QMK_REF"
git -C "$QMK_DIR" submodule update --init --depth 1 \
    lib/chibios lib/chibios-contrib lib/lufa lib/printf modules/zsa

rm -rf "$KEYMAP_DIR"
mkdir -p "$KEYMAP_DIR"
cp "$SRC_DIR"/keymap.c "$SRC_DIR"/keymap.json "$SRC_DIR"/config.h "$SRC_DIR"/rules.mk "$KEYMAP_DIR"/

docker run --rm -v "$QMK_DIR":/qmk_firmware -w /qmk_firmware "$IMAGE" \
    qmk compile -kb zsa/voyager -km "$KEYMAP"

cp "$QMK_DIR/zsa_voyager_$KEYMAP.bin" "$CACHE_DIR/voyager.bin"
echo "$CACHE_DIR/voyager.bin"
