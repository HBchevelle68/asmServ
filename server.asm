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
extern filestatus

section .data
  buffer: times 100 db 0
  .len: equ $- buffer

section .bss
  sfd:    resd 1 ;;Server socket file desc
  tfd:    resd 1 ;;Temp socket file desc
  var:    resd 1
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

  ;; recv
  mov    rdi, [tfd]
  mov    rsi, buffer
  mov    rdx, buffer.len
  call   cread
  test   ax, ax
  js     .err
  ;;Need to make sure null terminated string
  mov [var], rax ;; save num bytes
  mov [buffer+rax], BYTE 0x0

  ;;check for file
  mov    rdi, buffer
  call   filestatus
  test   al, al
  jnz    .err

  ;; test print
  mov    rdi, 1
  mov    rsi, buffer
  mov    rdx, [var] ;; print number of bytes recv'd
  call   cwrite
  test   ax, ax
  js     .err

  ;; temp error label/exit
.err:
  mov    r10, rax
  mov    rdi, [tfd]
  call   close
  mov    rdi, [sfd]
  mov    rax, r10
  call   close
  call   exit
