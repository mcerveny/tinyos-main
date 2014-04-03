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
 * HAL/Generic SRAM driver implementation.
 *
 * @author Martin Cerveny
 */

#include "Sram23x.h"

/**
 * @param sram23xaddress_t  Type must be large enough to hold address (usually uint16_t/uint32_t).
 * @param sram23xsize_t Type must be large enough to hold request size (usually only uint16_t on small platforms).
 * @param cfg_addrsize How many bytes used for address in SRAM (2 or 3).
 * @param cfg_chipsize How large is the SRAM in bytes (8192, 32768, ...)
 */

generic module GenericSram23xC(typedef sram23xaddress_t @integer(), typedef sram23xsize_t @integer(), uint8_t cfg_addrsize, uint32_t cfg_chipsize) {
	provides {
		interface GenericSram23x<sram23xaddress_t, sram23xsize_t> as Sram23x;
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
		SRAM32X_FILL,
		SRAM32X_COPY
	}
	state = SRAM32X_IDLE;

	bool initialized = FALSE;
	uint8_t * _data;
	uint8_t _pattern;
	sram23xaddress_t _daddr, _saddr;
	sram23xsize_t _n;

	command error_t PlatformInit.init() {
		call Select.makeOutput();
		call Select.set();
		return SUCCESS;
	}

	void init() {
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
	}

	command error_t Sram23x.read(sram23xaddress_t addr, void * PASS COUNT_NOK(n) data, sram23xsize_t n) {
		if(state != SRAM32X_IDLE)
			return EBUSY;
		if((n > cfg_chipsize) || (addr >= cfg_chipsize))
			return FAIL;
		state = SRAM32X_READ;
		_data = data;
		_saddr = addr;
		_n = n;
		return call SpiResource.request();
	}

	command error_t Sram23x.readNow(sram23xaddress_t addr, void * PASS COUNT_NOK(n) data, sram23xsize_t n) {
		uint8_t i;

		if(state != SRAM32X_IDLE)
			return EBUSY;
		if((n > cfg_chipsize) || (addr >= cfg_chipsize))
			return FAIL;
		if(call SpiResource.immediateRequest() != SUCCESS)
			return EBUSY;

		init();

		call Select.clr();
		call FastSpiByte.splitWrite(SRAM23X_C_READ);
		for(i = 0; i < cfg_addrsize; i++) {
			call FastSpiByte.splitReadWrite((addr >> ((cfg_addrsize - i - 1) * 8))& 0xff);
		}
		if(n) {
			call FastSpiByte.splitReadWrite(0);
			while(--n) {
				*(uint8_t * ) data++ = call FastSpiByte.splitReadWrite(0);
			}
			*(uint8_t * ) data++ = call FastSpiByte.splitRead();
		}
		call Select.set();
		call SpiResource.release();

		return SUCCESS;
	}

	command error_t Sram23x.write(sram23xaddress_t addr, void * PASS COUNT_NOK(n) data, sram23xsize_t n) {
		if(state != SRAM32X_IDLE)
			return EBUSY;
		if((n > cfg_chipsize) || (addr >= cfg_chipsize))
			return FAIL;
		state = SRAM32X_WRITE;
		_data = data;
		_daddr = addr;
		_n = n;
		return call SpiResource.request();
	}

	command error_t Sram23x.writeNow(sram23xaddress_t addr, void * PASS COUNT_NOK(n) data, sram23xsize_t n) {
		uint8_t i;

		if(state != SRAM32X_IDLE)
			return EBUSY;
		if((n > cfg_chipsize) || (addr >= cfg_chipsize))
			return FAIL;
		if(call SpiResource.immediateRequest() != SUCCESS)
			return EBUSY;

		init();

		call Select.clr();
		call FastSpiByte.splitWrite(SRAM23X_C_WRITE);
		for(i = 0; i < cfg_addrsize; i++) {
			call FastSpiByte.splitReadWrite((addr >> ((cfg_addrsize - i - 1) * 8))& 0xff);
		}
		while(n) {
			call FastSpiByte.splitReadWrite(*(uint8_t * ) data++);
			n--;
		}
		call FastSpiByte.splitRead();
		call Select.set();
		call SpiResource.release();

		return SUCCESS;
	}

	command error_t Sram23x.fill(sram23xaddress_t addr, sram23xsize_t n, uint8_t pattern) {
		if(state != SRAM32X_IDLE)
			return EBUSY;
		if((n > cfg_chipsize) || (addr >= cfg_chipsize))
			return FAIL;
		state = SRAM32X_FILL;
		_daddr = addr;
		_pattern = pattern;
		_n = n;
		return call SpiResource.request();
	}

	command error_t Sram23x.fillNow(sram23xaddress_t addr, sram23xsize_t n, uint8_t pattern) {
		uint8_t i;

		if(state != SRAM32X_IDLE)
			return EBUSY;
		if((n > cfg_chipsize) || (addr >= cfg_chipsize))
			return FAIL;
		if(call SpiResource.immediateRequest() != SUCCESS)
			return EBUSY;

		init();

		call Select.clr();
		call FastSpiByte.splitWrite(SRAM23X_C_WRITE);
		for(i = 0; i < cfg_addrsize; i++) {
			call FastSpiByte.splitReadWrite((addr >> ((cfg_addrsize - i - 1) * 8))& 0xff);
		}
		while(n) {
			call FastSpiByte.splitReadWrite(pattern);
			n--;
		}
		call FastSpiByte.splitRead();
		call Select.set();
		call SpiResource.release();

		return SUCCESS;
	}

	command error_t Sram23x.copy(sram23xaddress_t daddr, sram23xaddress_t saddr, sram23xsize_t n) {
		if(state != SRAM32X_IDLE)
			return EBUSY;
		//TODO: does not work in modulo cfg_chipsize -> returned as error
		if((n > cfg_chipsize) || (daddr >= cfg_chipsize) || (saddr >= cfg_chipsize) || (daddr + n >= cfg_chipsize) || (saddr + n >= cfg_chipsize))
			return FAIL;
		state = SRAM32X_COPY;
		_daddr = daddr;
		_saddr = saddr;
		_n = n;
		return call SpiResource.request();
	}

	command error_t Sram23x.copyNow(sram23xaddress_t daddr, sram23xaddress_t saddr, sram23xsize_t n) {

		if(state != SRAM32X_IDLE)
			return EBUSY;
		//TODO: does not work in modulo cfg_chipsize -> returned as error
		if((n > cfg_chipsize) || (daddr >= cfg_chipsize) || (saddr >= cfg_chipsize) || (daddr + n >= cfg_chipsize) || (saddr + n >= cfg_chipsize))
			return FAIL;
		if(call SpiResource.immediateRequest() != SUCCESS)
			return EBUSY;

		init();

		// copy using temporary t_data buffer
		while(n) {
			uint8_t i;
			sram23xaddress_t t_saddr, t_daddr;
			sram23xsize_t max, t_n;
			uint8_t t_data[SRAM23X_MAX_BLOCK], *t_dataptr;

			if((daddr <= saddr) || (n <= SRAM23X_MAX_BLOCK)) {
				// normal copy or last block
				t_daddr = daddr;
				t_saddr = saddr;
			}
			else {
				// reverse copy (block from end)
				t_daddr = daddr + n - SRAM23X_MAX_BLOCK;
				t_saddr = saddr + n - SRAM23X_MAX_BLOCK;
			}

			call Select.clr();
			call FastSpiByte.splitWrite(SRAM23X_C_READ);
			for(i = 0; i < cfg_addrsize; i++) {
				call FastSpiByte.splitReadWrite((t_saddr >> ((cfg_addrsize - i - 1) * 8))& 0xff);
			}

			t_n = n;
			if(n) {
				t_dataptr = t_data;
				max = SRAM23X_MAX_BLOCK;
				call FastSpiByte.splitReadWrite(0);
				while(--n && --max) {
					*t_dataptr++ = call FastSpiByte.splitReadWrite(0);
				}
				*t_dataptr++ = call FastSpiByte.splitRead();
			}

			call Select.set();
			call Select.clr();

			call FastSpiByte.splitWrite(SRAM23X_C_WRITE);
			for(i = 0; i < cfg_addrsize; i++) {
				call FastSpiByte.splitReadWrite((t_daddr >> ((cfg_addrsize - i - 1) * 8))& 0xff);
			}

			t_dataptr = t_data;
			max = SRAM23X_MAX_BLOCK;
			n = t_n;

			while(n && max--) {
				call FastSpiByte.splitReadWrite(*t_dataptr++);
				n--;
			}
			call FastSpiByte.splitRead();
			call Select.set();

			if(daddr <= saddr) {
				// normal copy
				daddr = daddr + SRAM23X_MAX_BLOCK;
				saddr = saddr + SRAM23X_MAX_BLOCK;
			}
		}
		call SpiResource.release();

		return SUCCESS;
	}

	command sram23xaddress_t Sram23x.getSize() {
		return cfg_chipsize;
	}

	event void SpiResource.granted() {
		init();

		switch(state) {
			case SRAM32X_READ : {
				uint8_t i;
				sram23xsize_t max = SRAM23X_MAX_BLOCK;

				call Select.clr();
				call FastSpiByte.splitWrite(SRAM23X_C_READ);
				for(i = 0; i < cfg_addrsize; i++) {
					call FastSpiByte.splitReadWrite((_saddr >> ((cfg_addrsize - i - 1) * 8))& 0xff);
				}
				if(_n) {
					call FastSpiByte.splitReadWrite(0);
					while(--_n && --max) {
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
					_saddr = (_saddr + SRAM23X_MAX_BLOCK) % cfg_chipsize;
					call SpiResource.request();
				}

				break;
			}
			case SRAM32X_WRITE : {
				uint8_t i;
				sram23xsize_t max = SRAM23X_MAX_BLOCK;

				call Select.clr();
				call FastSpiByte.splitWrite(SRAM23X_C_WRITE);
				for(i = 0; i < cfg_addrsize; i++) {
					call FastSpiByte.splitReadWrite((_daddr >> ((cfg_addrsize - i - 1) * 8))& 0xff);
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
					_daddr = (_daddr + SRAM23X_MAX_BLOCK) % cfg_chipsize;
					call SpiResource.request();
				}
				break;
			}
			case SRAM32X_FILL : {
				uint8_t i;
				sram23xsize_t max = SRAM23X_MAX_BLOCK;

				call Select.clr();
				call FastSpiByte.splitWrite(SRAM23X_C_WRITE);
				for(i = 0; i < cfg_addrsize; i++) {
					call FastSpiByte.splitReadWrite((_daddr >> ((cfg_addrsize - i - 1) * 8))& 0xff);
				}
				while(_n && max--) {
					call FastSpiByte.splitReadWrite(_pattern);
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
					_daddr = (_daddr + SRAM23X_MAX_BLOCK) % cfg_chipsize;
					call SpiResource.request();
				}
				break;
			}
			case SRAM32X_COPY : {
				uint8_t i;
				sram23xaddress_t t_saddr, t_daddr;
				sram23xsize_t max, t_n;
				uint8_t t_data[SRAM23X_MAX_BLOCK], *t_dataptr;

				if((_daddr <= _saddr) || (_n <= SRAM23X_MAX_BLOCK)) {
					// normal copy or last block
					t_daddr = _daddr;
					t_saddr = _saddr;
				}
				else {
					// reverse copy (block from end)
					t_daddr = _daddr + _n - SRAM23X_MAX_BLOCK;
					t_saddr = _saddr + _n - SRAM23X_MAX_BLOCK;
				}

				call Select.clr();
				call FastSpiByte.splitWrite(SRAM23X_C_READ);
				for(i = 0; i < cfg_addrsize; i++) {
					call FastSpiByte.splitReadWrite((t_saddr >> ((cfg_addrsize - i - 1) * 8))& 0xff);
				}

				t_n = _n;
				if(_n) {
					t_dataptr = t_data;
					max = SRAM23X_MAX_BLOCK;
					call FastSpiByte.splitReadWrite(0);
					while(--_n && --max) {
						*t_dataptr++ = call FastSpiByte.splitReadWrite(0);
					}
					*t_dataptr++ = call FastSpiByte.splitRead();
				}

				call Select.set();
				call Select.clr();

				call FastSpiByte.splitWrite(SRAM23X_C_WRITE);
				for(i = 0; i < cfg_addrsize; i++) {
					call FastSpiByte.splitReadWrite((t_daddr >> ((cfg_addrsize - i - 1) * 8))& 0xff);
				}

				t_dataptr = t_data;
				max = SRAM23X_MAX_BLOCK;
				_n = t_n;

				while(_n && max--) {
					call FastSpiByte.splitReadWrite(*t_dataptr++);
					_n--;
				}
				call FastSpiByte.splitRead();

				call Select.set();
				call SpiResource.release();

				if(_n == 0) {
					state = SRAM32X_IDLE;
					signal Sram23x.copyDone();
				}
				else {
					if(_daddr <= _saddr) {
						// normal copy
						_daddr = _daddr + SRAM23X_MAX_BLOCK;
						_saddr = _saddr + SRAM23X_MAX_BLOCK;
					}
					call SpiResource.request();
				}
				break;
			}
			default : // unexpected cmd
		}
	}
}