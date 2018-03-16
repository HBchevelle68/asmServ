global fopen
global close
global write

section .data
;; Nothing currently, possible use later
section .bss
;; Nothing currently, possible use later

section .rodata
  ;modes
  O_RDONLY:       equ 0        ;read-only
  O_WRONLY:       equ 1        ;wirte-only
  O_RDWR:         equ 2        ;read and write

  ;flags
  O_CREAT:        equ 100o     ;create file if file doesnt exists
  O_TRUNC:        equ 1000o    ;truncate file
  O_APPEND:       equ 2000o    ;append to file

  SEEK_SET:	      equ 0	       ;set file offset to offset
  SEEK_CUR:	      equ 1	       ;set file offset to current plus offset
  SEEK_END:       equ	2	       ;set file offset to EOF plus offset

section .text
;; params:
;; rdi -> filename/filepath
;; on ret, rax will contain fd || -1 if error
fopen:
  mov rax, 2
  ;; rdi
  mov rsi, O_CREAT | O_TRUNC | O_RDWR
  mov rdx, 0666o
  syscall
  ret

;; params:
;; rdi -> fd of file to close
;; on ret, rax will contain 0 || -1 if error
close:
  mov rax, 3
  ;; rdi
  syscall
  ret

;; sys_pwrite64
;; params:
;; rdi -> fd of file
;; rsi -> buffer
;; rdx -> buffer size
;; r10 -> offset
;; on ret, rax will contain # bytes written to buffer || -1 on error
write:
  mov rax, 18
  ;; rdi
  ;; rsi
  ;; rdx
  ;; r10
  syscall
  ret
