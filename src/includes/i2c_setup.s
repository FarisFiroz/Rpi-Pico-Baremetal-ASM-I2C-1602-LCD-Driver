/* {{{ Reset Controller 

Initially, the peripherals on the rp2040 not required to boot are held in a reset state. We can interact with the reset controller to control this behavior.

In STEP 1, we will clear the reset on IO_BANK0 and I2C0
In STEP 2, we will check whether the reset on IO_BANK0 and I2C0 was successful, and infinite loop if not


params:
    rst_base: base register for clearing reset controller
    rst_clr: atomic register for clearing reset controller
    rst_done: register to check for successful reset done
*/

.equ rst_base, 0x4000c000
.equ rst_clr, rst_base + 0x3000 
.equ rst_done, rst_base + 0x8

// STEP 1
    ldr r7, =rst_clr
    mov r6, #0b101000
    str r6, [r7]

// STEP 2
    ldr r7, =rst_done
rst:
    ldr r5, [r7]
    and r5, r6
    beq rst

// }}}

/* {{{ GPIO Control Register 

We will need to edit the GPIO Control Registers for GPIO16 and GPIO17 so that it is enabled and controllable by I2C0.

Pin Layout:
    GPIO 16: I2C0 SDA
    GPIO 17: I2C0 SCL

params:
    gpio16_ctrl: control register for gpio16
    gpio17_ctrl_offset: control register for gpio17, offset from gpio_16_crtl
    fncsel: function to select for gpios
*/
.equ fncsel, 3

.equ gpio16_ctrl, 0x40014000 + 0x84
.equ gpio17_ctrl_offset, 0x8

    ldr r7, =gpio16_ctrl
    mov r6, #fncsel

    str r6, [r7]
    str r6, [r7, #gpio17_ctrl_offset]
// }}}

/* {{{ GPIO Pad Control

We will need to edit the GPIO Pads to be configured for pull-up enabled, slew rate limited, and schmitt trigger enabled.

params:
    gpio16_pad_ctrl: pad control register for gpio16
    gpio17_pad_ctrl: pad control register for gpio17, offset from gpio16_pad_ctrl
    pad_ctrl_val: write value for pad control register
*/
.equ pad_ctrl_val, 0b01001010

.equ gpio16_pad_ctrl, 0x4001c000 + 0x44
.equ gpio17_pad_ctrl_offset, 0x4

    ldr r7, =gpio16_pad_ctrl
    mov r6, #pad_ctrl_val

    str r6, [r7]
    str r6, [r7, #gpio17_pad_ctrl_offset]
// }}}

/* {{{ I2C Initial Configuration

This section will have the code for the initial configuration steps of I2C0 as a master.

Step 0: Load i2c0_base into register 7, we will offset from this value for mem locations to write to.
STEP 1: Disable i2c0, so we can modify the code. (Not done here since i2c0 should already be disabled)
STEP 2: Wait for i2c0 to be disabled
STEP 3: Use the i2c0 control register to set standard speed, 7-bit addressing for the master (not necessary since already 7-bit by default), and disable slave bit and enable master bit (not necessary since already the default)
STEP 4: Write the address of the I2C device to be adressed to the i2c0 target register
STEP 5: Enable I2C0
STEP 6: Wait for I2C0 to be enabled
STEP 7: Jump to main function

I2C Addresses:
    The I2C address for the 1602 LCD Module is 0x27

params:
    i2c0_base: base address for the i2c0 registers
    i2c_enable_offset: offset for the enable register for i2c, which can be used to enable the i2c.
    i2c_enable_status: status of the enable for i2c, which will be used to ensure the i2c is enabled or disabled as expected
    i2c_con_offset: offset for the control register of i2c registers
    i2c_tar_offset: offset for the target register which holds the address of the i2c device to be addressed.

dynamic params:
    x_write_val: write value for the register of x type (correlates to the register specified by x_offset)
*/

.equ i2c0_base, 0x40044000

.equ i2c_enable_status, i2c0_base + 0x9c

.equ i2c_enable_offset, 0x6c
.equ i2c_enable_write_val, 0b001

.equ i2c_con_offset, 0x00
.equ i2c_con_write_val, 0b0001100011

.equ i2c_tar_offset, 0x04
.equ i2c_tar_write_val, (0x00<<10) + 0x27

// STEP 0
    ldr r7, =i2c0_base

// STEP 1
    mov r6, #0
    str r6, [r7, #i2c_enable_offset]

// STEP 2
    ldr r7, =i2c_enable_status
i2c_enable_off:
    ldr r5, [r7]
    cmp r5, r6
    bhi i2c_enable_off
    ldr r7, =i2c0_base

// STEP 3
    ldr r6, =i2c_con_write_val
    str r6, [r7, #i2c_con_offset]

// STEP 4
    ldr r6, =i2c_tar_write_val
    str r6, [r7, #i2c_tar_offset]

// STEP 5
    ldr r7, =i2c0_base
    ldr r6, =i2c_enable_write_val
    str r6, [r7, #i2c_enable_offset]

// STEP 6
    ldr r7, =i2c_enable_status
i2c_enable_on:
    ldr r5, [r7]
    cmp r5, r6
    bhi i2c_enable_on
// }}}
