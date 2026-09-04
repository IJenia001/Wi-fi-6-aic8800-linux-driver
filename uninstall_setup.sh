#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi
################################################################################
#			clean files
################################################################################
echo "Clean aic8800 wifi driver setup files!"
$SUDO modprobe -r aic_zlp_quirk aic8800_fdrv aic_load_fw 2>/dev/null || true
$SUDO rm -rf /lib/firmware/aic8800D80
$SUDO rm -rf /lib/firmware/aic8800D80N
$SUDO rm -f /etc/udev/rules.d/aic.rules /etc/modules-load.d/aic8800.conf
$SUDO udevadm control --reload

echo "The Uninstall Setup Script is completed!"
