global _start

extern csocket
extern csetsockopt
extern cbind
extern clisten
extern caccept
extern exit
extern cwrite
extern cread
extern close

section .data
;; Nothing currently, possible use later
  buffer: times 100 db 0
  .len: equ $- buffer
section .bss
  sfd:    resd 1
  tfd:    resd 1

section .rodata
;; Nothing currently, possible use later

section .text

_start:
  nop
  nop
  nop

  ;; create socket
  call    csocket
  test    ax, ax
  js      .err
  mov     [sfd], ax

  ;; set socket opts
  mov     rdi, [sfd]
  call    csetsockopt
  test    ax, ax
  js     .err

  ;; bind to addr space
  mov    rdi, [sfd]
  mov    rsi, 0xE110
  call   cbind
  test   ax, ax
  js     .err

  ;; begin listen
  mov    rdi, [sfd]
  call   clisten
  test   ax, ax
  js     .err

  ;; accept connections
  mov    rdi, [sfd]
  call   caccept
  test   ax, ax
  js     .err
  mov    [tfd], rax

  mov    rdi, [tfd]
  mov    rsi, buffer
  mov    rdx, buffer.len
  call   cread
  test   ax, ax
  js     .err

  ;; test print
  mov    rdi, 1
  mov    rsi, buffer
  mov    rdx, buffer.len
  call   cwrite
  test   ax, ax
  js     .err

  ;; temp error label/exit
.err:
  mov    r10, rax
  mov    rdi, [tfd]
  call   close
  mov    rdi, [sfd]
  call   close
  call   exit
