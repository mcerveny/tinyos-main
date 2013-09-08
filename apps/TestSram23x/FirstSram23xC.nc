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
 * Platform instance creation and binding for HAL/Generic Sram23x version.
 * This file should be placed in tos/platforms/XYZ/, tos/sensorboards/XYZ/  or in application directory if application specific.
 *
 * @author Martin Cerveny
 */

#include "FirstSram23x.h"

configuration FirstSram23xC {
	provides interface GenericSram23x<first_sram23xaddress_t, first_sram23xsize_t>;
}

implementation {
	components new GenericSram23xC(first_sram23xaddress_t, first_sram23xsize_t, FIRST_SRAM24X_ADDR_SIZE, FIRST_SRAM24X_CHIP_SIZE) as driver;

	GenericSram23x = driver.Sram23x;

	components Atm128SpiC as Spi;
	driver.SpiResource->Spi.Resource[unique("Atm128SpiC.Resource")];
	driver.FastSpiByte->Spi;

	components HplAtm128GeneralIOC as IO;
	driver.Select->IO.PortB7;

	components RealMainP;
	RealMainP.PlatformInit->driver.PlatformInit;
}
