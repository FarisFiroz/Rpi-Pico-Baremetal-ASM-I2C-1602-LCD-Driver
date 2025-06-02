/* Intro Schpiel {{{

description:

    This code contains the driver for the I2C 1602 LCD module. It follows the Hitachi HD44780 Datasheet. More info can be found in the README.
    From here on forward, the I2C 1602 LCD module will simply be referred to as the LCD.

    First, an introduction on how to use this driver. This driver consists of a series of subroutines that will handle communication with the LCD.
    Currently, all logic will take place on the CPU and will simply be written over I2C using the i2c_data_cmd register.

}}} */

// {{{ Delay Function
delay:
    ldr r5, =0x15000
delay2:
    sub r5, #1
    bne delay2

    bx lr
// }}}

/* I2C Write Function {{{ 

description:
    This function will write a value to the i2c_data_cmd buffer. It will also check whether the function is globally available to use.

prerequisites:
    The i2c0 must be completely set-up and ready in order to use this function.

equates:
    i2c0_data_cmd: Holds the register that will hold data to write to the LCD

stack map:
-----------------------------------------
| HEAD | Byte of data to write over i2c |
-----------------------------------------

register ignore:
    This should actively never touch or use registers r0 and r1

registers modified:
    r4, r5, r6, r7

*/

.equ i2c0_data_cmd, 0x40044000+0x10

i2c_write:
    ldr r7, =i2c0_data_cmd // Load the correct memory location into our writing register

    pop {r6} // byte of data to write to the LCD

    mov r5, #1
    lsl r5, #9 
    add r6, r5 // Send stop bit after transmission

i2c_write_check:
    ldr r5, [r7, #0x60] // Load data from i2c status register
    mov r4, #0b10 // Bit in i2c status register that shows if tx fifo is full or not
    and r5, r4 // Check if bit 2 of the i2c status register is set. If so, then the fifo is not full
    beq i2c_write_check // If bit 2 of the i2c status register is not set, then the fifo is full. In which case, loop and check again.

    str r6, [r7] // Write to LCD
    bx lr // Return from subroutine

// }}}

/* LCD Write Function {{{ 

description:
    This function takes an input of a data byte to send to the LCD, splits it into two 4-byte sections (as we will use 4-bit mode), and then appends 4 more bytes to each section for the final 3 pins and backlight.

register params:
    r0: Holds the entire data byte that will be sent to the LCD
    r1: Holds the 

registers modified:
    r2, r7

*/

.global lcd_write
lcd_write:
    push {lr}
    mov r2, #2

lcd_write_p1:
    // HIGH BITS (!EN)
    mov r7, #0xf0
    and r7, r0
    add r7, r1
    push {r7}
    bl i2c_write
    // HIGH BITS (EN)
    mov r7, #0xf0
    and r7, r0
    add r7, r1
    add r7, #0b0100
    push {r7}
    bl i2c_write
    // HIGH BITS (!EN)
    mov r7, #0xf0
    and r7, r0
    add r7, r1
    push {r7}
    bl i2c_write

    lsl r0, #4
    sub r2, #1
    bhi lcd_write_p1

    pop {pc}

// }}}

/* Init Function {{{

description:
    This function will initialize the LCD according to the datasheet. 
    It will initialize the LCD in 4-bit, 1 display line, with a 5x8 character font.

params: N/A
*/

.global lcd_init
lcd_init:
    push {lr}

    mov r1, #0b1000

// STEP 1
    mov r2, #4
    mov r0, #0b0011<<4
init_part_1:
    // Change to 8 bit mode
    add r0, r1
    // HIGH BITS (!EN)
    push {r0}
    bl i2c_write
    // HIGH BITS (EN)
    add r0, #0b0100
    push {r0}
    sub r0, #0b0100
    bl i2c_write
    // HIGH BITS (!EN)
    push {r0}
    bl i2c_write
    sub r2, #1
    bhi init_part_1

    sub r0, r1
    cmp r0, #0b0010<<4
    bls init_part_2
    // Change to 4 bit mode
    mov r2, #1
    mov r0, #0b0010<<4
    b init_part_1

init_part_2:
    mov r0, #0b00000001
    bl lcd_write

    mov r0, #0b00000010
    bl lcd_write

    mov r0, #0b00001110
    bl lcd_write

    pop {pc}

// }}}
