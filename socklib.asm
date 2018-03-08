section .data

section .bss

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
  mov rax, rdi
  mov rdi, SOL_SOCKET
  mov rsi, SO_REUSEADDR
  mov r10, DWORD [r8]
  mov r8, 4
  syscall
  ret

;; params:
;; rdi -> socket fd
;; rsi -> port number in reverse byte order
;; on ret rax will contain 0 || -1 if error
cbind:
  mov rbp, rsp
  mov rax, rdi ;;move passed fd

  ;; Build struct sockaddr_in
  push DWORD INADDR_ANY
  push WORD rsi
  push WORD AF_INET
  mov rdi, rsp

  mov rsi, 16
  syscall
  mov rsp, rbp
  ret

;; params:
;; rdi -> socket fd
;; on ret rax will contain 0 || -1 if error
clisten:
  mov rax, rdi
  mov rdi, 5
  syscall
  ret

caccept:
  mov rax, rdi
  mov rdi, 0
