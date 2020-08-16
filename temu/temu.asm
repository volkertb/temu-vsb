;┌═══════════════════════════════════════════════════════════════════════════┐
;│▒▓█  TANDY3 & PCjr sound generator (TI SN 76496N) & DISNEY SS emulator  █▓▒│
;│▒▓█             for Covox Speech Thing|PC Squeaker & 386 CPU            █▓▒│
;│▒▓█          Version 3.03 (C)opyright 1993 by FRIENDS software          █▓▒│
;└═══════════════════════════════════════════════════════════════════════════┘

                .SALL
                .MODEL  TINY
                .386P
                .CODE
                SMART
                ORG     100h

DSSbufferSize   equ     128
DSSbufferMask   equ     DSSbufferSize-1
PortHandler     equ     <t386port.asm>
StartFreq       equ     050h

Start:          jmp     Init

ScaleTable      db      16*256 dup ('·')

                include ../386pdef.asm          ; Definitions first
                include ../386pdata.asm         ; Then data segment
                include ../386plib.asm          ; PM library
                include ../386pint.asm          ; ISR's
                include ../386pdt.asm           ; Descriptor tables

IRQ0handler     proc    near
                push    ax
                push    bx
                push    dx
                push    si
                mov     ax,@gdData
                mov     ds,ax

;*** First channel - DSS or noise if exist (computed later) ***
                mov     bx,1234h
BuffStart       equ     word ptr $-2

                mov     ah,DSSbuffer[bx]

                cmp     bx,1234h
BuffEnd         equ     word ptr $-2
                je      @@DSSsilence

                add     DSSfreqbuff,1234h
DSSfrequence    equ     word ptr $-2
                adc     bx,0
                and     bx,DSSbufferMask
                mov     BuffStart,bx

@@DSSsilence:   mov     bx,Low offset ScaleTable
Volume4         equ     byte ptr $-1
                cmp     bh,1
                jbe     @@NoNoise

;*** Compute noise if enabled ***
                mov     si,0
Position4       equ     word ptr $-2
                shr     si,5
                mov     al,NoiseSample[si]
                xlat
                mov     ah,al

@@NoNoise:      mov     si,0
Position1       equ     word ptr $-2
                shr     si,8
                mov     al,MelodicSample[si]
                mov     bh,1
Volume1         equ     byte ptr $-1
                xlat
                add     ah,al

                mov     si,0
Position2       equ     word ptr $-2
                shr     si,8
                mov     al,MelodicSample[si]
                mov     bh,1
Volume2         equ     byte ptr $-1
                xlat
                add     ah,al

                mov     si,0
Position3       equ     word ptr $-2
                shr     si,8
                mov     al,MelodicSample[si]
                mov     bh,1
Volume3         equ     byte ptr $-1
                xlat
                add     al,ah

                xor     al,80h
PatchHere:      shr     al,1
                out     42h,al

                add     word ptr Position1,0200h
Freq1           equ     word ptr $-2
                add     word ptr Position2,0200h
Freq2           equ     word ptr $-2
                add     word ptr Position3,0200h
Freq3           equ     word ptr $-2
                add     word ptr Position4,0200h
Freq4           equ     word ptr $-2

                add     Counter,1234h
Int8Coeff       equ     word ptr $-2
                jc      @@DoOld
                mov     al,60h
                out     20h,al
                pop     si
                pop     dx
                pop     bx
                pop     ax
                iretd

@@DoOld:        pop     si
                pop     dx
                pop     bx
                cmp     Speaker,0
                je      @@NoRestore
                mov     ax,BuffStart
                cmp     ax,BuffEnd
                je      @@NoRestore
                mov     al,90h
                out     43h,al
                in      al,61h
                or      al,3
                out     61h,al
@@NoRestore:    mov     al,60h
                out     20h,al
                mov     ax,8                    ; Do old 8th interrupt
                mov     ss:FlagsMask,1111111011111111b
                jmp     IRQset
                endp

SetTimerFreq    proc    near
                mov     ss:TimerFreq,ax
                push    ax
                push    ax
                mov     al,36h
                out     43h,al
                pop     ax
                out     40h,al
                mov     al,ah
                out     40h,al
                cmp     cs:Speaker,0
                je      @@NoInit
                in      al,61h
                or      al,3
                out     61h,al
                mov     al,90h
                out     43h,al
@@NoInit:       push    dx
                mov     dx,ss:TimerFreq
                xor     ax,ax
                cmp     dx,ss:DSSbaseFreq
                jb      @@OK
                mov     ax,0FFFFh
                jmp     @@SetDSS
@@OK:           div     ss:DSSbaseFreq
@@SetDSS:       mov     ss:DSSfrequence,ax
                pop     dx
                pop     ax
                ret
                endp

SetVirtualIRQ   proc    near
                or      ax,ax
                jne     @@NoZero
                dec     ax
@@NoZero:       mov     ss:IRQ0freq,ax
                push    dx
                push    bx
                push    ax
                mov     bx,ax
                mov     dx,cs:TimerFreq
                xor     ax,ax
                cmp     dx,bx
                jae     @@Overflow
                div     bx
@@PutRes:       mov     ss:Int8Coeff,ax
                pop     ax
                pop     bx
                pop     dx
                ret
@@Overflow:     dec     ax
                jmp     @@PutRes
                ret
                endp

OutC0_AL        proc    near
                push    cx
                mov     bx,@gdData
                mov     ds,bx

                test    al,80h
                jz      @@SecondByte
                mov     bl,al
                mov     cl,3
                shr     bl,cl
                and     bx,0Eh
                jmp     [bx+offset JumpTable]

@@SecondByte:   mov     bx,LastChannel
                mov     ah,0
                mov     cl,4
                shl     ax,cl
                mov     dl,[bx+offset VoiceFreq]
                and     dl,15
                or      al,dl
                and     ax,3FFh
                mov     word ptr [bx+offset VoiceFreq],ax
                call    Sound
                jmp     @@Exit

Register0:      and     ax,0Fh
                mov     bx,VoiceFreq[0]
                and     bx,3F0h
                or      ax,bx
                mov     bl,0
                mov     VoiceFreq[0],ax
                call    Sound
                jmp     short @@Exit
Register1:      and     ax,0Fh
                xor     al,0Fh
                inc     al
                mov     Volume1,al
                jmp     short @@Exit
Register2:      and     ax,0Fh
                mov     bx,VoiceFreq[2]
                and     bx,3F0h
                or      ax,bx
                mov     bl,2
                mov     VoiceFreq[2],ax
                call    Sound
                jmp     short @@Exit
Register3:      and     al,0Fh
                xor     al,0Fh
                inc     al
                mov     Volume2,al
                jmp     short @@Exit
Register4:      and     ax,0Fh
                mov     bx,VoiceFreq[4]
                and     bx,3F0h
                or      ax,bx
                mov     bl,4
                mov     VoiceFreq[4],ax
                call    Sound
                jmp     short @@Exit
Register5:      and     al,0Fh
                xor     al,0Fh
                inc     al
                mov     Volume3,al
                jmp     short @@Exit
Register6:      and     ax,03h
                mov     bx,ax
                shl     bx,1
                mov     ax,[bx+offset NoiseFreq]
                mov     Freq4,ax
                jmp     short @@Exit
Register7:      and     al,0Fh
                xor     al,0Fh
                inc     al
                mov     Volume4,al
@@Exit:         pop     cx
                ret

JumpTable:      dw      offset Register0,offset Register1
                dw      offset Register2,offset Register3
                dw      offset Register4,offset Register5
                dw      offset Register6,offset Register7
NoiseFreq       dw      0008h,000Ch,0010h,0018h
OutC0_AL        endp

Sound           proc    near
;Function ->    Compute frequence for given channel # (0-2)
;In       ->    ax = 10-bit frequence
;               bl = channel (0-2)
;Out      ->    ax = 16-bit-style frequence
                mov     bh,0
                mov     LastChannel,bx
                mov     bx,[bx+offset FreqOffs]
                cmp     ax,13
MinFreq         equ     word ptr $-2
                ja      @@Compute
                jmp     @@Zero
@@Compute:      mov     cx,ax
                mov     ax,1583h
                mul     TimerFreq
                div     cx
                mov     [bx],ax
                retn
@@Zero:         xor     ax,ax
                mov     [bx],ax
                retn
Sound           endp

Int15entry      proc
                cmp     ah,0C0h
                jne     @@NotC0
                push    cs
                pop     es
                mov     bx,offset ROMtable
                clc
                retf    2
@@NotC0:        cmp     ah,087h
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

ROMtable        dw      8
                db      0FCh
                db      00Bh
                db      000h
                db      070h
                dd      0

FlipFlop        db      0
Speaker         db      0
Counter         dw      0
DSSfreqbuff     dw      0
IRQ0freq        dw      0FFFFh
DSSbaseFreq     dw      070h
DSSbuffer       db      DSSbufferSize dup (?)
FreqOffs        dw      Freq1,Freq2,Freq3,Freq4
TimerFreq       dw      StartFreq
LastChannel     dw      0
VoiceFreq       dw      0,0,0,0

                include Samples.asm

LastByte        label   near

VolumeTable     db      00,01,02,03,04,05,06,08,10,12,14,17,20,23,27,32

CovoxPatch:     mov     dx,5FE0h
DACport         equ     word ptr $-2
                out     dx,al

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
                cmp     al,'T'
                je      @@IRQ0freq
@@BadOption:    mov     dx,offset BadOption
                jmp     PrintAndExit

@@PrintHelp:    mov     dx,offset HelpText
                jmp     PrintAndExit

@@Speaker:      inc     Speaker
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

@@IRQ0freq:     xor     bx,bx
@@ReadNumber:   lodsb
                cmp     al,' '
                jbe     @@NumberEnd
                sub     al,'0'
                jc      @@BadOption
                cmp     al,9
                ja      @@BadOption
                cbw
                xchg    ax,bx
                mov     cl,10
                mul     cl
                add     bx,ax
                jmp     @@ReadNumber
@@NumberEnd:    cmp     bx,44
                ja      @@BadOption
                cmp     bx,12
                jb      @@BadOption
                mov     ax,1000
                mul     bx
                xchg    ax,bx
                mov     dx,00014h
                mov     ax,04F38h
                div     bx
                mov     TimerFreq,ax
                dec     si
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
                mov     al,48h
                out     61h,al
                cmp     Speaker,0
                jne     @@NoChange
                mov     si,offset CovoxPatch
                mov     di,offset PatchHere
                mov     cx,4
                rep     movsb
@@NoChange:     mov     idInt32.SegLimit,offset IRQ0handler
                mov     ax,IRQ0freq
                call    SetVirtualIRQ
                mov     ax,TimerFreq
                call    SetTimerFreq
                mov     IOportMap[040h/8],00001001b  ;Ports 040h & 043h
                mov     IOportMap[0C0h/8],00000011b  ;Ports 0C0h & 0C1h
                mov     IOportMap[1E0h/8],00000011b  ;Ports 1E0h & 1E1h
                mov     IOportMap[205h/8],00100000b  ;Port  205h
                mov     IOportMap[378h/8],00000011b  ;Ports 378h & 379h

                xor     ax,ax
                mov     BuffStart,ax
                mov     BuffEnd,ax
                inc     al
                mov     Volume4,al
                mov     al,18h
                mov     Freq1,ax
                mov     Freq2,ax
                mov     Freq3,ax
                mov     Freq4,ax

                mov     ax,1583h
                mul     TimerFreq
                inc     dx
                shl     dx,1
                mov     MinFreq,dx
;░▒▓█ Compute volume scaling table █▓▒░
                mov     bx,offset VolumeTable
                push    cs
                pop     es
                mov     di,offset ScaleTable
                cld
@@L00:          mov     cx,256
@@L01:          mov     ax,256
                sub     ax,cx
                sar     al,2
                mov     ah,[bx]
                imul    ah
                sar     ax,5
                stosb
                loop    @@L01
                inc     bx
                cmp     bx,offset VolumeTable+16
                jb      @@L00
                retn
                endp

Init:           call    CheckCPU
                call    CheckCmdLine
                call    SetupRoutines
                call    SwitchToPM
                call    SwitchToVM86

                mov     ah,9                    ; Now running in VM86 mode
                mov     dx,offset Header
                int     21h
                mov     dx,offset LastByte
                int     27h                     ; Stay resident

                include ../386rdata.asm         ; Real-mode data
                include ../386preal.asm         ; Then real-mode subroutines
                include t386data.asm

                end     Start
