/*
 * Copyright (c) 2013 Martin Cerveny
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * Shared header for HAL/Generic and HAL/HPL SRAM interface.
 *
 * @author Martin Cerveny
 */

#ifndef SRAM23X_H
#define SRAM23X_H

enum {
	// commands we're executing
	SRAM23X_C_READ = 0x03,
	SRAM23X_C_WRITE = 0x02,
	SRAM23X_C_RDSR = 0x05,
	SRAM23X_C_WRSR = 0x01,

	// mode constants
	SRAM23X_M_BYTE_MODE = 0x00,
	SRAM23X_M_PAGE_MODE = 0x80,
	SRAM23X_M_SEQUENTIAL_MODE = 0x40,
};

// maximum request size per one resource request
// (To prevent block shared SPI resource and CPU dispatcher for log period of time)
#ifndef SRAM23X_MAX_BLOCK
#define SRAM23X_MAX_BLOCK 128
#endif

#endif /* SRAM23X_H */
