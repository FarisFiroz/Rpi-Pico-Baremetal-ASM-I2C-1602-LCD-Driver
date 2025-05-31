.section .reset, "ax"
.global _start
_start:

.include "src/program/clocks.s"

.include "src/program/i2c_setup.s"

// {{{ Processor Sleep 
    wfi
// }}}
