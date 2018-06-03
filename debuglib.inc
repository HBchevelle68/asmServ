
%ifndef DEBUGLIB.INC
  %define DEBUGLIB.INC


    section .data
      SOCKERR: db "ERROR --> socket creation", 0
      .len: equ $ - SOCKERR




    ;;params
    ;;will get error value off stack
    ;;
    errorSwitch:
      mov    QWORD rax, [esp+8]
      cmp    rax, -1
      je     printSockErr
      leave
      ret

    printSockErr:
      mov    rsi, SOCKERR
      call   string_length
      mov    rdx, rax
      mov    rax, 1
      mov    rdi, 1
      syscall
      ret

    ;;rdi points to string
    string_length:
      xor    rax, rax
      .loop:
      cmp    BYTE [rsi+rax], 0
      je     .end
      inc    rax
      jmp    .loop
      .end:
      ret
%endif
