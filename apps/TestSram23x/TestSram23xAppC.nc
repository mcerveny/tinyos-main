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
 * Two possible integration is possible:
 * HAL/HPL - only one SRAM available and toplevel component is Sram23xC.
 * HAL/Generic - you can create many SRAM with generic "new" component GenericSram23xC.
 *
 * @author Martin Cerveny
 */

#include "TestSram23x.h"

configuration TestSram23xAppC {
}
implementation {
	components TestSram23xC;

	components LedsC;
	TestSram23xC.Leds->LedsC;
	components MainC;
	TestSram23xC->MainC.Boot;

	#ifdef TEST_SRAM23X_HPL

	/**
	 * This is test for HAL/HPL version
	 * This files should be placed in tos/platform/XYZ/chips/sram23x/ directory (in this example are placed here):
	 * HplSram23x_chip.h - defines type of SRAM (size, address bytes, typedefs for platform)
	 * HplSram23xC.nc - defines SPI bindings and CS output pin
	 *
	 * HAL component is Sram23xC with interface Sram23x
	 */
	components Sram23xC;
	TestSram23xC.FirstSram23x->Sram23xC.Sram23x;

	#else

	/**
	 * This is test for HAL/generic version
	 * This files (that uses "new" generic) should be placed in application or platform or sensorboard
	 * (tos/platforms/XYZ/, tos/sensorboards/XYZ/  or in application directory)
	 * (filenames only as example, in this example are placed here):
	 * FirstSram23x.h - defines typedefs for parametric interface for first SRAM
	 * FirstSram23C.nc - defines SPI bindings and CS output pin for first SRAM
	 *
	 * Generic component is GenericSram23xC binded in FirstSram23C.nc.
	 */
	components FirstSram23xC;
	TestSram23xC.FirstSram23x->FirstSram23xC;

	#endif

}
