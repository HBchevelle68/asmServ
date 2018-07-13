global _start

section .data

section .bss
  ipPtr  resq  1
  ipInt  resd  1

section .text

_start:

  mov     rsi, [rsp+16] ;; *argv[1]
  mov     QWORD [ipPtr], rsi


;; Convert IP cmd arg to int
;; rsi -> pointer to the string to convert
;; ipInt var contains net byte order ip addr by end
ipstring_to_int:
  xor    rbx, rbx    ; clear rbx

.next_octet:

  movzx  eax, BYTE [rsi]
  inc    rsi
  sub    al, '0'    ;; convert from ASCII to number
  imul   ebx, 10    ;; unsigned multiply by 10
  add    ebx, eax   ;; ebx = ebx*10 + eax
  cmp    BYTE [rsi], '.'  ;; check for octet delim
  je     .update
  cmp    BYTE [rsi], 0  ;; check for end of str
  je     .update
  jmp    .next_octet

  .update:
  mov    eax, ebx     ;; mov result into eax
  mov    edi, [ipInt] ;; get ip var
  cmp    edi, 0       ;; if edi (ipInt) == 0, then no rotate
  je     .iter1
  ror    edi, 8       ;; rotate right by $r8d bits

  .iter1:
  or     BYTE dil, al ;; update ip var
  mov    DWORD [ipInt], edi
  cmp    BYTE [rsi], 0 ;; test for end of str
  je     .done
  inc    rsi  ;; inc rsi to mov past '.'
  jmp    ipstring_to_int

  .done:
  ror    edi, 8  ;; alst rotate right by $r8d bits
  mov    DWORD [ipInt], edi ;; final ip var update
  ret
