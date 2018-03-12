global _start

extern csocket
extern csetsockopt
extern cbind
extern clisten
extern caccept
extern exit


section .data

section .bss
  fd:    resd 1

section .rodata

section .text

_start:
  nop
  nop
  nop
  nop

  call    csocket
  test    ax, ax
  js      .err
  mov     [fd], ax

  mov     rdi, [fd]
  call    csetsockopt
  test    ax, ax
  js     .err

  mov    rdi, [fd]
  mov    rsi, 0xE110
  call   cbind
  test   ax, ax
  js     .err

  mov    rdi, [fd]
  call   clisten
  test   ax, ax
  js     .err

  mov    rdi, [fd]
  call   caccept
  test   ax, ax
  js     .err

.err:
  mov    dil, al
  call   exit
