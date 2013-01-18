// 

/*
 * Copyright (c) 2011
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 *
 * IN NO EVENT SHALL THE VANDERBILT UNIVERSITY BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE VANDERBILT
 * UNIVERSITY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * THE VANDERBILT UNIVERSITY SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE VANDERBILT UNIVERSITY HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 *
 * Author: Janos Sallai
 * Epic port by Stephen Dawson-Haggerty <stevedh@eecs.berkeley.edu>
 */ 

configuration LocalIeeeEui64C {
	provides interface LocalIeeeEui64;
}

implementation {
	components WserialIeeeEui64P, MainC, RealMainP;
	components Atm128SpiC as SpiC;
	components HplAtm128GeneralIOC as IO;

	LocalIeeeEui64 = WserialIeeeEui64P;

	WserialIeeeEui64P.SpiResource->SpiC.Resource[unique("Atm128SpiC.Resource")];
	WserialIeeeEui64P.SpiByte->SpiC.SpiByte;
	WserialIeeeEui64P.SpiSel->IO.PortB5;

	RealMainP.PlatformInit->WserialIeeeEui64P.PlatformInit;
	MainC.SoftwareInit->WserialIeeeEui64P.SoftwareInit;
	
	components BusyWaitMicroC;
	WserialIeeeEui64P.BusyWait -> BusyWaitMicroC;
}