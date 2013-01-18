//

/*
 * Copyright (c) 2011.  
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
 * - Neither the name of the University of California nor the names of
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

#include "IeeeEui64.h"

module WserialIeeeEui64P {
	provides interface LocalIeeeEui64;
	provides interface Init as SoftwareInit;
	provides interface Init as PlatformInit;

	uses interface Resource as SpiResource;
	uses interface SpiByte;
	uses interface GeneralIO as SpiSel;
	uses interface BusyWait<TMicro, uint16_t>;
}

implementation {
	ieee_eui64_t eui;

	command ieee_eui64_t LocalIeeeEui64.getId() {
		atomic return eui;
	}

	command error_t PlatformInit.init() {
		call SpiSel.makeOutput();
		call SpiSel.set();
		return SUCCESS;
	}

	command error_t SoftwareInit.init() {
		memset(eui.data, 0, sizeof(eui.data));
		return call SpiResource.request();
	}

	#define MAC_ADDRESS_POSITION 0xFA
	#define EEPROM_READ_CMD 0x03
	#define EEPROM_STATUS_CMD 0x05
	#define STATUS_WIP 0x01

	event void SpiResource.granted() {

		call SpiSel.clr();
		call SpiByte.write(EEPROM_READ_CMD);
		call SpiByte.write(MAC_ADDRESS_POSITION);
		eui.data[7] = call SpiByte.write(0xff);
		eui.data[6] = call SpiByte.write(0xff);
		eui.data[5] = call SpiByte.write(0xff);
		eui.data[4] = 0xff;
		eui.data[3] = 0xfe;
		eui.data[2] = call SpiByte.write(0xff);
		eui.data[1] = call SpiByte.write(0xff);
		eui.data[0] = call SpiByte.write(0xff);
		call SpiSel.set();

		call SpiResource.release();
	}
}