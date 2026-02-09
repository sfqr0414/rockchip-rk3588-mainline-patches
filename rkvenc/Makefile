# SPDX-License-Identifier: (GPL-2.0+ OR MIT)
#
# Rockchip VEPU580 encoder driver - Standalone DKMS Makefile
# Copyright (C) 2026 Ross Cawston
#

# Module name
obj-m := rkvenc.o

# Source files for the module
rkvenc-objs := rkvenc_drv.o \
               rkvenc_hw.o \
               rkvenc_iommu.o \
               rkvenc_service.o \
               rkvenc_task.o

# Compiler flags
ccflags-y := -I$(src)/uapi

# Kernel build directory
KDIR ?= /lib/modules/$(shell uname -r)/build

# Current directory
PWD := $(shell pwd)

# Default target
all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

# Clean target
clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

# Install target
install:
	$(MAKE) -C $(KDIR) M=$(PWD) modules_install

# Help target
help:
	@echo "Rockchip VEPU580 encoder driver build"
	@echo ""
	@echo "Targets:"
	@echo "  all     - Build the kernel module (default)"
	@echo "  clean   - Clean build artifacts"
	@echo "  install - Install the kernel module"
	@echo ""
	@echo "Variables:"
	@echo "  KDIR    - Kernel build directory (default: /lib/modules/\$$(uname -r)/build)"

.PHONY: all clean install help
