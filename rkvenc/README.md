# Rockchip RK3588 VEPU580 Encoder Driver

This is a standalone, DKMS-compatible driver for the Rockchip VEPU580 hardware video encoder found on RK3588 SoCs.

## Features

- **Hardware Support**: RK3588 VEPU580 encoder (rkvenc v2)
- **Codecs**: H.264, H.265/HEVC, JPEG encoding
- **Resolution**: Up to 8K encoding support
- **Multi-core**: Dual-core encoder support with CCU (Core Control Unit)
- **Standard APIs**: Uses mainline Linux kernel APIs (no kernel core modifications required)

## Driver Architecture

The driver consists of the following components:

- **rkvenc_drv.c**: Platform driver, probe/remove, power management
- **rkvenc_hw.c**: Hardware control, register programming, IRQ handling
- **rkvenc_service.c**: Character device `/dev/mpp_service`, IOCTL interface
- **rkvenc_task.c**: Task lifecycle management, memory region handling
- **rkvenc_iommu.c**: IOMMU/DMA buffer management using standard dma-buf APIs
- **rkvenc_hw.h**: Hardware definitions and data structures
- **compat.h**: UAPI structures and IOCTL commands

## Zero-Intrusion Design

This driver has been refactored to use **only standard Linux kernel APIs**:

### IOMMU/DMA Management
- ✅ Uses `dma_set_mask_and_coherent()` for DMA mask setup
- ✅ Uses `dma_buf_get()`, `dma_buf_attach()`, `dma_buf_map_attachment()` for dma-buf operations
- ✅ Uses `sg_dma_address()` for IOVA address retrieval
- ✅ Uses `iommu_attach_group()`, `iommu_get_domain_for_dev()` for IOMMU operations
- ❌ No custom `rockchip_iommu_xxx()` function calls

### Memory Management
- ✅ Standard dma-buf attachment and scatter-gather table handling
- ✅ Uses `dma_sync_single_range_for_cpu/device()` for cache management
- ✅ IOMMU domain sharing between multi-core encoder instances

## Build Instructions

### Prerequisites

```bash
# Install kernel headers
sudo apt-get install linux-headers-$(uname -r)

# Or on other distributions
sudo dnf install kernel-devel
sudo pacman -S linux-headers
```

### Building the Module

```bash
cd rkvenc
make
```

### Installing the Module

```bash
sudo make install
sudo modprobe rkvenc
```

### DKMS Installation

For automatic module rebuilding on kernel updates:

```bash
# Copy source to DKMS tree
sudo mkdir -p /usr/src/rk-vcodec-1.0
sudo cp -r * /usr/src/rk-vcodec-1.0/

# Add to DKMS
sudo dkms add -m rk-vcodec -v 1.0

# Build and install
sudo dkms build -m rk-vcodec -v 1.0
sudo dkms install -m rk-vcodec -v 1.0
```

## Device Tree Requirements

The driver requires proper device tree bindings. Example snippet:

```dts
rkvenc_ccu: rkvenc-ccu {
	compatible = "rockchip,rkv-encoder-v2-ccu";
	rockchip,grf = <&sys_grf>;
};

venc_core0: venc-core@fdbd0000 {
	compatible = "rockchip,rkv-encoder-v2-core";
	reg = <0x0 0xfdbd0000 0x0 0x800>;
	interrupts = <GIC_SPI 104 IRQ_TYPE_LEVEL_HIGH>;
	clocks = <&cru ACLK_RKVENC0>, <&cru HCLK_RKVENC0>,
	         <&cru CLK_RKVENC0_CORE>;
	clock-names = "aclk", "hclk", "core";
	assigned-clocks = <&cru ACLK_RKVENC0>, <&cru CLK_RKVENC0_CORE>;
	assigned-clock-rates = <850000000>, <850000000>;
	resets = <&cru SRST_A_RKVENC0>, <&cru SRST_H_RKVENC0>,
	         <&cru SRST_RKVENC0_CORE>;
	reset-names = "rst_a", "rst_h", "rst_core";
	power-domains = <&power RK3588_PD_RKVENC0>;
	iommus = <&venc0_mmu>;
	rockchip,srv = <&mpp_srv>;
	rockchip,ccu = <&rkvenc_ccu>;
	rockchip,core-id = <0>;
	rockchip,taskqueue-node = <0>;
	rockchip,resetgroup-node = <0>;
	rockchip,sram = <&rkvenc_sram>;
	rockchip,rcb-iova = <0x10000000 0x80000>;
};

venc0_mmu: iommu@fdbd0800 {
	compatible = "rockchip,rk3588-iommu", "rockchip,rk3568-iommu";
	reg = <0x0 0xfdbd0800 0x0 0x40>;
	interrupts = <GIC_SPI 105 IRQ_TYPE_LEVEL_HIGH>;
	clocks = <&cru ACLK_RKVENC0>, <&cru HCLK_RKVENC0>;
	clock-names = "aclk", "iface";
	power-domains = <&power RK3588_PD_RKVENC0>;
	#iommu-cells = <0>;
};

mpp_srv: mpp-service {
	compatible = "rockchip,mpp-service";
	status = "okay";
};
```

## Userspace Interface

The driver provides a character device `/dev/mpp_service` that implements the Rockchip MPP (Media Process Platform) protocol.

### IOCTL Commands

- `MPP_IOC_CFG_V1`: Main configuration IOCTL
  - `MPP_CMD_INIT_CLIENT_TYPE`: Initialize client session
  - `MPP_CMD_SET_REG_WRITE`: Write hardware registers
  - `MPP_CMD_SET_REG_READ`: Read hardware registers
  - `MPP_CMD_POLL_HW_FINISH`: Wait for encoding completion

### Integration with MPP Library

This driver is designed to work with the Rockchip MPP userspace library:

```bash
git clone https://github.com/rockchip-linux/mpp.git
cd mpp
cmake -DCMAKE_BUILD_TYPE=Release
make
sudo make install
```

## Kernel Version Compatibility

- **Minimum**: Linux 6.19 or later
- **Tested**: Linux 6.19
- **Architecture**: ARM64 (Rockchip RK3588)

### Required Kernel Config

```
CONFIG_ARCH_ROCKCHIP=y
CONFIG_ARM64=y
CONFIG_IOMMU_API=y
CONFIG_ROCKCHIP_IOMMU=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_PM=y
CONFIG_PM_RUNTIME=y
```

## Debugging

Enable debug output:

```bash
# Load module with debug parameter
sudo modprobe rkvenc rkvenc_debug=0x3f

# Or set at runtime
echo 0x3f | sudo tee /sys/module/rkvenc/parameters/rkvenc_debug
```

Debug flags:
- `0x00000004` - IRQ status
- `0x00000008` - IOMMU operations
- `0x00000010` - IOCTL calls
- `0x00000020` - Function entry/exit
- `0x00000200` - Task information
- `0x01000000` - CCU operations
- `0x02000000` - Core operations

## License

This driver is dual-licensed under GPL-2.0 and MIT licenses.

## Credits

- **Original BSP driver**: Rockchip Electronics Co., Ltd.
- **Mainline port and refactoring**: Ross Cawston (2026)
- **Zero-intrusion adaptation**: AI-assisted refactoring for standard kernel APIs

## References

- [Rockchip MPP Library](https://github.com/rockchip-linux/mpp)
- [RK3588 Technical Reference Manual](https://opensource.rock-chips.com/wiki_RK3588)
- [Linux DMA-BUF Framework](https://docs.kernel.org/driver-api/dma-buf.html)
- [Linux IOMMU API](https://docs.kernel.org/core-api/iommu.html)
