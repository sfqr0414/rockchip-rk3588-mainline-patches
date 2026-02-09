/* SPDX-License-Identifier: (GPL-2.0+ OR MIT) */
/*
 * Rockchip VEPU580 encoder driver - UAPI compatibility layer
 * 
 * This file contains UAPI structures and constants extracted from the
 * Rockchip MPP (Media Process Platform) userspace API, adapted for
 * standalone kernel module compilation without kernel core modifications.
 *
 * Copyright (C) 2023 Rockchip Electronics Co., Ltd.
 * Copyright (C) 2026 Ross Cawston
 */

#ifndef __RKVENC_COMPAT_H__
#define __RKVENC_COMPAT_H__

#include <linux/types.h>
#include <linux/ioctl.h>

/* ---- IOCTL commands ---- */
#define MPP_IOC_MAGIC			'p'
#define MPP_IOC_CFG_V1			_IOW(MPP_IOC_MAGIC, 1, unsigned long)

/* ---- MPP command types ---- */
#define MPP_CMD_QUERY_BASE		0x00000000
#define MPP_CMD_QUERY_HW_SUPPORT	(MPP_CMD_QUERY_BASE + 0)
#define MPP_CMD_QUERY_HW_ID		(MPP_CMD_QUERY_BASE + 1)
#define MPP_CMD_QUERY_CMD_SUPPORT	(MPP_CMD_QUERY_BASE + 2)
#define MPP_CMD_QUERY_BUTT		(MPP_CMD_QUERY_BASE + 3)

#define MPP_CMD_INIT_BASE		0x00000100
#define MPP_CMD_INIT_CLIENT_TYPE	(MPP_CMD_INIT_BASE + 0)
#define MPP_CMD_INIT_DRIVER_DATA	(MPP_CMD_INIT_BASE + 1)
#define MPP_CMD_INIT_TRANS_TABLE	(MPP_CMD_INIT_BASE + 2)
#define MPP_CMD_INIT_BUTT		(MPP_CMD_INIT_BASE + 3)

#define MPP_CMD_SEND_BASE		0x00000200
#define MPP_CMD_SET_REG_WRITE		(MPP_CMD_SEND_BASE + 0)
#define MPP_CMD_SET_REG_READ		(MPP_CMD_SEND_BASE + 1)
#define MPP_CMD_SET_REG_ADDR_OFFSET	(MPP_CMD_SEND_BASE + 2)
#define MPP_CMD_SET_RCB_INFO		(MPP_CMD_SEND_BASE + 3)
#define MPP_CMD_SEND_BUTT		(MPP_CMD_SEND_BASE + 4)

#define MPP_CMD_POLL_BASE		0x00000300
#define MPP_CMD_POLL_HW_FINISH		(MPP_CMD_POLL_BASE + 0)
#define MPP_CMD_POLL_HW_INT_STATUS	(MPP_CMD_POLL_BASE + 1)
#define MPP_CMD_POLL_HW_SLICE		(MPP_CMD_POLL_BASE + 2)
#define MPP_CMD_POLL_BUTT		(MPP_CMD_POLL_BASE + 3)

#define MPP_CMD_CONTROL_BASE		0x00000400
#define MPP_CMD_RESET_SESSION		(MPP_CMD_CONTROL_BASE + 0)
#define MPP_CMD_TRANS_FD_TO_IOVA	(MPP_CMD_CONTROL_BASE + 1)
#define MPP_CMD_RELEASE_FD		(MPP_CMD_CONTROL_BASE + 2)
#define MPP_CMD_SEND_CODEC_INFO		(MPP_CMD_CONTROL_BASE + 3)
#define MPP_CMD_CONTROL_BUTT		(MPP_CMD_CONTROL_BASE + 4)

/* ---- MPP message flags ---- */
#define MPP_FLAGS_MULTI_MSG		BIT(0)
#define MPP_FLAGS_LAST_MSG		BIT(1)
#define MPP_FLAGS_REG_FD_NO_TRANS	BIT(2)
#define MPP_FLAGS_SCL_FD_NO_TRANS	BIT(3)
#define MPP_FLAGS_REG_NO_OFFSET		BIT(4)
#define MPP_FLAGS_SECURE_MODE		BIT(16)

/* ---- UAPI request structure ---- */
struct mpp_request {
	__u32 cmd;
	__u32 flags;
	__u32 size;
	__u32 offset;
	__u64 data;
};

#endif /* __RKVENC_COMPAT_H__ */
