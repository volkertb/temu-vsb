;ฺอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออฟ
;ณฑฒÛ            Sound Blaster emulator for Covox & PC-Squeaker           Ûฒฑณ
;ณฑฒÛ             for Covox Speech Thing|PC Squeaker & 386 CPU            Ûฒฑณ
;ณฑฒÛ          Version 2.02 (C)opyright 1993 by FRIENDS software          Ûฒฑณ
;ภอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออู

                .SALL
                .MODEL  TINY
                .386P
                .CODE
                SMART
                ORG     100h

PortHandler     equ     <s386port.asm>
MinIRQfreq      equ     20h
MinTimerFreq    equ     030h            ; Ignore request to faster frequences

Start:          jmp     Init

                include ..\386pdef.asm  ; Definitions first
                include ..\386pdata.asm ; Then data segment
                include ..\386plib.asm  ; PM library
                include ..\386pint.asm  ; ISR's
                include ..\386pdt.asm   ; Descriptor tables

IRQ0handler     proc    near
                push    ax
                push    dx
                push    ebx
                mov     ax,@gdData
                mov     ds,ax
                mov     ax,@gdFlat
;               mov     es,ax
EnablePatch:    jmp     @@ShutUp        ; Patch here to shut up

                mov     ebx,12345678h
SamplePointer   equ     dword ptr $-4
                mov     al,es:[ebx]

PatchHere:      shr     al,1
                out     42h,al

                inc     word ptr SamplePointer
IncDecPatch     equ     byte ptr $-3
                sub     SBcounter,1
                jc      LastSBbyte
@@DecDMA:       sub     DMAcounter,1
                jc      LastDMAbyte

@@ShutUp:       add     Counter,1234h
Int8Coeff       equ     word ptr $-2
                jc      @@DoOld

@@IRET:         mov     al,60h
                out     20h,al
                pop     ebx
                pop     dx
                pop     ax
                iretd

@@DoOld:        cmp     Speaker,0
                je      @@NoRestore
                in      al,61h
                or      al,3
                out     61h,al
                mov     al,90h
                out     43h,al
@@NoRestore:    test    PICmask,10000000b
IRQpatch5       equ     byte ptr $-1
                jne     @@IRQ7_masked
                cmp     DoAnIRQ,1
                je      LastSBbyte
@@IRQ7_masked:  test    PICmask,00000001b
                jne     @@IRET
                mov     DoAnIRQ,0
                pop     ebx
                pop     dx
                ;mov     al,60h
                ;out     20h,al
                ;mov     ss:FlagsMask,1111111011111111b
                mov     ax,8                    ; Do old 8th interrupt
                jmp     IRQset

LastDMAByte:    push    offset @@ShutUp
@@LastDMA:      mov     al,0
                cmp     AutoInit,al
                je      @@TurnOff
               ;mov     ax,word ptr SBDMAcount
               ;mov     SBcounter,ax
                mov     ax,word ptr DMAch1count
                mov     DMAcounter,ax
                mov     ax,word ptr DMAch1ad
                mov     word ptr SamplePointer,ax
                movzx   ax,byte ptr DMAch1page
                mov     word ptr SamplePointer+2,ax
                mov     al,1
@@TurnOff:      jmp     EnableDMA

LastSBbyte:     mov     DoAnIRQ,1
               ;mov     ax,word ptr SBDMAcount
               ;mov     SBcounter,ax
                mov     al,0
                call    EnableDMA
                test    PICmask,10000000b
IRQpatch6       equ     byte ptr $-1
                jne     @@DecDMA
                sub     DMAcounter,1
                jnc     @@SkipDMA
                call    near ptr @@LastDMA
@@SkipDMA:      mov     DoAnIRQ,0
                pop     ebx
                pop     dx
                mov     al,60h
                out     20h,al
                mov     Port020,8007h
IRQpatch1       equ     word ptr $-2
                mov     ax,0Fh                  ; Generate an IRQ
IRQpatch3       equ     byte ptr $-2
                jmp     IRQset
IRQ0handler     endp

; 1 - enable; 0 - disable DMA
EnableDMA       proc    near
                push    bx
                mov     bx,word ptr ss:PatchData1
                or      al,al
                je      @@Off
                cmp     ss:SBcounter,0FFFFh
                jne     @@1
                inc     ss:SBcounter
@@1:            cmp     ss:DMAcounter,0FFFFh
                jne     @@2
                inc     ss:DMAcounter
@@2:            mov     bx,word ptr ss:PatchData2
@@Off:          mov     word ptr ss:EnablePatch,bx
                pop     bx
                ret
                endp

; 1 - Enable sound; 0 - disable sound
EnableSB        proc    near
                push    eax
                or      al,al
                mov     eax,90909090h
                je      @@Set
                mov     eax,dword ptr ss:PatchIRQ
@@Set:          mov     dword ptr ss:PatchHere,eax
                pop     eax
                ret
                endp

SetTimerFreq    proc    near
                push    ax
                push    dx
                mov     ss:TimerFreq,ax
                mov     ax,ss:IRQ0freq
                cmp     ax,MinTimerFreq
                ja      @@freqOK
                mov     ax,MinTimerFreq
@@freqOK:       or      ax,ax
                jne     @@NoZero
                dec     ax
@@NoZero:       push    bx
                mov     bx,ax
                mov     dx,ss:TimerFreq
                xor     ax,ax
                cmp     dx,bx
                jae     @@Overflow
                div     bx
@@PutRes:       mov     ss:Int8Coeff,ax
                mov     ax,ss:TimerFreq
                push    ax
                mov     al,36h
                out     43h,al
                pop     ax
                out     40h,al
                mov     al,ah
                out     40h,al
                cmp     ss:Speaker,0
                je      @@NoInit
                in      al,61h
                or      al,3
                out     61h,al
                mov     al,90h
                out     43h,al
@@NoInit:       pop     bx
                pop     dx
                pop     ax
                ret
@@Overflow:     dec     ax
                mov     ss:IRQ0freq,bx
                mov     ss:TimerFreq,bx
                jmp     @@PutRes
                endp

Int15entry      proc
                cmp     ah,087h
                jne     @@DoOld
                push    ecx
                push    esi
                push    edi
                mov     edi,es:[si+26]
                mov     esi,es:[si+18]
                shl     esi,8
                shr     esi,8
                shl     edi,8
                shr     edi,8
                movzx   ecx,cx
                int     3

                pop     edi
                pop     esi
                pop     ecx
                clc
                retf    2
@@DoOld:        db      0EAh
Old15           dd      0
Int15entry      endp

SlowAdlib       db      0
SBirq           db      5
Phase_E2        db      0
PrevE2          db      0
ReadWrite       db      0
PICmask         db      0
DoAnIRQ         db      0
AutoInit        db      0
DMAflipFlop     db      0
DMAch1ad        dw      0
DMAch1count     dw      0
DMAch1page      db      0
DMAcounter      dw      0
SBcounter       dw      0
FlipFlop        db      0
Speaker         db      0
Counter         dw      0
SBDMAcount      dw      0
IRQ0freq        dw      0FFFFh
TimerFreq       dw      1000h
PatchData1      dw      0
PatchData2:     mov     es,ax
PatchIRQ:       shr     al,1
                out     42h,al
CovoxPatch:     mov     dx,5FE0h
DACport         equ     word ptr $-2
                out     dx,al

LastByte        label   near

CheckCmdLine    proc    near
                cld
                mov     si,81h
@@NextChar:     lodsb
                cmp     al,' '
                je      @@NextChar
                cmp     al,13
                je      @@EndCmdLine
                cmp     al,'/'
                jne     @@BadOption
                lodsb
                and     al,0DFh
                cmp     al,'H'
                je      @@PrintHelp
                cmp     al,1Fh
                je      @@PrintHelp
                cmp     al,'S'
                je      @@Speaker
                cmp     al,'L'
                je      @@Covox
                cmp     al,'A'
                je      @@Adlib
                cmp     al,'W'
                je      @@SlowAdlib
                cmp     al,'I'
                je      @@SetIRQ
                cmp     al,'F'
                je      @@NextChar
@@BadOption:    mov     dx,offset BadOption
                jmp     PrintAndExit

@@PrintHelp:    mov     dx,offset HelpText
                jmp     PrintAndExit

@@Speaker:      inc     Speaker
                jmp     @@NextChar

@@Adlib:        mov     CatchAdlib,0
                jmp     @@NextChar

@@SlowAdlib:    mov     SlowAdlib,1
                jmp     @@NextChar

@@SetIRQ:       lodsb
                sub     al,'0'
                jc      @@BadOption
                cmp     al,7
                je      @@IRQok
                cmp     al,5
                jne     @@BadOption
@@IRQok:        mov     SBirq,al
                jmp     @@NextChar

@@Covox:        lodsb
                sub     al,'1'
                jc      @@BadOption
                cmp     al,4
                jae     @@BadOption
                push    es
                push    0
                pop     es
                movzx   bx,al
                shl     bx,1
                mov     ax,es:[bx+408h]
                mov     DACport,ax
                mov     Speaker,0
                pop     es
                jmp     @@NextChar

@@EndCmdLine:   retn
                endp

SetupRoutines   proc    near
                mov     ax,3515h
                int     21h
                mov     word ptr Old15,bx
                mov     word ptr Old15+2,es
                mov     dx,offset Int15entry
                mov     ah,25h
                int     21h
                push    cs
                pop     es
                in      al,61h
                and     al,11111100b
                out     61h,al
                cmp     Speaker,0
                jne     @@NoChange
                mov     eax,dword ptr CovoxPatch
                mov     dword ptr PatchHere,eax
                mov     dword ptr PatchIRQ,eax
@@NoChange:     mov     idInt32.SegLimit,offset IRQ0handler
                mov     ax,TimerFreq
                call    SetTimerFreq
                mov     IOportMap[000h/8],00001100b  ;Ports 000h...007h
                mov     IOportMap[008h/8],11111111b  ;Ports 008h...00Fh
                mov     IOportMap[020h/8],00000011b  ;Ports 020h & 021h
                mov     IOportMap[040h/8],00001001b  ;Ports 040h & 043h
                mov     IOportMap[080h/8],00001000b  ;Port  083h
                mov     IOportMap[220h/8],01000000b  ;Ports 220h...227h
                mov     IOportMap[228h/8],01010111b  ;Ports 228h...22Eh
                mov     IOportMap[388h/8],00000011b  ;Ports 388h...389h
CatchAdlib      equ     byte ptr $-1
                mov     ax,word ptr EnablePatch
                mov     PatchData1,ax
                mov     al,0
                call    EnableSB
                mov     al,0
                call    EnableDMA
                mov     al,SBirq
                mov     cl,al
                mov     ah,1
                shl     ah,cl

                mov     IRQpatch1,ax
                mov     IRQpatch2,ax
                mov     IRQpatch5,ah
                mov     IRQpatch6,ah
                add     al,8
                mov     IRQpatch3,al
                mov     IRQpatch4,al
                retn
                endp

Init:           call    CheckCmdLine
                call    CheckCPU
                call    SetupRoutines
                call    SwitchToPM
                call    SwitchToVM86
                mov     ah,9                    ; Now running in VM86 mode
                mov     dx,offset Header
                int     21h
                mov     dx,offset LastByte
                int     27h                     ; Stay resident

                include ..\386rdata.asm         ; Real-mode data
                include ..\386preal.asm         ; Then real-mode subroutines
                include s386data.asm

                end     Start
