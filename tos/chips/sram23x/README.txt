Implementation HAL/HPL/Generic for serial SRAM from Microchip 23xYYY.

- This implementation is tested on 23K256 (32kB RAM, 2 byte addressing) and should be compatible with 23x640, 23x256, 23x512, 23x1024 (3 byte adressing).
- The SPI mode 1x is only used (not dual and quad modes)
- The most common sequential mode is used (not page mode or byte mode).
- There is split API and synchronous API (*Now()) .
- There is two different types of integration:

1) HAL/HPL version

- This version is compliant to HAL/HPL layering.
- There can be defined only 1x SRAM.
- Top level HAL component is "Sram23xC" providing interface "Sram23x".
- The HPL layer should be implemented in two files "HplSram23x_chip.h" that defines constants and types the second file is "HplSram23xC.nc" that define bindings to platform SPI. Files should be placed in tos/platform/XYZ/chips/sram23x/ directory and "platform" should include "%T/platforms/XYZ/chips/sram23x" and "%T/chips/sram23x".

- Defines in HplSram23x_chip.h:
typedef sram23xaddress_t = Type must be large enough to hold address (usually uint16_t/uint32_t).
typedef sram23xsize_t =  Type must be large enough to hold request size (usually only uint16_t on small platforms).
constant SRAM24X_ADDR_SIZE = How many bytes used for address in SRAM (2 or 3).
constant SRAM24X_CHIP_SIZE = How large is the SRAM in bytes (8192, 32768, ...).

- Bindings in HplSram23xC.nc:
interface Resource as SpiResource = defined for shared resource reservation
interface FastSpiByte = defined for data transfer
interface GeneralIO as Select = chip select for SRAM chip

2) HAL/Generic version

- This version has "generic" interface for HAL module.
- There can be defined more than one SRAM HAL  (with "new").
- The driver can be bounded with many SRAM and with different types of SRAM at once.
- HAL component name is application, sensorboard or platform defined (for example FirstSram23xC.nc, SecondSram23xC.nc ...) with SPI binding and hardware parameters. The HAL file should be placed in tos/platforms/XYZ/, tos/sensorboards/XYZ/  or in application directory if application specific. The interface "GenericSram23x<type_addr_t, type_size_t>" provides same functionality as interface "Sram23x"in HAL/HPL version.
- HAL component uses driver HAL "GenericSram23xC" with "new" bindings with parameters.

- Parameters for new "GenericSram23xC(typedef sram23xaddress_t @integer(), typedef sram23xsize_t @integer(), uint8_t cfg_addrsize, uint32_t cfg_chipsize)":
sram23xaddress_t = Type must be large enough to hold address (usually uint16_t/uint32_t).
sram23xsize_t = Type must be large enough to hold request size (usually only uint16_t on small platforms).
cfg_addrsize = How many bytes used for address in SRAM (2 or 3).
cfg_chipsize = How large is the SRAM in bytes (8192, 32768, ...).

- Binings for GenericSram23xC:
interface GenericSram23x<sram23xaddress_t, sram23xsize_t> as Sram23x = Exported as HAL layer.
interface Init as PlatformInit @exactlyonce() = Initialize Select (chip select) pin.
interface Resource as SpiResource = defined for shared resource reservation
interface FastSpiByte = defined for data transfer
interface GeneralIO as Select = chip select for SRAM chip

Example of implementation and testing:
There is demo located in "apps/TestSram23x/".
The demo can be configured/tested for HAL/HPL and HAL/Generic version (define TEST_SRAM23X_HPL in TestSram23x.h).
The tested throughput for "-Os" (size) ~ 160kB/s, "-O3" (speed) ~ 310kB/s on AVR platform (8MHz CPU clock, 4MHz SPI).
