/* SPDX-License-Identifier: LGPL-2.1-or-later */
/*
 * libiio - Library for interfacing industrial I/O (IIO) devices
 *
 * Libiio 0.x to 1.x compat library
 *
 * Copyright (C) 2021 Analog Devices, Inc.
 * Author: Paul Cercueil <paul.cercueil@analog.com>
 */
/** @file iio-compat.h
 * @brief Libiio 0.x to 1.x compatibility library */

#ifndef __LIBIIO_COMPAT_H__
#define __LIBIIO_COMPAT_H__

#include <iio.h>

#ifndef DOXYGEN
#ifdef LIBIIO_COMPAT_EXPORTS
#define __api __iio_api_export
#else
#define __api __iio_api_import
#endif
#endif


/* ---------------------------------------------------------------------------*/
/* ------------------------- Libiio 0.x to 1.x compat API --------------------*/
/** @defgroup TopLevel Top-level functions
 * @{ */


/** @brief Create a context from local IIO devices (Linux only)
 * @return On success, A pointer to an iio_context structure
 * @return On failure, NULL is returned and errno is set appropriately */
__api __check_ret struct iio_context * iio_create_local_context(void);


/** @brief Create a context from the network
 * @param host Hostname, IPv4 or IPv6 address where the IIO Daemon is running
 * @return On success, a pointer to an iio_context structure
 * @return On failure, NULL is returned and errno is set appropriately */
__api __check_ret struct iio_context * iio_create_network_context(const char *host);


/** @brief Create a context from a XML file
 * @param xml_file Path to the XML file to open
 * @return On success, A pointer to an iio_context structure
 * @return On failure, NULL is returned and errno is set appropriately
 *
 * <b>NOTE:</b> The format of the XML must comply to the one returned by
 * iio_context_get_xml. */
__api __check_ret struct iio_context * iio_create_xml_context(const char *xml_file);


/** @} *//* ------------------------------------------------------------------*/

#undef __api

#endif /* __LIBIIO_COMPAT_H__ */
