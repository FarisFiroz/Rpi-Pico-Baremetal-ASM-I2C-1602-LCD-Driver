.section .reset, "ax"
.global _start
_start:

.include "src/includes/clocks.s"
.include "src/includes/i2c_setup.s"

.global main
main:
    bl lcd_init

    mov r1, #0b1001

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

    mov r0, #' '
    bl lcd_write

    mov r0, #'w'
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

