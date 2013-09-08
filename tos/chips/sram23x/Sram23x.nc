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
 * HAL/HPL SRAM interface.
 * Sequential mode over single line SPI is supported now only.
 * This is HAL/HPL version used from application and configured from platform.
 *
 * @author Martin Cerveny
 */

#include "Sram23x.h"
#include "HplSram23x_chip.h"

interface Sram23x {
	/**
	 * Read directly from sram. readDone will be signaled.
	 * @param addr Address to read from.
	 * @param data Buffer in which to place read data. The buffer is "returned"
	 *   at readDone time.
	 * @param n Number of bytes to read (> 0).
	 * @return SUCCESS When a request has been accepted. <br>
	 *            EBUSY Some activity pending.<br>
	 * 	          FAIL Bad parameters.
	 */
	command error_t read(sram23xaddress_t addr, uint8_t * PASS COUNT_NOK(n) data, sram23xsize_t n);

	/**
	 * Signaled when data has been read from the buffer. The data buffer
	 * is "returned".
	 */
	event void readDone();

	/**
	 * Write some data to sram, writeDone will be signaled.
	 * @param addr Address to write to.
	 * @param data Data to write. The buffer is "returned" at writeDone time.
	 * @param n Number of bytes to write (> 0).
	 * @return SUCCESS When a request has been accepted. <br>
	 *            EBUSY Some activity pending.<br>
	 * 	          FAIL Bad parameters.
	 */
	command error_t write(sram23xaddress_t addr, uint8_t * PASS COUNT_NOK(n) data, sram23xsize_t n);

	/**
	 * Signaled when data has been written to the buffer. The data buffer
	 * is "returned".
	 */
	event void writeDone();
	/**
	 * Fill SRAM with fill pattern, fillDone will be signaled.
	 * @param addr Address to erase to.
	 * @param n Number of bytes to erase (> 0).
	 * @param fill Pattern to fill.
  	 * @return SUCCESS When a request has been accepted. <br>
	 *            EBUSY Some activity pending.<br>
	 * 	          FAIL Bad parameters.
	 */
	command error_t fill(sram23xaddress_t addr, sram23xsize_t n, uint8_t fill);

	/**
	 * Signaled when SRAM is filled.
	 */
	event void fillDone();

	/**
	 * Query size of SRAM.
	 * @return Size in bytes returned.
	 */
	command sram23xaddress_t getSize();
}