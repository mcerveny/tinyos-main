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
 * HAL/Generic SRAM interface.
 * Sequential mode over single line SPI is supported now only.
 * This is HAL/Generic version configured and used directly from application.
 *
 * @author Martin Cerveny
 */

/**
 * @param sram23xaddress_t  Type must be large enough to hold address (usually uint16_t/uint32_t).
 * @param sram23xsize_t Type must be large enough to hold request size (usually only uint16_t on small platforms).
 */

interface GenericSram23x<sram23xaddress_t, sram23xsize_t> {
	/**
	 * Query size of SRAM.
	 * @return Size in bytes returned.
	 */
	command sram23xaddress_t getSize();

	/**
	 * Read from SRAM. readDone will be signaled. Read is done in SRAM23X_MAX_BLOCK block sizes.
	 * @param addr Address to read from.
	 * @param data Buffer in which to place read data. The buffer is "returned"
	 *   at readDone time.
	 * @param n Number of bytes to read (> 0).
	 * @return SUCCESS When the request has been accepted.<br/>
	 *   EBUSY Some activity is pending.<br/>
	 *   FAIL Bad parameters.
	 */
	command error_t read(sram23xaddress_t addr, void * PASS COUNT_NOK(n) data, sram23xsize_t n);

	/**
	 * Signaled when data has been read to the buffer. The data buffer
	 * is "returned".
	 */
	event void readDone();

	/**
	 * Read synchronously from SRAM.
	 * @param addr Address to read from.
	 * @param data Buffer in which to place read data.
	 * @param n Number of bytes to read (> 0).
	 * @return SUCCESS When read was successful.<br/>
	 *   EBUSY Some activity is pending or resource immediate request was unsuccessful.<br/>
	 *   FAIL Bad parameters.
	 */
	command error_t readNow(sram23xaddress_t addr, void * PASS COUNT_NOK(n) data, sram23xsize_t n);

	/**
	 * Write some data to SRAM, writeDone will be signaled. Write is done in SRAM23X_MAX_BLOCK block sizes.
	 * @param addr Address to write to.
	 * @param data Data to write. The buffer is "returned" at writeDone time.
	 * @param n Number of bytes to write (> 0).
	 * @return SUCCESS When the request has been accepted.<br/>
	 *   EBUSY Some activity is pending.<br/>
	 *   FAIL Bad parameters.
	 */
	command error_t write(sram23xaddress_t addr, void * PASS COUNT_NOK(n) data, sram23xsize_t n);

	/**
	 * Signaled when data has been written from the buffer. The data buffer
	 * is "returned".
	 */
	event void writeDone();

	/**
	 * Write synchronously to SRAM.
	 * @param addr Address to write to.
	 * @param data Data to write.
	 * @param n Number of bytes to write (> 0).
	 * @return SUCCESS When the request has been accepted.<br/>
	 *   EBUSY Some activity is pending or resource immediate request was unsuccessful.<br/>
	 *   FAIL Bad parameters.
	 */
	command error_t writeNow(sram23xaddress_t addr, void * PASS COUNT_NOK(n) data, sram23xsize_t n);

	/**
	 * Fill SRAM with fill pattern, fillDone will be signaled. Fill is done in SRAM23X_MAX_BLOCK block sizes.
	 * @param addr Address to erase to.
	 * @param n Number of bytes to erase (> 0).
	 * @param pattern Pattern to fill.
	 * @return SUCCESS When write was successful<br/>
	 *   EBUSY Some activity is pending.<br/>
	 *   FAIL Bad parameters.
	 */
	command error_t fill(sram23xaddress_t addr, sram23xsize_t n, uint8_t pattern);

	/**
	 * Signaled when SRAM is filled.
	 */
	event void fillDone();

	/**
	 * Fill synchronously SRAM with fill pattern.
	 * @param addr Address to erase to.
	 * @param n Number of bytes to erase (> 0).
	 * @param pattern Pattern to fill.
	 * @return SUCCESS When fill was successful.<br/>
	 *   EBUSY Some activity is pending or resource immediate request was unsuccessful.<br/>
	 *   FAIL Bad parameters.
	 */
	command error_t fillNow(sram23xaddress_t addr, sram23xsize_t n, uint8_t pattern);

	/**
	 * Copy data block in SRAM. copyDone will be signaled. Copy is done in SRAM23X_MAX_BLOCK block sizes.
	 * @param daddr Destination address.
	 * @param saddr Source address.
	 * @param n Number of bytes to copy (> 0).
	 * @return SUCCESS When the request has been accepted.<br/>
	 *   EBUSY Some activity is pending.<br/>
	 *   FAIL Bad parameters.
	 */
	command error_t copy(sram23xaddress_t daddr, sram23xaddress_t saddr, sram23xsize_t n);

	/**
	 * Signaled when data has been copied.
	 */
	event void copyDone();

	/**
	 * Copy data block in SRAM.
	 * @param daddr Destination address.
	 * @param saddr Source address.
	 * @param n Number of bytes to copy (> 0).
	 * @return SUCCESS When copy was successful.<br/>
	 *   EBUSY Some activity is pending or resource immediate request was unsuccessful.<br/>
	 *   FAIL Bad parameters.
	 */
	command error_t copyNow(sram23xaddress_t daddr, sram23xaddress_t saddr, sram23xsize_t n);

}