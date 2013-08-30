#include "Atm1281Usart.h"

module PlatformSerialP {

	provides interface StdControl;
	provides interface Atm1281UartConfigure;
	uses interface Resource;
	uses interface Atm128Calibrate;
}
implementation {

	command error_t StdControl.start() {
		return call Resource.immediateRequest();
	}
	command error_t StdControl.stop() {
		call Resource.release();
		return SUCCESS;
	}
	event void Resource.granted() {
	}

	Atm1281UartUnionConfig_t uartConfig;

	async command Atm1281UartUnionConfig_t * Atm1281UartConfigure.getConfig() {
		atomic {
			uartConfig = atm1281_uart_default_config;
			uartConfig.uartConfig.ubr = call Atm128Calibrate.baudrateRegister(PLATFORM_BAUDRATE);
		}
		return & uartConfig;
	}

}