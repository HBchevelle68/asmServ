global csocket
global csetsockopt
global cbind
global clisten
global caccept
global exit
global cconnect

section .data

section .bss


section .rodata
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

;; params:
;; rdi -> socker fd
;; on ret rax will contain fd || -1 if error
caccept:
  mov rax, 43
  xor rsi, rsi
  xor rdx, rdx
  syscall

;; params:
;; rdi -> socket fd
;; rsi -> port number in reverse byte order
;;       (port 4321 = 0x10E1, in reverse byte order = 0xE110)
;; rdx -> IP addr in reverse byte order
;; on ret rax will contain 0 || -1 if error
cconnect:
  mov rbp, rsp
  push QWORD 0
  push rdx
  push rsi
  push WORD AF_INET


  mov rax, 42
  ;; rdi
  mov rsi, rsp
  mov rdx, 16
  syscall
  mov rsp, rbp
  ret

;; params:
;; rdi -> socker fd
;; on ret rax will contain fd || -1 if error
exit:
  mov rax, 60
  syscall
