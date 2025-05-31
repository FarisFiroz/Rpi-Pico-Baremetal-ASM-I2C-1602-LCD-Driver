.section .reset, "ax"
.global _start
_start:

.include "src/includes/clocks.s"
.include "src/includes/i2c_setup.s"

.global main
main:
    bl lcd_init
    wfi

