# SPDX-License-Identifier: (GPL-2.0+ OR MIT)
# Makefile for Rockchip RKVENC (VEPU580) encoder driver standalone module

# Module name
MODULE_NAME := rkvenc

# Object files
obj-m += $(MODULE_NAME).o
$(MODULE_NAME)-objs := rkvenc_drv.o rkvenc_hw.o rkvenc_service.o rkvenc_task.o rkvenc_iommu.o

# Kernel build directory
KDIR ?= /lib/modules/$(shell uname -r)/build

# Module source directory
PWD := $(shell pwd)

# CFLAGS for module compilation
ccflags-y += -I$(src)

# Default target: build the module
all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

# Clean target: remove build artifacts
clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
	rm -f Module.symvers modules.order

# Install target: install the module
install:
	$(MAKE) -C $(KDIR) M=$(PWD) modules_install
	depmod -A

# Uninstall target: remove the module
uninstall:
	rm -f $(DESTDIR)/lib/modules/$(shell uname -r)/extra/$(MODULE_NAME).ko
	depmod -A

# Help target
help:
	@echo "Rockchip RKVENC (VEPU580) encoder driver build system"
	@echo ""
	@echo "Available targets:"
	@echo "  all       - Build the kernel module (default)"
	@echo "  clean     - Remove build artifacts"
	@echo "  install   - Install the module to the system"
	@echo "  uninstall - Remove the module from the system"
	@echo "  help      - Display this help message"
	@echo ""
	@echo "Variables:"
	@echo "  KDIR      - Kernel build directory (default: /lib/modules/\$(uname -r)/build)"

.PHONY: all clean install uninstall help
