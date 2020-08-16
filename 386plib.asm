;░▒▓█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█▓▒░
;░▒▓█                 A i386(R) protected mode library                    █▓▒░
;░▒▓█               (C)opyright 1993 by FRIENDS software                  █▓▒░
;░▒▓█                    Protected-mode use routines                      █▓▒░
;░▒▓█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█▓▒░

;*****************************************************************************
;                    Change hardware interrupt vectors
; In: BL = Starting int no for int. controller #1
;     BH = Starting int no for int. controller #2
;*****************************************************************************
SetPIC          proc    near
                mov     al,011h
                out     020h,al
                out     0A0h,al
                SettleBus
                mov     al,bl
                out     021h,al
                mov     al,bh
                out     0A1h,al
                SettleBus
                mov     al,004h
                out     021h,al
                mov     al,002h
                out     0A1h,al
                SettleBus
                mov     al,001h
                out     021h,al
                out     0A1h,al
                SettleBus
                mov     al,0FFh
                out     021h,al
                out     0A1h,al
                ret
SetPIC          endp

;*****************************************************************************
;                            Restore real mode
;*****************************************************************************
Back2DOS        proc    near
                mov     bl,al
                cli
                mov     ax,@gdData
                mov     ds,ax
                mov     es,ax
                mov     fs,ax                   ;Clear segment
                mov     gs,ax                   ;registers cache
                xor     eax,eax
                mov     dr7,eax                 ;Turn off debug
                mov     eax,cr0
                and     eax,7FFFFFF2h           ;Turn off paging,PM etc.
                mov     cr0,eax                 ;Back to real mode
                db      0EAh                    ;Clear prefetch & set CS
                dw      $+4,1234h
PatchCS1        equ     word ptr $-2
                mov     ax,cs                   ;Set segment
                mov     ds,ax                   ;registers to CS
                mov     es,ax
                mov     gs,ax
                mov     fs,ax
                lss     esp,fword ptr RMESP
                lidt    SavedIDT
                mov     bx,7008h
                call    SetPIC
                mov     al,36h                  ;Restore IRQ0 frequence
                out     43h,al
                SettleBus
                mov     al,0
                out     40h,al
                SettleBus
                out     40h,al
                SettleBus
                sti
                mov     al,cs:IntMask1
                out     021h,al
                mov     al,cs:IntMask2
                out     0A1h,al
                mov     al,bl
                mov     ah,04Ch
                int     21h
                endp

Output          proc    near
;*****************************************************************************
;                    Character and digit output routines
;*************************** Print longword in eax ***************************
HexOut4         label   near
                push    eax
                shr     eax,16
                call    HexOut2
                pop     eax
;***************************** Print word in ax ******************************
HexOut2         label   near
                push    ax
                mov     al,ah
                call    HexOut
                pop     ax
; print a hex byte in al
HexOut          label   near
                aam     16
                add     ax,'00'
                push    ax
                mov     al,ah
                call    HexDig
                pop     ax
HexDig:         cmp     al,'9'
                jbe     OutChar
                add     al,'A'-'0'-10
OutChar         label   near
                push    di
                push    ax
                push    ds
                push    es
                push    cx
                mov     cx,@gdVideo
                mov     es,cx
                mov     cx,@gdData
                mov     ds,cx
                pop     cx
                mov     ah,Color
                mov     di,Cursor
                cmp     al,0Dh
                je      CR
                cmp     al,0Ah
                je      LF
; write to screen
                shl     di,1
                mov     es:[di],AX
                shr     di,1
                inc     di
                jmp     OuChD
CR:             push    dx
                push    cx
                mov     ax,di
                xor     dx,dx
                mov     cx,80
                div     cx
                sub     di,dx
                pop     cx
                pop     dx
                jmp     OuChD
LF:             add     di,80
OuChD:          cmp     di,80*25                ; rolling off the screen?
                jb      NoScroll
; scroll screen if required
                push    ds
                push    es
                pop     ds
                push    si
                push    cx
                push    di
                cld
                mov     cx,80*24
                xor     di,di
                mov     si,160
                rep     movsw
                push    ax
                mov     al,' '
                mov     ah,cs:Color
                mov     cx,80
                rep     stosw
                pop     ax
                pop     di
                sub     di,80
                pop     cx
                pop     si
                pop     ds
NoScroll:       mov     Cursor,di               ; update cursor
                push    dx
                mov     dx,@gdFlat
                mov     ds,dx
                mov     dx,word ptr ds:[463h]
                mov     ax,di
                mov     al,14
                out     dx,ax
                mov     ax,di
                mov     ah,al
                mov     al,15
                out     dx,ax

                mov     ax,di
                mov     di,80
                xor     dx,dx
                div     di
                mov     byte ptr ds:[450h],dl
                mov     byte ptr ds:[451h],al

                pop     dx
                pop     es
                pop     ds
                pop     ax
                pop     di
                ret
                endp

CRLF            proc    near
                mov     al,13
                call    OutChar
                mov     al,10
                jmp     OutChar
                endp

WriteMSG        proc    near
                mov     al,[bx]
                or      al,al
                je      @@WM_End
                call    OutChar
                inc     bx
                jmp     WriteMsg
@@WM_End:       ret
                endp
