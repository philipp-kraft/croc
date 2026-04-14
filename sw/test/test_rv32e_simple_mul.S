.section .text
.globl main

main:
    li   a0, 6
    li   a1, 7
    # mul  t0, a0, a1   # t0 = 42
    # div  t1, t0, a0

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