;░▒▓█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█▓▒░
;░▒▓█                 A i386(R) protected mode library                    █▓▒░
;░▒▓█               (C)opyright 1993 by FRIENDS software                  █▓▒░
;░▒▓█                     Real-mode use routines                          █▓▒░
;░▒▓█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█▓▒░

;*****************************************************************************
; Routine to control A20 line; AL=1 to turn A20 on (enable) or 0 to disable.
; Returns ZF=1 if error
;*****************************************************************************
SetA20          proc    near
                push    ax
                mov     ax,4300h                ; XMS driver detection
                int     2Fh
                cmp     al,80h
                jne     @@NoXMSdriver

                mov     ax,4310h                ; XMS control function
                int     2Fh
                pop     ax
                push    cs
                push    offset @@ReturnCZF
                push    es
                push    bx
                cmp     al,0
                je      @@Disable

                mov     ah,3                    ; Global enable A20
                retf

@@Disable:      mov     ah,4                    ; Global disable A20
                retf

@@NoXMSdriver:  pop     ax
                push    cx
                mov     ah,0DFh                 ; A20 On
                or      al,al
                jnz     @@a20_1
                mov     ah,0DDh                 ; A20 Off
@@a20_1:        call    @@KeyWait
                jz      @@a20_err
                mov     al,0D1h
                out     64h,al
                call    @@KeyWait
                mov     al,ah
                out     60h,al
                call    @@KeyWait
                jz      @@a20_err
                mov     al,0FFh
                out     64h,al
                call    @@KeyWait
@@a20_err:      pop     cx
                ret
@@ReturnCZF:    mov     al,1
                test    ax,ax
                ret

;******** Wait for keyboard controller ready. Returns ZF=1 if timeout ********
@@KeyWait       proc    near
                xor     cx,cx                   ; maximum time out
@@kw_1:         dec     cx
                jz      @@kw_err
                in      al,64h
                and     al,2
                jnz     @@kw_1
@@kw_err:       or      cx,cx
                ret
                endp

SetA20          endp

;*****************************************************************************
;               Macro to setup a descriptor table pointer
;*****************************************************************************
SetDT           macro   DTptr,DTlen,DT
                mov     DTptr.TableSize,DTlen
                mov     bx,offset DT
                call    GetLinearAddr
                mov     DTptr.TableAddr,eax
                endm

;*****************************************************************************
;           Macro to setup a selector; uses previous routine.
;*****************************************************************************
Adjust          macro   Selector,Segmnt
If Segmnt EQ AX
Else
                mov     ax,Segmnt
EndIf
                mov     bx,offset Selector
                call    SelectorSetup
                endm

;*****************************************************************************
; Set a selector addressed by DS:BX to contain address of real-mode segment AX
;*****************************************************************************
SelectorSetup   proc    near
                movzx   eax,ax
                shl     eax,4
                mov     [bx].Base0to15,ax
                shr     eax,16
                mov     [bx].Base16to23,al
                mov     [bx].Base24to31,ah
                ret
                endp


;*****************************************************************************
;        Return in EAX linear address of a location adressed by DS:BX
;*****************************************************************************
GetLinearAddr   proc    near
                mov     ax,ds
                movzx   eax,ax
                movzx   ebx,bx
                shl     eax,4
                add     eax,ebx
                ret
                endp

;*****************************************************************************
;     Check if processor is a i386(R) or higher - if not, stop execution
;*****************************************************************************
CheckCPU        proc    near
		push	sp
		pop	dx
		cmp	dx,sp
		jne	@@isNot386
                smsw    dx                      ;Check if we are
                test    dl,1                    ;already in V86 mode
                je      @@NotV86
                mov     dx,offset AlreadyV86
                jmp     PrintAndExit
@@NotV86:       pushf                           ;Check CPU by toggling
                pop     ax                      ;Nested Task (NT) bit
                xor     ax,4000h                ;in EFLAGS register
                push    ax
                popf
                pushf
                pop     bx
                xor     ax,4000h
                push    ax
                popf
                pushf
                pop     ax
                cmp     ax,bx
                jne     @@Is386
@@IsNot386:     mov     dx,offset CPUerror
PrintAndExit:   mov     ah,9
                int     21h
                mov     ax,4C01h                ;Terminate program
                int     21h
@@Is386:        mov     al,1
                call    SetA20
                jnz     @@Check_ok
                mov     dx,offset A20error
                jmp     PrintAndExit
@@Check_ok:     ret
                endp

;*****************************************************************************
;         Initialize ISR segment, set interrupt gates & do LIDT
;*****************************************************************************
InitializeIDT   proc    near
                cli
                mov     idInt13.SegLimit,offset int13h
                SetDT   DTload,IDTlen,IDT
                lidt    qword ptr DTload
                mov     bx,2820h
                call    SetPIC
                ret
                endp

;*****************************************************************************
;                      Switch to protected mode
;*****************************************************************************
SwitchToPM      proc    near
                sidt    SavedIDT
                mov     RMSS,ss
                mov     RMESP,esp
                mov     ah,3
                xor     bx,bx
                int     10h
                mov     ax,80
                mul     dh
                add     al,dl
                adc     ah,0
                mov     word ptr Cursor,ax
                in      al,021h
                mov     IntMask1,al
                in      al,0A1h
                mov     IntMask2,al

                Adjust  gdCode,cs
                Adjust  gdData,ds
                push    es
                push    0
                pop     es
                mov     ax,0B800h
                cmp     word ptr es:[463h],3D4h
                jae     @@Color
                mov     ax,0B000h
@@Color:        Adjust  gdVideo,ax
                pop     es

                SetAddr gdTSS,TaskSegment
                mov     TaskSegment.TSSespP0,offset P0ESP
                mov     TaskSegment.TSSesp,offset VM86SP
                mov     TaskSegment.TSSssP0,@gdData
                mov     word ptr TaskSegment.TSSss,ss
                mov     word ptr TaskSegment.TSSgs,gs
                mov     word ptr TaskSegment.TSSfs,fs
                mov     word ptr TaskSegment.TSSds,ds
                mov     word ptr TaskSegment.TSSes,es
                mov     word ptr TaskSegment.TSScs,cs
                mov     HIntFrame.i30esp,offset VM86SP
                mov     word ptr HIntFrame.i30ss,ss
                mov     word ptr HIntFrame.i30es,es
                mov     word ptr HIntFrame.i30ds,ds
                mov     word ptr HIntFrame.i30fs,fs
                mov     word ptr HIntFrame.i30gs,gs
                mov     PatchCS1,cs
                mov     PatchCS2,cs
If PMinterrupts EQ 1
                mov     PatchSS1,ss
                mov     word ptr QIRETaddr,offset QIret
                mov     word ptr QIRETaddr+2,cs
EndIf

                SetDT   DTload,GDTlen,GDT
                lgdt    qword ptr DTload
                call    InitializeIDT

                smsw    dx                      ;Heh ;)
                or      dl,1
                lmsw    dx                      ;Go to protected mode
                db      0EAh                    ;Clear prefetch & set CS
                dw      $+4,@gdCode

                mov     ax,@gdData
                mov     ds,ax
                mov     es,ax
                mov     fs,ax
                mov     gs,ax
                mov     ss,ax
                pop     bx
                mov     esp,offset P0ESP
                mov     ax,@gdTSS
                ltr     ax
                mov     al,IntMask1
                out     021h,al
                mov     al,IntMask2
                out     0A1h,al
                jmp     bx
                endp

;*****************************************************************************
;    Switch to VM86 and continue execution from (Real-mode)CS:runVM86(label)
;*****************************************************************************
SwitchToVM86    proc    near
                cli
                pop     bx
                movzx   ebx,bx
                mov     ax,@gdData
                mov     ds,ax
                push    TaskSegment.TSSgs
                push    TaskSegment.TSSfs
                push    TaskSegment.TSSds
                push    TaskSegment.TSSes
                push    TaskSegment.TSSss
If VM86stack EQ 1
                push    RMESP
Else
                push    large offset VM86SP
EndIf
                push    20000h or StartIOPL     ; Set VM86 & IOPL,clear IF
                push    TaskSegment.TSScs
                push    ebx
                pushfd
                pop     eax
                and     ax,not 4000h            ; Clear NT
                push    eax
                popfd
                iretd
                endp
