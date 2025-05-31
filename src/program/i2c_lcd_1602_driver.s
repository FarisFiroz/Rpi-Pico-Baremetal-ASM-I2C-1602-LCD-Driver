/* Intro Schpiel {{{

description:

    This code contains the driver for the I2C 1602 LCD module. It follows the Hitachi HD44780 Datasheet. More info can be found in the README.
    From here on forward, the I2C 1602 LCD module will simply be referred to as the LCD.

    First, an introduction on how to use this driver. This driver consists of a series of subroutines that will handle communication with the LCD.
    Currently, all logic will take place on the CPU and will simply be written over I2C using the i2c_data_cmd register.

}}} */

/* {{{ Unused Delay Function
delay:
    ldr r5, =0x10000
delay2:
    sub r5, #1
    bne delay2

    bx lr
}}} */ 

/* Write Function {{{ 

description:
    This function will write a value to the i2c_data_cmd buffer. It will also check whether the function is globally available to use.

prerequisites:
    The i2c0 must be completely set-up and ready in order to use this function.

equates:
    i2c0_data_cmd: Holds the register that will hold data to write to the LCD

stack map:
----------------------------------
| Byte of data to write over i2c |
----------------------------------
| Link Register Value            |
----------------------------------

*/

.equ i2c0_data_cmd, 0x40044000+0x10

i2c_write:
    ldr r7, =i2c0_data_cmd // Load the correct memory location into our writing register

    pop {r6} // byte of data to write to the LCD

    mov r0, #1
    lsl r0, #9 
    add r6, r0 // Send stop bit after transmission

i2c_write_check:
    ldr r5, [r7, #0x60] // Load data from i2c status register
    mov r0, #0b10 // Bit in i2c status register that shows if tx fifo is full or not
    and r5, r0 // Check if bit 2 of the i2c status register is set. If so, then the fifo is not full
    beq i2c_write_check // If bit 2 of the i2c status register is not set, then the fifo is full. In which case, loop and check again.

    str r6, [r7] // Write to LCD
    bx lr // Return from subroutine

// }}}

/* Init Function {{{

description:
    This function will initialize the LCD according to the datasheet. 
    It will initialize the LCD in 4-bit, 1 display line, with a 5x8 character font.

params: N/A
*/

.global lcd_init
lcd_init:
    mov r0, #0
    push {r0, lr}
    bl i2c_write
    pop {pc}

// }}}
