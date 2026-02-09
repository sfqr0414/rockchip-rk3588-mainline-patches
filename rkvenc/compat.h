/* SPDX-License-Identifier: (GPL-2.0+ OR MIT) */
/*
 * Rockchip VEPU580 encoder driver - Compatibility definitions
 * These definitions ensure compatibility with standard mainline kernel
 *
 * Copyright (C) 2026 Ross Cawston
 */

#ifndef __RKVENC_COMPAT_H__
#define __RKVENC_COMPAT_H__

#include <linux/version.h>
#include <linux/dma-mapping.h>
#include <linux/iommu.h>

/*
 * DMA address mask for RK3588 VEPU580
 * RK3588 supports 40-bit physical addressing
 */
#define RKVENC_DMA_BIT_MASK		DMA_BIT_MASK(40)

/*
 * Default IOMMU domain cookie type compatibility
 * Mainline kernels use different cookie types
 */
#ifndef IOMMU_COOKIE_NONE
#define IOMMU_COOKIE_NONE		0
#endif

#endif /* __RKVENC_COMPAT_H__ */
