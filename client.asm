global _start

extern csocket
extern csetsockopt
extern cbind
extern clisten
extern caccept
extern exit

section .data

section .bss
fd: resd 1

section .rodata


section .text

_start:
  nop
  nop
  nop
  mov rdi, 0
  call exit
