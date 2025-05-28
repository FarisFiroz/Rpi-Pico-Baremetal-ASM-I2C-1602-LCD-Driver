/* {{{ Crystal Oscillator Switch 
By default, the rpi pico uses the ring oscillator, which is fine, but we can use the crystal oscillator for a more accurate clock.

STEP 1: We will set the startup delay for the crystal oscillator
STEP 2: We will enable the crystal oscillator and define the use of the 12MHz crystal
STEP 3: We need to wait for the crystal oscillator to start up. We will check if the stable bit in the status register for the xosc is set. Looping if not.
STEP 4: Finally, we can switch from the ROSC to the XOSC. We do this by glitchless swapping the reference clock to use the XOSC. Since the reference clock is the default clock for the system clock, this means that the system clock will also use the XOSC.
STEP 5: Keep checking to ensure that the XOSC is swapped to

params:
    xosc_ctrl: Control register for the crystal oscillator. (Is also the base for xosc)
    xosc_startup: Register for xosc that handles the startup delay
    clk_ref_ctrl: Control register for the reference clock (the system clock uses the reference clock as a default)
*/

.equ xosc_ctrl, 0x40024000 
.equ xosc_startup, xosc_ctrl + 0xc
.equ clk_ref_ctrl, 0x40008000 + 0x30

// STEP 1
    ldr r7, =xosc_startup
    mov r6, #47
    str r6, [r7]

// STEP 2
    ldr r7, =xosc_ctrl
    ldr r6, =(0xfab<<12 + 0xaa0)
    str r6, [r7]

// STEP 3
xosc_rdy:
    ldr r6, [r7, #0x4]
    lsr r6, #31
    beq xosc_rdy

// STEP 4
    ldr r7, =clk_ref_ctrl
    mov r6, #0x2
    str r6, [r7]

// STEP 5 (Not Implemented)

// }}}

/* {{{ Ring Oscillator Stop 

I want to disable to ring oscillator as it is no longer needed. We will be using the XOSC for now.

params:
    rosc_ctrl: Control register for the ring oscillator.
*/

.equ rosc_ctrl, 0x40060000 

    ldr r7, =rosc_ctrl
    ldr r6, =(0xd1e<<12 + 0xaa0)
    str r6, [r7]

// }}}
