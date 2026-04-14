.section .text
.globl main

main:
    li t0, 0xDEADBEEF
    sw   t0, -4(sp)
    lw   t1, -4(sp)

    # switch to RV32E reliable
    addi a0, x0, 1      # rv32e
    addi a1, x0, 1      # reliability on
    addi sp, sp, -4
    sw   ra, 0(sp)
    call core_mode_switch
    lw   ra, 0(sp)
    addi sp, sp, 4

    # return 0
    li a0, 0
    ret