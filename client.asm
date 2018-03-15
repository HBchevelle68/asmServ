global _start

extern csocket
extern csetsockopt
extern cbind
extern clisten
extern caccept
extern exit
extern cconnect

section .data
;; Nothing currently, possible use later

section .bss
fd: resd 1

section .rodata
;; Nothing currently, possible use later

section .text

_start:
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
