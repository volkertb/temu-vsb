;┌═══════════════════════════════════════════════════════════════════════════┐
;│▒▓█            Sound Blaster emulator for Covox & PC-Squeaker           █▓▒│
;│▒▓█             for Covox Speech Thing|PC Squeaker & 386 CPU            █▓▒│
;│▒▓█          Version 2.02 (C)opyright 1993 by FRIENDS software          █▓▒│
;└═══════════════════════════════════════════════════════════════════════════┘

                .SALL
                .MODEL  TINY
                .386P
                .CODE
                ;SMART
                ORG     100h

Start:          jmp     @@here
                dw      offset RealModeProg - offset Start
@@here:         push    sp
                pop     ax
                cmp     ax,sp
                jne     @@real
                smsw    ax
                test    al,1
                je      @@real
                mov     si,offset V86modeProg
                jmp     @@runIt
@@real:         mov     si,offset RealModeProg
@@runIt:        push    si
                mov     di,sp
                mov     cx,progLen
                sub     di,cx
                sub     di,200h                 ; For stack
                mov     ax,[si]
                add     ax,[si+2]
                cmp     ax,di
                jae     @@noMemory
                theoffset equ offset @@nextInstr - offset Start
                lea     ax,[di+theoffset]
                mov     si,offset Start
                rep     movsb
                jmp     ax
@@nextInstr:    pop     si
                mov     di,offset Start
                push    di
                mov     cx,[si+2]
                mov     si,[si]
                add     si,offset Start
                rep     movsb
                retn

@@noMemory:     mov     ah,9
                mov     dx,offset msgNoMemory
                int     21h
                int     20h

msgNoMemory     db      'Not enough memory to load VSB',13,10,'$'

progLen         equ     $ - offset Start

RealModeProg    dw      0,0
V86modeProg     dw      0,0

                end     Start
