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
 * HAL/HPL SRAM driver implementation.
 *
 * @author Martin Cerveny
 */

#include "Sram23x.h"
#include "HplSram23x_chip.h"

module Sram23xP {
	provides {
		interface Sram23x;
		interface Init as PlatformInit @exactlyonce();
	}

	uses {
		interface Resource as SpiResource;
		interface FastSpiByte;
		interface GeneralIO as Select;
	}

}
implementation {

	enum {
		SRAM32X_IDLE,
		SRAM32X_READ,
		SRAM32X_WRITE,
		SRAM32X_FILL
	}
	state = SRAM32X_IDLE;

	uint8_t initialized = FALSE;
	uint8_t * _data;
	uint8_t _fill;
	sram23xaddress_t _addr;
	sram23xsize_t _n;

	command error_t PlatformInit.init() {
		call Select.makeOutput();
		call Select.set();
		return SUCCESS;
	}

	command error_t Sram23x.read(sram23xaddress_t addr, uint8_t * PASS COUNT_NOK(n) data, sram23xsize_t n) {
		if(state != SRAM32X_IDLE)
			return EBUSY;
		if((n > SRAM24X_CHIP_SIZE) || (addr >= SRAM24X_CHIP_SIZE))
			return FAIL;
		state = SRAM32X_READ;
		_data = data;
		_addr = addr;
		_n = n;
		return call SpiResource.request();
	}

	command error_t Sram23x.write(sram23xaddress_t addr, uint8_t * PASS COUNT_NOK(n) data, sram23xsize_t n) {
		if(state != SRAM32X_IDLE)
			return EBUSY;
		if((n > SRAM24X_CHIP_SIZE) || (addr >= SRAM24X_CHIP_SIZE))
			return FAIL;
		state = SRAM32X_WRITE;
		_data = data;
		_addr = addr;
		_n = n;
		return call SpiResource.request();
	}

	command error_t Sram23x.fill(sram23xaddress_t addr, sram23xsize_t n, uint8_t fill) {
		if(state != SRAM32X_IDLE)
			return EBUSY;
		if((n > SRAM24X_CHIP_SIZE) || (addr >= SRAM24X_CHIP_SIZE))
			return FAIL;
		state = SRAM32X_FILL;
		_addr = addr;
		_fill = fill;
		_n = n;
		return call SpiResource.request();
	}

	command sram23xaddress_t Sram23x.getSize() {
		return SRAM24X_CHIP_SIZE;
	}

	event void SpiResource.granted() {

		if( ! initialized) {
			call Select.clr();
			call FastSpiByte.splitWrite(SRAM23X_C_WRSR);
			// switch to sequential mode (some chips has byte mode default).
			call FastSpiByte.splitReadWrite(SRAM23X_M_SEQUENTIAL_MODE);
			call FastSpiByte.splitRead();
			call Select.set();
			// >50ns CS disable time, this is ok, continue with cmd.
			initialized = TRUE;
		}

		switch(state) {
			case SRAM32X_READ : {
				uint8_t i;
				sram23xaddress_t max = SRAM23X_MAX_BLOCK;

				call Select.clr();
				call FastSpiByte.splitWrite(SRAM23X_C_READ);
				for(i = 0; i < SRAM24X_ADDR_SIZE; i++) {
					call FastSpiByte.splitReadWrite((_addr >> ((SRAM24X_ADDR_SIZE - i - 1) * 8))& 0xff);
				}
				if(_n) {
					call FastSpiByte.splitReadWrite(0);
					while(--_n && max--) {
						*_data++ = call FastSpiByte.splitReadWrite(0);
					}
					*_data++ = call FastSpiByte.splitRead();
				}
				call Select.set();
				call SpiResource.release();

				if(_n == 0) {
					state = SRAM32X_IDLE;
					signal Sram23x.readDone();
				}
				else {
					_addr = (_addr + SRAM23X_MAX_BLOCK) % SRAM24X_CHIP_SIZE;
					call SpiResource.request();
				}

				break;
			}
			case SRAM32X_WRITE : {
				uint8_t i;
				sram23xaddress_t max = SRAM23X_MAX_BLOCK;

				call Select.clr();
				call FastSpiByte.splitWrite(SRAM23X_C_WRITE);
				for(i = 0; i < SRAM24X_ADDR_SIZE; i++) {
					call FastSpiByte.splitReadWrite((_addr >> ((SRAM24X_ADDR_SIZE - i - 1) * 8))& 0xff);
				}
				while(_n && max--) {
					call FastSpiByte.splitReadWrite(*_data++);
					_n--;
				}
				call FastSpiByte.splitRead();
				call Select.set();
				call SpiResource.release();

				if(_n == 0) {
					state = SRAM32X_IDLE;
					signal Sram23x.writeDone();
				}
				else {
					_addr = (_addr + SRAM23X_MAX_BLOCK) % SRAM24X_CHIP_SIZE;
					call SpiResource.request();
				}
				break;
			}
			case SRAM32X_FILL : {
				uint8_t i;
				sram23xaddress_t max = SRAM23X_MAX_BLOCK;

				call Select.clr();
				call FastSpiByte.splitWrite(SRAM23X_C_WRITE);
				for(i = 0; i < SRAM24X_ADDR_SIZE; i++) {
					call FastSpiByte.splitReadWrite((_addr >> ((SRAM24X_ADDR_SIZE - i - 1) * 8))& 0xff);
				}
				while(_n && max--) {
					call FastSpiByte.splitReadWrite(_fill);
					_n--;
				}
				call FastSpiByte.splitRead();
				call Select.set();
				call SpiResource.release();

				if(_n == 0) {
					state = SRAM32X_IDLE;
					signal Sram23x.fillDone();
				}
				else {
					_addr = (_addr + SRAM23X_MAX_BLOCK) % SRAM24X_CHIP_SIZE;
					call SpiResource.request();
				}
				break;
			}
			default : // unexpected cmd
		}
	}
}
