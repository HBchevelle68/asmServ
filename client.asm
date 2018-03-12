global _start

extern csocket
extern csetsockopt
extern cbind
extern clisten
extern caccept
extern exit
extern cconnect

section .data

section .bss
fd: resd 1

section .rodata


section .text

_start:
  nop
  nop
  nop
  nop

  call csocket
  test ax, ax
  js   .err
  mov  [fd], ax


  mov  rdi, [fd]
  mov  rsi, 0xE110
  mov  rdx, 0x0100007f
  call cconnect
  test ax, ax
  js   .err

.err:
  mov  dil, al
  call exit
