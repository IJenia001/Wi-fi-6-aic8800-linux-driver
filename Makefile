# Variables
INSTALL_SCRIPT = ./install_setup.sh
UNINSTALL_SCRIPT = ./uninstall_setup.sh
BUILD_DIR = drivers/aic8800
TARGET = aic8800_fdrv.ko
KVER ?= $(shell uname -r)
KDIR ?= /lib/modules/$(KVER)/build

# Default target to build the driver
all: build

# Build the driver
build:
	@echo "Compiling the driver..."
	$(MAKE) -C $(BUILD_DIR) KVER="$(KVER)" KDIR="$(KDIR)"

# Install the driver using the install script
install: build
	@echo "Installing the driver using install_setup.sh..."
	$(MAKE) -C $(BUILD_DIR) KVER="$(KVER)" KDIR="$(KDIR)" install
	@AIC_TARGET_KVER="$(KVER)" bash $(INSTALL_SCRIPT)

# Uninstall the driver using the uninstall script
uninstall:
	@echo "Uninstalling the driver using uninstall_setup.sh..."
	$(MAKE) -C $(BUILD_DIR) KVER="$(KVER)" KDIR="$(KDIR)" uninstall
	@AIC_TARGET_KVER="$(KVER)" bash $(UNINSTALL_SCRIPT)

# Clean the build artifacts
clean:
	@echo "Cleaning the build artifacts..."
	$(MAKE) -C $(BUILD_DIR) KVER="$(KVER)" KDIR="$(KDIR)" clean

# Phony targets to avoid conflicts with files
.PHONY: all build install uninstall clean
