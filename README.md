# Wi-Fi 6 Linux driver

This project contains the original Windows package and a Linux kernel driver for the
AIC8800/AIC8800D80 USB Wi-Fi 6 adapters identified in the Windows INF files.

## Table of Contents
- [Project Overview](#project-overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Compiling the Driver](#compiling-the-driver)
  - [Installing the Driver](#installing-the-driver)
- [Usage](#usage)
- [License](#license)

## Project Overview

The AIC8800 Linux Driver supports USB Wi-Fi adapters based on the AIC8800/AIC8800D80 chipsets. A clean module build has been verified with Linux 7.0 and 7.2.6 headers. Hardware operation still depends on the adapter and its firmware and should be checked on the target system.

## Features

- Support for USB and SDIO interfaces
- Linux BlueZ Bluetooth HCI support for AIC8800D80 adapters
- FullMAC driver with 802.11ac/ax capabilities
- WPA/WPA2 encryption
- MAC randomization support
- Power management features (DCDC_VRF mode)
- WPA3 compatibility (for kernels supporting it)
- MU-MIMO support (requires compatible firmware)
- Wireless extensions support

## Supported USB IDs

The driver includes the AIC IDs from the supplied package, including `VID_A69C`
(`PID_8801`, `PID_8D81`, `PID_8D83`, `PID_88DC`-`PID_88DE`) and the
rebranded adapters from `VID_368B`, `VID_2604`, and `VID_2357`.

## Requirements

To compile and install this driver, ensure the following dependencies are installed:

- Linux kernel headers for the target kernel
- GCC and Make
- DKMS (`dkms`), so the modules rebuild automatically when a new kernel is installed

`sudo make install` registers this tree with DKMS. After that, installing a
new kernel rebuilds `aic_load_fw`, `aic8800_fdrv`, and `aic_zlp_quirk` through
`/etc/kernel/postinst.d/dkms`.

To install for a different kernel that already has headers:

```bash
sudo make install KVER=6.1.0-<version>
```

Use the exact kernel version and matching headers installed on your system.

```bash
# Debian/Ubuntu
sudo apt install build-essential dkms linux-headers-$(uname -r)
```

## Installation

### Compiling the Driver

1. Compile the driver from this directory:

   ```bash
   make
   ```

   This will generate the necessary kernel module (`.ko` file).

### Installing the Driver

2. Install the package with DKMS. This copies the source to
   `/usr/src/aic8800-1.0.0`, builds the three modules, installs the firmware,
   and loads the modules when the target kernel is the running one:

   ```bash
   sudo make install
   ```

   Check the registration with `dkms status`.

3. To verify both modules are loaded, run:

   ```bash
   lsmod | grep -E 'aic_load_fw|aic8800_fdrv'
   bluetoothctl list
   ```

   Bluetooth uses the standard kernel `btusb` driver after the combo firmware
   is initialized. For USB `368b:8d81`, `aic_zlp_quirk` adds the required
   Bluetooth ACL packet behavior without replacing `btusb`.

### Uninstalling the Driver

If you need to remove the driver:

```bash
sudo make uninstall
```

## Usage

Once the driver is installed and loaded, the AIC8800 chipset will be automatically recognized by the Linux system. You can verify the wireless device is working by checking the network interfaces:

```bash
ip link
```

You can also manage the wireless device using standard Linux network management tools like `iwconfig`, `ifconfig`, or `nmcli`.

## Source and license

The Linux implementation and firmware are provided under the MIT license; see
[LICENSE](LICENSE). The Windows binaries remain vendor-supplied files.
