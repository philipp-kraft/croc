.section .text
.globl main

main:
    la   t0, target
    addi t0, t0, -4
    jalr x5, t0, 4      # jump to target, write PC+4 into x5
    nop
    nop
    nop
    nop
target:
    nop
    nop
    nop

    # switch to RV32E reliable
    addi a0, x0, 1      # rv32e
    addi a1, x0, 1      # reliability on
    addi sp, sp, -4
    sw   ra, 0(sp)
    call core_mode_switch
    lw   ra, 0(sp)
    addi sp, sp, 4
    
    # random instructions for debugging
    li t0, 0xDEADBEEE
    addi x13, t0, 1

    # return 0
    li a0, 0
    ret