# What is this?
This is a baremetal ARM assembly driver on the Raspberry Pi Pico for 1602 LCD's written with an LCM1602 I2C package in mind. Most of these packages use a PCF8574T general purpose I2C expander chip (with a default I2C slave address of 0x27) in unison with a Hitachi HD44780 Liquid Crystal Display Controller, and so this project will be written with the circuit diagrams for those in mind.

As mentioned previously, this project uses baremetal assembly. Specifically, the RP2040 which uses ARM Cortex-M0+ cores, which use the ARMv6-M Instruction set. The Pico SDK will be used minimally (Only used for the stage 2 bootloader, vector table, and as a base for the linker script)

## What does this project do?
This project will go through all necessary steps to set up I2C on the Raspberry Pi Pico as well as provide functions to write to the LCD and initialize it properly.

All specific functions of this project are specified below:
- Linking Code to proper locations of RP2040 memory
- Booting the Raspberry Pi Pico and allowing it to run the second stage bootloader
- Switching to the crystal oscillator (XOSC) from the ring oscillator (ROSC) to get a more stable clock signal, then disabling the ROSC
- Disabling the subsystem resets on the I2C0 and IO_BANK0 modules
- Setting the GPIO 16 and 17 Pins to use I2C0 as their allocated function
- Setting the GPIO Pads for the GPIO 16 and 17 to be compatible with I2C this includes:
    - Enabling Pull-Up Resistor
    - Disabling Pull-Down Resistor
    - Limiting Slew Rate
    - Enabling the Schmitt Trigger
- Enable the I2C module0
    - Configure it as a master (Since the LCM1602 I2C package will be a slave)
    - Configure the correct target address (0x27)
- Write a function to write to the I2C from a value specified in the stack, sending a stop-bit after the fact and ensuring that the buffer is not full before writing to the FIFO.
- Write a function to write to the LCD1602 I2C package which needs to:
    - take an input of a full byte and 4-bit word
    - split the byte it into two 4-bit sections
    - combine it with the input 4-bits
    - enable/disable the Enable bit as necessary
    - do this for both halves of the input byte
- Write some example code in the main function to write "Hello World!" to the display

The project also checks whether every step completes properly before moving on to the next to ensure that there is no problem in-case a faster clock speed is used in the future.

# How do I use this?
Using this project is extremely simple as all build scripts are available in the makefile and only 4 pins on the pico are used.

## Build commands
In the command line, typing these commands does these things:
- `make`: will build the final fully assembled and linked elf file, it will output all assembled object files in the build_garbage folder along with a memory map created during linking.
- `make clean`: will delete the build garbage folder along with everything inside, as well as any built elf or uf2 files
- `make uf2`: will build a uf2 file that you can program the pico with using the bootloader method
- `make flash`: (NEED Pico Debugger plugged in properly) Will flash the elf file to the pico directly using the pico debugger
- `make debug`: Will open gdb and will stop at a breakpoint specified at (*\_start), this is where the main function usually resides

## Circuit Design
When connecting the Pico to the LCD1602 I2C module, simply connect GP17 to SCL, GP16 to SDA, 3v3(out) to VCC, and GND to GND.

# Readability and Documentation
Bare metal programming is complex. Documentation and Readability of code is an important factor in ensuring quick development time.

Assembly code is split into different sections and documented to make understanding the code simple.
- The code itself uses assembler tricks to ensure that readability is maintained. These assembler tricks ensure that memory savings will be the same regardless of if the code itself may not prioritize them. 

Linker Scripts are also documented as much as possible.
TODO - (Document makefile)

## Recommended Reading
- Read the raspberry pi pico RP2040 datasheet to learn what the different memory locations are if you are unsure what is going on.
- Use an ARMv6-M architecture reference manual to delve into a deep understanding of arm thumbv1.
- Use the Hitachi HD44780U datasheet to learn how the I2C module itself functions
- Use the LiquidCrystal_I2C library as a reference to see another implementation of this in C++

All of these files will be linked in the references.

# Requirements
There are two hard requirements and three optional requirements for this project based on your choice of microcontroller flashing method and/or use of debuggers.

The hard requirements are:
- gnumake
- gcc-arm-embedded

If you would like to use openocd to flash the chip, there is an optional requirement:
- openocd

Additionally, if you would like to also use a debugger and already have openocd, there is an optional requirement:
- gdb

If you would like to use the UF2 method of flashing the rpi pico, you can install:
- elf2uf2-rs

# References
[Life with david: BMA 04](https://github.com/LifeWithDavid/RaspberryPiPico-BareMetalAdventures/tree/main/Chapter%2004)

[RP2040 Datasheet](https://datasheets.raspberrypi.com/rp2040/rp2040-datasheet.pdf)

[Rpi Pico Pinout](https://www.raspberrypi.com/documentation/microcontrollers/images/pico-pinout.svg)

[Rpi Pico W Pinout](https://www.raspberrypi.com/documentation/microcontrollers/images/picow-pinout.svg)

[Rpi Pico SDK](https://github.com/raspberrypi/pico-sdk)

[LiquidCrystal_I2C](https://github.com/lucasmaziero/LiquidCrystal_I2C)

[Hitachi HD44780U Datasheet](https://cdn.sparkfun.com/assets/9/5/f/7/b/HD44780.pdf)

[ARMv6-M Architecture Reference Manual](https://documentation-service.arm.com/static/5f8ff05ef86e16515cdbf826)
