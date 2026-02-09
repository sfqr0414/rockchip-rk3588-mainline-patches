/* SPDX-License-Identifier: (GPL-2.0+ OR MIT) WITH Linux-syscall-note */
/*
 * Rockchip VEPU580 encoder driver - Userspace API
 * Extracted from Rockchip BSP
 *
 * Copyright (C) 2023 Rockchip Electronics Co., Ltd.
 * Copyright (C) 2026 Ross Cawston
 */

#ifndef __UAPI_RKVENC_H__
#define __UAPI_RKVENC_H__

#include <linux/types.h>

/*
 * Register request structure for userspace-kernel communication
 * Used to transfer register data between userspace and kernel
 */
struct mpp_request {
	__u32 offset;		/* Register offset */
	__u32 size;		/* Size of data in bytes */
	__u32 *data;		/* Pointer to register data */
};

/*
 * IOCTL commands for MPP service
 */
#define MPP_IOC_MAGIC		'p'
#define MPP_IOC_CFG_V1		_IOWR(MPP_IOC_MAGIC, 1, unsigned long)

#endif /* __UAPI_RKVENC_H__ */
