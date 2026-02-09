# Rockchip RK3588 VEPU580 Encoder Driver (Standalone)

This is a standalone, zero-intrusion refactored version of the RK3588 VEPU580 H.265 encoder driver, extracted from the kernel patch and made compatible with standard mainline Linux kernels (6.19+).

## Features

- **Zero Intrusion**: Uses only standard Linux kernel APIs (no custom IOMMU hacks)
- **Standard DMA-buf**: Uses standard dma-buf attach/map/detach interfaces
- **40-bit Addressing**: Properly configured DMA mask for RK3588's IOVA space
- **DKMS Ready**: Can be built and installed as a DKMS module

## Directory Structure

```
rkvenc/
├── rkvenc_drv.c       - Platform driver and probe logic
├── rkvenc_hw.c        - Hardware control and register operations
├── rkvenc_hw.h        - Hardware definitions and data structures
├── rkvenc_iommu.c     - IOMMU and DMA buffer management (refactored)
├── rkvenc_service.c   - Character device and IOCTL handlers
├── rkvenc_task.c      - Task lifecycle and memory region management
├── compat.h           - Compatibility layer for mainline kernels
├── uapi/
│   └── rkvenc.h       - Userspace API definitions
├── Makefile           - Standalone build configuration
├── dkms.conf          - DKMS package configuration
└── README.md          - This file
```

## Key Refactoring Changes

### 1. Standard IOMMU/DMA APIs
- **Before**: Custom `rockchip_iommu_*` functions
- **After**: Standard `dma_set_mask_and_coherent()` with 40-bit mask

### 2. DMA Buffer Management
- Already uses standard `dma_buf_get()`, `dma_buf_attach()`, `dma_buf_map_attachment()`
- Uses `sg_dma_address()` for IOVA translation
- No changes needed - already mainline-compatible!

### 3. Local Headers
- Created `uapi/rkvenc.h` for userspace API (replaces kernel uapi)
- Created `compat.h` for kernel compatibility definitions
- No dependencies on modified kernel files

## Building

### Method 1: Direct Build

```bash
cd rkvenc
make
sudo insmod rkvenc.ko
```

### Method 2: DKMS Installation

```bash
# Copy to DKMS source directory
sudo mkdir -p /usr/src/rk-vcodec-1.0
sudo cp -r rkvenc/* /usr/src/rk-vcodec-1.0/

# Add to DKMS
sudo dkms add -m rk-vcodec -v 1.0

# Build
sudo dkms build -m rk-vcodec -v 1.0

# Install
sudo dkms install -m rk-vcodec -v 1.0
```

### Method 3: In-tree Build (Optional)

If you want to build this as part of the kernel tree:

```bash
# Copy to kernel source
cp -r rkvenc /path/to/linux/drivers/media/platform/rockchip/

# Add to kernel config
# CONFIG_VIDEO_ROCKCHIP_RKVENC=m

# Build kernel
make -j$(nproc)
```

## Device Tree Requirements

The driver expects the following device tree nodes:

```dts
rkvenc_core: rkvenc-core@fdba0000 {
    compatible = "rockchip,rkvenc-core";
    reg = <0x0 0xfdba0000 0x0 0x400>;
    interrupts = <GIC_SPI 122 IRQ_TYPE_LEVEL_HIGH>;
    clocks = <&cru ACLK_RKVENC>, <&cru HCLK_RKVENC>;
    clock-names = "aclk", "hclk";
    iommus = <&rkvenc_mmu>;
    power-domains = <&power RK3588_PD_RKVENC>;
    rockchip,srv = <&mpp_srv>;
    rockchip,task-capacity = <8>;
};
```

## Dependencies

- Linux kernel 6.19+ with standard IOMMU and DMA-buf support
- Rockchip IOMMU driver (rockchip-iommu)
- MPP userspace library for encoding

## Testing

After loading the module:

```bash
# Verify module is loaded
lsmod | grep rkvenc

# Check device node
ls -l /dev/mpp_service

# Test with MPP
mpp_enc_test -i input.yuv -o output.h265 -w 1920 -h 1080 -t 7
```

## Known Limitations

- Requires RK3588 SoC with VEPU580 encoder
- Requires compatible MPP userspace library
- SRAM allocation is optional (uses fallback if unavailable)

## License

This driver is licensed under GPL-2.0+ OR MIT, consistent with the original Rockchip BSP code.

## Authors

- Original: Rockchip Electronics Co., Ltd.
- Mainline Port: Ross Cawston (2026)
- Zero-Intrusion Refactoring: GitHub Copilot (2026)
