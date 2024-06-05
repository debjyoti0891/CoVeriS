.section ".text.init", "ax", @progbits

.globl _start
_start:
        # enable floating point unit
        li t0, 0x6000
        csrs mstatus, t0
        csrwi fcsr, 0
        la sp, _sstack

        jal trap_setup
        jal ra, main

        li a0, 0
        j tohost_exit

.section .data

msg_mtime:    .asciz "mtime:"
msg_c_fn:     .asciz "calling a C function from asm:"
msg_wfi:      .asciz "waiting for interrupts..."
msg_exc:      .asciz "manually invoking an exception..."

.globl msg_sep
msg_sep:      .asciz "-------------------------"
