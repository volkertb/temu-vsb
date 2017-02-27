;∞±≤€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€≤±∞
;∞±≤€           Sound Blaster emulator for Covox & PC-Squeaker            €≤±∞
;∞±≤€                (C)opyleft 1993 by FRIENDS software                  €≤±∞
;∞±≤€                          Port handler                               €≤±∞
;∞±≤€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€≤±∞

                cmp     ah,0EEh
                je      OutDX_AL
                cmp     ah,0ECh
                je      InAL_DX
                cmp     ah,0E6h
                je      Out@@_AL
                cmp     ah,0E4h
                je      InAL_@@
                jmp     TooBad

OutDX_AL:       push    dx
CheckPort:      cbw
                add     [ebp],ax
                mov     al,byte ptr [ebp-4]
IfDef Debug
                push    ax
                mov     al,'O'
                call    Outchar
                mov     ax,dx
                call    hexout2
                pop     ax
                push    ax
                call    hexout
                mov     al,' '
                call    outchar
                pop     ax
EndIf
                cmp     dx,0220h
                jae     SBport
                cmp     dx,010h
                jb      DMAport
                cmp     dx,43h
                je      @@Timer_Control
                cmp     dx,40h
                je      @@Timer_Ch0
                cmp     dx,83h
                je      DMApage
                cmp     dx,20h
                je      @@PICCR

                mov     ss:PICmask,al
                and     al,0FEh
                out     dx,al
                jmp     AllRight

@@PICCR:        mov     ah,al
                out     20h,al
                and     al,06Eh
                cmp     al,0Ah
                jne     @@PICCR_1
                test    ah,1
                mov     ax,9090h
                je      @@PICCR_0
                mov     ax,word ptr ss:@@SelfMod
@@PICCR_0:      mov     word ptr ss:Port020sm,ax
                mov     ss:ICRoffset,offset ICRread
                jmp     AllRight
@@PICCR_1:      mov     word ptr ss:Port020,0
                jmp     AllRight
@@SelfMod:      mov     al,ah

@@Timer_Control:test    al,11000000b
                jne     @@NoCh0
                mov     ss:FlipFlop,0
                jmp     AllRight
@@NoCh0:        out     dx,al
                jmp     AllRight

@@Timer_Ch0:    and     ss:FlipFlop,1
                movzx   bx,ss:FlipFlop
                inc     ss:FlipFlop
                mov     byte ptr ss:IRQ0Freq[bx],al
                or      bx,bx
                je      AllRight
                mov     ax,ss:TimerFreq
               ;mov     bx,ss:IRQ0freq
                call    SetTimerFreq
                jmp     AllRight

SBport:         cmp     dl,88h
                jae     @@AdlibPort
@@HandleSB:     mov     bl,dl
                mov     bh,0
                shl     bx,1
                jmp     ss:OUTJumpTable[bx-40h]
@@AdlibPort:    cmp     ss:SlowAdlib,1
                je      OutF
                sub     dx,(388h-228h)
                jmp     @@HandleSB

Out220          label   near
Out221          label   near
Out222          label   near
Out223          label   near
Out224          label   near
Out225          label   near
Out227          label   near
Out22A          label   near
Out22B          label   near
Out22D          label   near
Out22F          label   near
                jmp     AllRight
In220           label   near
In221           label   near
In222           label   near
In223           label   near
In224           label   near
In225           label   near
In226           label   near
In227           label   near
In229           label   near
In22B           label   near
In22C           label   near
In22D           label   near
In22F           label   near
                mov     al,0
                jmp     AllRightIN

In228           label   near
                mov     al,0
Port228         equ     byte ptr $-1
                jmp     AllRightIN

In22A           label   near
                mov     al,0AAh
port22Acontents equ     byte ptr $-1
                mov     ss:port22Acontents,0AAh
                jmp     AllRightIN

In22A_E1a:      mov     al,01                   ; High byte of version No
                mov     ss:In22Aoffs,offset In22A_E1b
                jmp     AllRightIN

In22A_E1b:      mov     al,10                   ; Low byte of version No
                mov     ss:In22Aoffs,offset In22A
                jmp     AllRightIN

In22E           label   near
                mov     al,0
Port22E         equ     byte ptr $-1
                xor     ss:Port22E,080h
;               mov     ss:Out22Coffs,offset Out22Ca
                mov     ss:DoAnIRQ,0
                mov     ss:Port020,0
                jmp     AllRightIN

Out226          label   near
                mov     al,0
                call    EnableDMA
                mov     ss:Out22Coffs,offset Out22Ca
                mov     ss:DoAnIRQ,al
                mov     ss:Phase_E2,al
;               pop     dx
;               pop     ebp
;               pop     ds
;               pop     ebx
;               pop     eax
;               push    ax
;               mov     ax,3
;               jmp     IRQset
                jmp     AllRight

Out228          label   near
                mov     ss:Command228,al
                jmp     AllRight

Out229          label   near                    ; Ignore RegNo; only data
                mov     ah,0
Command228      equ     byte ptr $-1
                cmp     ah,4
                jne     @@229_Done
                test    al,10000000b
                jne     @@229_Reset
                test    al,1
                jne     @@229_Set
@@229_Reset:    mov     ss:Port228,0
                jmp     AllRight
@@229_Set:      and     al,060h
                xor     al,0E0h
                mov     ss:Port228,al
@@229_Done:     jmp     AllRight

Out22Ca         label   near
                cmp     al,010h
                je      @@22C_10
                mov     ss:Command,al
                cmp     al,014h
                je      @@22C_14
                cmp     al,040h
                je      @@22Ca_OK
                cmp     al,0E0h
                je      @@22Ca_OK
                cmp     al,0D0h
                je      @@22C_D0
                cmp     al,0D1h
                je      @@22C_D1
                cmp     al,0D3h
                je      @@22C_D3
                cmp     al,0D4h
                je      @@22C_D4
                cmp     al,0E1h
                je      @@22C_E1
                cmp     al,0E2h
                je      @@22C_E2
                cmp     al,0F2h
                je      @@22C_F2
                jmp     @@22Cb_OK

@@22C_10:       mov     ss:Out22Coffs,offset @@22C_10a
                jmp     AllRight

@@22C_14:       mov     ss:Out22Coffs,offset @@22C_14a
                jmp     AllRight

@@22C_D0:       mov     al,0
                call    EnableDMA
                jmp     AllRight

@@22C_D1:       mov     al,1
                call    EnableSB
                jmp     AllRight

@@22C_D3:       mov     al,0
                call    EnableSB
                jmp     AllRight

@@22C_D4:       mov     al,1
                call    EnableDMA
                jmp     AllRight

@@22C_E1:       mov     ss:In22Aoffs,offset In22A_E1a
                jmp     @@CommandOK

@@22C_E2:       mov     ss:Out22Coffs,offset @@22C_E2a
                jmp     AllRight

@@22C_F2:       pop     dx
                pop     ebp
                pop     ds
                pop     ebx
                pop     eax
                push    ax
                mov     ss:Port020,8007h
IRQpatch2       equ     word ptr $-2
                mov     ax,0Fh                  ; Generate an IRQ7
IRQpatch4       equ     byte ptr $-2
                jmp     IRQset

@@22Ca_OK:      mov     ss:Out22Coffs,offset Out22Cb
                jmp     AllRight

@@22Cb_OK:      mov     ss:Out22Coffs,offset Out22Ca
                jmp     AllRight

Out22Cb         label   near
                mov     ah,0
Command         equ     byte ptr $-1
                cmp     ah,040h
                je      @@22C_40
                cmp     ah,0E0h
                je      @@22C_E0
                jmp     @@CommandOK
@@22C_10a:      mov     dx,ss:DACport
                out     dx,al
@@CommandOK:    mov     ss:Out22Coffs,offset Out22Ca
                jmp     AllRight

@@22C_14a:      mov     byte ptr ss:SBDMAcount,al
                mov     ss:Out22Coffs,offset @@22C_14b
                jmp     AllRight

@@22C_14b:      mov     byte ptr ss:SBDMAcount+1,al
                mov     ss:Out22Coffs,offset Out22Ca
                mov     ax,word ptr ss:PatchData1
                mov     word ptr ss:EnablePatch,ax; Disable DMA
                mov     ax,word ptr ss:SBDMAcount
                cmp     ax,1
                ja      @@NotTest
                mov     al,010h                 ; Give to emulator a chance
                mov     ss:DMAcounter,ax
@@NotTest:      mov     ss:SBcounter,ax
                mov     al,1
                call    EnableDMA
                jmp     AllRight

@@22C_40:       not     al
                mov     ah,120
                mul     ah
                xor     dx,dx
                mov     bx,108
                div     bx
                cmp     ax,MinIRQfreq
                ja      @@22C_40_1
                mov     ax,MinIRQfreq
@@22C_40_1:     call    SetTimerFreq
                jmp     @@CommandOK

@@22C_E0:       not     al
                mov     ss:port22Acontents,al
                jmp     @@CommandOK

@@22C_E2a:      xor     ss:Phase_E2,1
                je      @@Phase2
                mov     ah,al
                and     ax,016E9h
                sub     al,ah
                add     al,40h
                mov     ss:PrevE2,al
                jmp     @@E2done
@@Phase2:       xor     al,0A5h
                add     al,ss:PrevE2
@@E2done:       mov     esi,ss:SamplePointer
                push    @gdFlat
                pop     fs
                mov     fs:[esi],al
                mov     al,ss:IncDecPatch
                mov     ss:IncDecPatch1,al
                inc     word ptr ss:SamplePointer
IncDecPatch1    equ     byte ptr $-3
                jmp     @@CommandOK

Out22E          label   near
                mov     ss:DoAnIRQ,0
                jmp     AllRight

OUTJumpTable    dw      offset Out220,offset Out221
                dw      offset Out222,offset Out223
                dw      offset Out224,offset Out225
                dw      offset Out226,offset Out227
                dw      offset Out228,offset Out229
                dw      offset Out22A,offset Out22B
Out22Coffs      dw      offset Out22Ca,offset Out22D
                dw      offset Out22E,offset Out22F

INJumpTable     dw      offset In220, offset In221
                dw      offset In222, offset In223
                dw      offset In224, offset In225
                dw      offset In226, offset In227
                dw      offset In228, offset In229
In22Aoffs       dw      offset In22A, offset In22B
                dw      offset In22C, offset In22D
                dw      offset In22E, offset In22F

DMAport:        mov     bl,dl
                mov     bh,0
                shl     bx,1
                jmp     ss:DMAOUTJumpTable[bx]

Out0            label   near
Out1            label   near
Out4            label   near
Out5            label   near
Out6            label   near
Out7            label   near
Out8            label   near
Out9            label   near
OutD            label   near
OutE            label   near
OutF            label   near
                out     dx,al
                jmp     AllRight

Out2:           movzx   bx,byte ptr ss:DMAflipFlop
                xor     byte ptr ss:DMAflipFlop,1
                mov     byte ptr ss:DMAch1ad[bx],al
                jmp     AllRight

Out3:           movzx   bx,byte ptr ss:DMAflipFlop
                xor     byte ptr ss:DMAflipFlop,1
                mov     byte ptr ss:DMAch1count[bx],al
                jmp     AllRight

OutA:           mov     ah,al
                and     ah,3
                cmp     ah,1
                jne     OutE
;               out     dx,al
                and     al,4
                xor     al,4
                je      @@OutA_1
                mov     ax,0FFFFh
                cmp     ss:ReadWrite,0
                jne     @@SetCnt
                mov     ax,ss:DMAch1count
@@SetCnt:       mov     ss:DMAcounter,ax
                mov     ax,word ptr ss:DMAch1ad
                mov     word ptr ss:SamplePointer,ax
                movzx   ax,byte ptr ss:DMAch1page
                mov     word ptr ss:SamplePointer+2,ax
@@OutA_1:       jmp     AllRight

OutB            label   near
                mov     ah,al
                and     ah,3
                cmp     ah,1
                jne     OutF
                mov     ah,al
                and     ah,00010000b
                mov     ss:AutoInit,ah
                mov     ah,al
                and     ah,00100000b
                shr     ah,2
                and     ss:IncDecPatch,not 8
                or      ss:IncDecPatch,ah
                and     al,00000100b
                mov     ss:ReadWrite,al
                jmp     AllRight

OutC:           mov     ss:DMAflipFlop,0
                jmp     AllRight

DMAOUTjumpTable dw      offset Out0, offset Out1
                dw      offset Out2, offset Out3
                dw      offset Out4, offset Out5
                dw      offset Out6, offset Out7
                dw      offset Out8, offset Out9
                dw      offset OutA, offset OutB
                dw      offset OutC, offset OutD
                dw      offset OutE, offset OutF
DMAINjumpTable  dw      offset In00, offset In01
                dw      offset In02, offset In03
                dw      offset In04, offset In05
                dw      offset In06, offset In07
                dw      offset In08, offset In09
                dw      offset In0A, offset In0B
                dw      offset In0C, offset In0D
                dw      offset In0E, offset In0F
                dw      ?,?                             ;10h/11h
                dw      ?,?                             ;12h/13h
                dw      ?,?                             ;14h/15h
                dw      ?,?                             ;16h/17h
                dw      ?,?                             ;18h/19h
                dw      ?,?                             ;1Ah/1Bh
                dw      ?,?                             ;1Ch/1Dh
                dw      ?,?                             ;1Eh/1Fh
ICRoffset       dw      offset DirectRead

DMApage:        mov     ss:DMAch1page,al
                jmp     AllRight

Out@@_AL:       push    dx
                movzx   dx,byte ptr [ebx]
                inc     al
                jmp     CheckPort

InAL_DX:        push    dx
ReadPort:       cbw
                add     [ebp],ax
IfDef Debug
                push    ax
                mov     al,'I'
                call    Outchar
                mov     ax,dx
                call    hexout2
                mov     al,' '
                call    outchar
                call    outchar
                call    outchar
                pop     ax
EndIf
                cmp     dx,220h
                jb      DMAread

                cmp     dl,88h
                jae     @@AdlibRead
@@ReadSB:       mov     bl,dl
                mov     bh,0
                shl     bx,1
                jmp     ss:INJumpTable[bx-40h]
@@AdlibRead:    cmp     ss:SlowAdlib,1
                je      DirectRead
                sub     dx,(388h-228h)
                jmp     @@ReadSB

ICRread:        mov     ax,0
Port020         equ     word ptr $-2
Port020sm:      mov     al,ah
                mov     ss:ICRoffset,offset DirectRead
                or      al,al
                je      DirectRead
                jmp     AllRightIN

DMAread:        cmp     dl,83h
                je      GetDMApage
                cmp     dl,20h
                ja      DirectRead
                mov     bl,dl
                mov     bh,0
                shl     bx,1
                jmp     ss:DMAINJumpTable[bx]

InAL_@@:        push    dx
                inc     al
                movzx   dx,byte ptr [ebx]
                jmp     ReadPort

In02:           movzx   bx,byte ptr ss:DMAflipFlop
                xor     byte ptr ss:DMAflipFlop,1
                mov     al,byte ptr ss:SamplePointer[bx]
                jmp     AllRightIN

In03:           movzx   bx,byte ptr ss:DMAflipFlop
                xor     byte ptr ss:DMAflipFlop,1
                mov     al,byte ptr ss:DMAcounter[bx]
                jmp     AllRightIN

GetDMApage:     mov     al,ss:DMAch1page
                jmp     allRightIN

In00            label   near
In01            label   near
In04            label   near
In05            label   near
In06            label   near
In07            label   near
In08            label   near
In09            label   near
In0A            label   near
In0B            label   near
In0C            label   near
In0D            label   near
In0E            label   near
In0F            label   near
DirectRead:     in      al,dx
AllRightIN:     mov     byte ptr [ebp-4],al
AllRight:       pop     dx
                pop     ebp
                pop     ds
                pop     ebx
                pop     eax
                iretd

TooBad:
