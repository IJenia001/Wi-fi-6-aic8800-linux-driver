# Variables
INSTALL_SCRIPT = ./install_setup.sh
UNINSTALL_SCRIPT = ./uninstall_setup.sh
BUILD_DIR = drivers/aic8800
TARGET = aic8800_fdrv.ko
KVER ?= $(shell uname -r)
KDIR ?= /lib/modules/$(KVER)/build
DKMS_PACKAGE := $(shell sed -n 's/^PACKAGE_NAME="\(.*\)"/\1/p' dkms.conf)
DKMS_VERSION := $(shell sed -n 's/^PACKAGE_VERSION="\(.*\)"/\1/p' dkms.conf)

# Default target to build the driver
all: build

# Build the driver
build:
	@echo "Compiling the driver..."
	$(MAKE) -C $(BUILD_DIR) KVER="$(KVER)" KDIR="$(KDIR)"

# Register the source with DKMS and install the modules for $(KVER).
# Kernel upgrades rebuild the modules through /etc/kernel/postinst.d/dkms.
install:
	@if [ "$$(id -u)" -ne 0 ]; then echo "Run: sudo make install"; exit 1; fi
	@command -v dkms >/dev/null || { echo "Install DKMS first: apt install dkms"; exit 1; }
	@echo "Installing $(DKMS_PACKAGE) $(DKMS_VERSION) for kernel $(KVER) via DKMS..."
	@if [ "$(KVER)" = "$$(uname -r)" ]; then modprobe -r aic_zlp_quirk aic8800_fdrv aic_load_fw 2>/dev/null || true; fi
	@dkms remove -m $(DKMS_PACKAGE) -v $(DKMS_VERSION) --all >/dev/null 2>&1 || true
	dkms add --force "$(CURDIR)"
	dkms install -m $(DKMS_PACKAGE) -v $(DKMS_VERSION) -k "$(KVER)" --modprobe-on-install
	@if [ "$(KVER)" = "$$(uname -r)" ]; then modprobe aic_load_fw && modprobe aic8800_fdrv && modprobe aic_zlp_quirk; fi

# Uninstall the driver using the uninstall script
uninstall:
	@if [ "$$(id -u)" -ne 0 ]; then echo "Run: sudo make uninstall"; exit 1; fi
	@echo "Removing $(DKMS_PACKAGE) $(DKMS_VERSION) from DKMS..."
	@if [ "$(KVER)" = "$$(uname -r)" ]; then modprobe -r aic_zlp_quirk aic8800_fdrv aic_load_fw 2>/dev/null || true; fi
	$(MAKE) -C $(BUILD_DIR) KVER="$(KVER)" KDIR="$(KDIR)" uninstall
	@dkms remove -m $(DKMS_PACKAGE) -v $(DKMS_VERSION) --all >/dev/null 2>&1 || true
	@rm -rf "/usr/src/$(DKMS_PACKAGE)-$(DKMS_VERSION)"
	@AIC_TARGET_KVER="$(KVER)" bash $(UNINSTALL_SCRIPT)

# Clean the build artifacts
clean:
	@echo "Cleaning the build artifacts..."
	$(MAKE) -C $(BUILD_DIR) KVER="$(KVER)" KDIR="$(KDIR)" clean

# Phony targets to avoid conflicts with files
.PHONY: all build install uninstall clean
