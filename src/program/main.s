.section .reset, "ax"
.global _start
_start:

.include "src/program/clocks.s"

.include "src/program/i2c_setup.s"

// {{{ Processor Sleep 
    wfi
// }}}

/* {{{ Unused Delay Function
delay:
    ldr r5, =0x10000
delay2:
    sub r5, #1
    bne delay2

    bx lr
}}} */ 
