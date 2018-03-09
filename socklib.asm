global _start
section .data

section .bss
fd: resd 1
section .rodata
  ;;Socket calls
  SYS_SOCKET:      equ 1
  SYS_BIND:        equ 2
  SYS_LISTEN:      equ 4
  SYS_ACCEPT:      equ 5
  SYS_SEND:        equ 9
  SYS_RECV:        equ 10
  SYS_SETSOCKOPT:  equ 14
  ;;Domains/Family
  AF_INET:         equ 2
  ;;Types
  SOCK_STREAM:     equ 1
  ;;Protocols
  IPPROTO_IP:      equ 0
  ;;Socket options
  SOL_SOCKET:      equ 1
  SO_REUSEADDR:    equ 2
  ;;Addresses
  INADDR_ANY:      equ 0

section .text

;; no params passed
;; on ret rax will contain fd || -1 if error
csocket:
  mov rax, 41
  mov rdi, AF_INET
  mov rsi, SOCK_STREAM
  mov rdx, IPPROTO_IP
  syscall
  ret

;; params:
;; rdi -> socket fd
;; on ret rax will contain 0 || -1 if error
csetsockopt:
  mov rax, 54
  mov rsi, SOL_SOCKET
  mov rdx, SO_REUSEADDR
  mov r8, 4
  push QWORD 4
  mov r10, rsp

  syscall
  add rsp, 8
  ret

;; params:
;; rdi -> socket fd
;; rsi -> port number in reverse byte order
;;       (port 4321 = 0x10E1, in reverse byte order = 0xE110)
;; on ret rax will contain 0 || -1 if error
cbind:
  mov rbp, rsp
  mov rax, 49
  ;;rdi
  ;; Build struct sockaddr_in
  push DWORD INADDR_ANY
  push WORD si
  push WORD AF_INET
  mov rsi, rsp

  mov rdx, 16
  syscall
  mov rsp, rbp
  ret

;; params:
;; rdi -> socket fd
;; on ret rax will contain 0 || -1 if error
clisten:
  mov rax, 50
  ;;rdi
  mov rsi, 5
  syscall
  ret

;; no params passed
;; rdi -> socker fd
;; on ret rax will contain fd || -1 if error
caccept:
  mov rax, 43
  push QWORD 0
  mov rdi, rsp
  push QWORD 0
  mov rsi, rsp
  syscall

exit:
  mov rax, 60
  syscall

_start:
  nop
  nop
  nop
  nop

  call csocket
  test ax, ax
  js .err
  mov [fd], ax

  mov rdi, [fd]
  call csetsockopt
  test ax, ax
  js .err

  mov rdi, [fd]
  mov rsi, 0xE110
  call cbind
  test ax, ax
  js .err

  mov rdi, [fd]
  call clisten
  test ax, ax
  js .err

  mov rdi, [fd]
  call caccept
  test ax, ax
  js .err

.err:
  mov dil, al
  call exit
