global _start
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
fopen:
  mov rax, 2
  ;; rdi
  mov rsi, O_CREAT
  xor rdx, rdx
  syscall
  ret


;; Here to supress entry warning
_start:
  nop
  nop
