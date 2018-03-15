global _start

extern csocket
extern csetsockopt
extern cbind
extern clisten
extern caccept
extern exit

section .data
;; Nothing currently, possible use later

section .bss
  sfd:    resd 1

section .rodata
;; Nothing currently, possible use later

section .text

_start:
  nop
  nop
  nop

  call    csocket
  test    ax, ax
  js      .err
  mov     [sfd], ax

  mov     rdi, [sfd]
  call    csetsockopt
  test    ax, ax
  js     .err

  mov    rdi, [sfd]
  mov    rsi, 0xE110
  call   cbind
  test   ax, ax
  js     .err

  mov    rdi, [sfd]
  call   clisten
  test   ax, ax
  js     .err

  mov    rdi, [sfd]
  call   caccept
  test   ax, ax
  js     .err

.err:
  mov    dil, al
  call   exit
