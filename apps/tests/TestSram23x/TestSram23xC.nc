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
 * This is demo application for external SRAM based on Microchip 23xYYY
 * Application fill whole SRAM with incremental data (led1),
 * then data is read back and tested (led0),
 * if data does not equals error is shown (led2 toggles).
 *
 * @author Martin Cerveny
 */

#include "TestSram23x.h"

#include "TestSram23x.h"
#include "FirstSram23x.h"

module TestSram23xC {
	uses interface Leds;
	uses interface Boot;

	#ifdef TEST_SRAM23X_HPL
	uses interface Sram23x as FirstSram23x;
	#else
	uses interface GenericSram23x<first_sram23xaddress_t, first_sram23xsize_t> as FirstSram23x;
	#endif

}
implementation {

	uint8_t fill = 0;
	uint32_t where;

	uint8_t wbuff[64];
	uint8_t rbuff[20];

	event void Boot.booted() {
		call FirstSram23x.write(where = 0, 0, 0);
		call Leds.led1On();
	}

	event void FirstSram23x.readDone() {
		uint8_t i;
		uint32_t len;

		len = (where + sizeof(rbuff) > call FirstSram23x.getSize()) ? call FirstSram23x.getSize() - where : sizeof(rbuff);

		for(i = 0; i < len; i++) {
			if(rbuff[i] != ((where + i + fill)& 0xff))
				call Leds.led2Toggle();
		}
		where += len;

		if(where == call FirstSram23x.getSize()) {
			call Leds.led0Off();
			call Leds.led1On();
			fill++;
			call FirstSram23x.write(where = 0, 0, 0);
		}
		else {
			len = (where + sizeof(rbuff) > call FirstSram23x.getSize()) ? call FirstSram23x.getSize() - where : sizeof(rbuff);
			call FirstSram23x.read(where, rbuff, len);
		}
	}

	event void FirstSram23x.writeDone() {
		uint8_t i;
		uint32_t len;

		if(where == call FirstSram23x.getSize()) {
			call Leds.led0On();
			call Leds.led1Off();
			call FirstSram23x.read(where = 0, rbuff, sizeof(rbuff));
			return;
		}

		for(i = 0; i < sizeof(wbuff); i++)
			wbuff[i] = (i + where + fill)& 0xff;

		len = (where + sizeof(wbuff) > call FirstSram23x.getSize()) ? call FirstSram23x.getSize() - where : sizeof(wbuff);
		call FirstSram23x.write(where, wbuff, len);
		where += len;
	}

	event void FirstSram23x.fillDone() {
	}
	event void FirstSram23x.copyDone() {
	}
}