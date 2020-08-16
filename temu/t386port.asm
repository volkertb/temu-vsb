;░▒▓█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█▓▒░
;░▒▓█         Disney Sound Source emulator for Covox & PC-Squeaker        █▓▒░
;░▒▓█                (C)opyleft 1993 by FRIENDS software                  █▓▒░
;░▒▓█                          Port handler                               █▓▒░
;░▒▓█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█▓▒░


PortHandler     proc    near
                cmp     ah,0EEh
                je      OutDX_AL
                cmp     ah,0E6h
                je      Out@@_AL
                cmp     ah,0ECh
                je      InAL_DX
                cmp     ah,0E4h
                je      InAL_@@
                jmp     TooBad

OutDX_AL:       push    dx
CheckPort:      cbw
                add     [ebp],ax
                mov     al,byte ptr [ebp-4]
                cmp     dx,0378h
                je      @@DSSport
                ja      @@AllRight
                cmp     dx,0C0h
                jae     @@TandyPort
                cmp     dx,43h
                je      @@Timer_Control
                cmp     dx,40h
                je      @@Timer_Ch0
                jmp     @@AllRight

@@DSSport:      xor     al,80h
                sar     al,1
                mov     bx,ss:BuffEnd           ; Put byte into queue
                mov     ss:DSSbuffer[bx],al
                inc     bx
                and     bx,DSSbufferMask
                cmp     bx,ss:BuffStart
                je      @@AllRight
                mov     ss:BuffEnd,bx

@@AllRight:     pop     dx
                pop     ebp
                pop     ds
                pop     ebx
                pop     eax
                iretd

@@TandyPort:    call    OutC0_AL
                jmp     @@AllRight

@@Timer_Control:test    dl,11000000b
                jne     @@NoCh0
                mov     ss:FlipFlop,0
                jmp     @@AllRight
@@NoCh0:        out     dx,al
                jmp     @@AllRight

@@Timer_Ch0:    movzx   bx,cs:FlipFlop
                inc     ss:FlipFlop
                mov     byte ptr ss:IRQ0Freq[bx],al
                and     ss:FlipFlop,1
                jne     @@AllRight
                mov     ax,cs:IRQ0Freq
                call    SetVirtualIRQ
                mov     ax,cs:TimerFreq
                call    SetTimerFreq
                jmp     @@AllRight

Out@@_AL:       push    dx
                movzx   dx,byte ptr [ebx]
                inc     al
                jmp     CheckPort

InAL_DX:        push    dx
ReadPort:       cbw
                add     [ebp],ax
                cmp     dx,379h
                jne     DirectRead
                mov     al,byte ptr cs:BuffEnd
                sub     al,byte ptr cs:BuffStart
                and     al,DSSBufferMask
                cmp     al,16
                jae     @@Full
                mov     byte ptr [ebp-4],0
                jmp     @@AllRight
@@Full:         mov     byte ptr [ebp-4],40h
                jmp     @@AllRight

DirectRead:     in      al,dx
                mov     byte ptr [ebp-4],al
                jmp     @@AllRight

InAL_@@:        push    dx
                inc     al
                movzx   dx,byte ptr [ebx]
                jmp     ReadPort

TooBad:
PortHandler     endp
