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

  

  ;; temp error label/exit
.err:
  mov    dil, al
  call   exit
