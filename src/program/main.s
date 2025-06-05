.section .reset, "ax"
.global _start
_start:

.include "src/includes/clocks.s"
.include "src/includes/i2c_setup.s"

.global main
main:
    mov r1, #0b1000
    bl lcd_init

    add r1, #0b1

    mov r0, #'H'
    bl lcd_write
    mov r0, #'e'
    bl lcd_write
    mov r0, #'l'
    bl lcd_write
    mov r0, #'l'
    bl lcd_write
    mov r0, #'o'
    bl lcd_write

    sub r1, #0b1
    mov r0, #0b1000<<4 + 0b1010
    bl lcd_write
    add r1, #0b1

    mov r0, #'W'
    bl lcd_write
    mov r0, #'o'
    bl lcd_write
    mov r0, #'r'
    bl lcd_write
    mov r0, #'l'
    bl lcd_write
    mov r0, #'d'
    bl lcd_write

    mov r0, #'!'
    bl lcd_write

    wfi

