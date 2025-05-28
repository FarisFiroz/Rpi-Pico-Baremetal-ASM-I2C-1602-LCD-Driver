.section .reset, "ax"
.global _start
_start:

.include "src/program/clocks.s"

/* {{{ Reset Controller 

Initially, the peripherals on the rp2040 not required to boot are held in a reset state. We can interact with the reset controller to control this behavior.

In STEP 1, we will clear the reset on iobank_0 as this has the controls for all the gpio pins.
In STEP 2, we will check whether the reset on iobank_0 was successful, and infinite loop if not

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
    mov r6, #0b100000
    str r6, [r7]

// STEP 2
    ldr r7, =rst_done
rst:
    ldr r5, [r7]
    and r5, r6
    beq rst

// }}}

/* {{{ GPIO Control Register 

We will need to edit the GPIO Control Registers so that they are enabled and controllable by the SIO.

params:
    gpio0_ctrl: control register for gpio0
*/

.equ gpio0_ctrl, 0x40014000 + 0x4
    ldr r7, =gpio0_ctrl
    mov r6, #5
    str r6, [r7]

// }}}

/* {{{ SIO GPIO Output Enable and Set 

Now, we will enable the GPIO Output on the specified pin and then we will turn it the output on (or set it).

// STEP 1: Output Enable
// STEP 2: Output Set

params:
    sio_base: base register for SIO control
    gpio_oe: output enable register for gpio through SIO
    gpio_out_set: output set register for gpio through SIO
*/

.equ sio_base, 0xd0000000
.equ gpio_oe, sio_base + 0x20
.equ gpio_out, sio_base + 0x10

// STEP 1
    ldr r7, =gpio_oe
    mov r6, #0b1
    str r6, [r7]

// STEP 2
    ldr r7, =gpio_out
    mov r6, #0b1
    str r6, [r7]

// }}}

/* {{{ Enter Dormant state 

(Disabled for now as it is unnecessary, you can also disable clock signals manually when sleeping for processors if desired)

params:
    xosc_dormant: control register for dormant state on XOSC
*/
//.equ xosc_dormant, xosc_ctrl + 0x08
//
//    ldr r7, =xosc_dormant
//    ldr r6, =0x636f6d61
//    str r6, [r7]

/// }}}

// {{{ Processor Sleep 
    wfi

    mov r6, #0b0
    str r6, [r7]
// }}}
