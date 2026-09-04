#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FIRMWARE_DIR="/lib/firmware/aic8800D80"
TARGET_KVER="${AIC_TARGET_KVER:-$(uname -r)}"

if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

echo "##################################################"
echo "AIC Wi-Fi driver Setup Files script"
echo "2023.03.09 v1.1.0"
echo "##################################################"

echo "Installing AIC8800 Wi-Fi and Bluetooth firmware..."
$SUDO install -d -m 0755 "$FIRMWARE_DIR"
$SUDO cp -a "$SCRIPT_DIR/fw/aic8800D80/." "$FIRMWARE_DIR/"
$SUDO install -d -m 0755 /lib/firmware/aic8800D80N
$SUDO cp -a "$SCRIPT_DIR/fw/aic8800D80N/." /lib/firmware/aic8800D80N/
$SUDO install -D -m 0644 "$SCRIPT_DIR/tools/aic.rules" /etc/udev/rules.d/aic.rules
$SUDO install -D -m 0644 /dev/null /etc/modules-load.d/aic8800.conf
printf '%s\n' aic_load_fw aic8800_fdrv aic_zlp_quirk | $SUDO tee /etc/modules-load.d/aic8800.conf >/dev/null
$SUDO udevadm control --reload
$SUDO udevadm trigger

echo "Loading Wi-Fi and Bluetooth modules..."
if [ "$TARGET_KVER" = "$(uname -r)" ]; then
    $SUDO modprobe aic_load_fw
    $SUDO modprobe aic8800_fdrv
else
    echo "Modules installed for kernel $TARGET_KVER; they will load when that kernel boots."
fi

echo "##################################################"
echo "The Setup Script is completed !"
echo "##################################################"
