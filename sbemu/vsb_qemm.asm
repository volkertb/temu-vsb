;┌═══════════════════════════════════════════════════════════════════════════┐
;│▒▓█            Sound Blaster emulator for Covox & PC-Squeaker           █▓▒│
;│▒▓█   for Covox Speech Thing|PC Squeaker & 386 CPU using QEMM API       █▓▒│
;│▒▓█          Version 2.02 (C)opyright 1993 by FRIENDS software          █▓▒│
;└═══════════════════════════════════════════════════════════════════════════┘

                .SALL
                .MODEL  TINY
                .386P
;                LOCALS  @@
;                SMART

MinTimerFreq    equ     030h            ; Ignore request to faster frequences

Flash           macro   Color           ; debug macro
                local   @@1,@@2
                push    ax
                push    dx
                mov     dx,3DAh
                in      al,dx
                mov     dl,0C0h
                mov     al,11h
                out     dx,al
                mov     al,Color
                out     dx,al
                mov     al,20h
                out     dx,al
                mov     dl,0DAh
                mov     ah,30h
@@1:            in      al,dx
                test    al,8
                je      @@1
@@2:            in      al,dx
                test    al,8
                jne     @@2
                dec     ah
                jne     @@1
                pop     dx
                pop     ax
                endm

Acode16         segment byte use16
                assume  cs:Acode16, ds:Acode16
_Code           group   Acode16,Code32,Zcode16
                org     100h

MinIRQfreq      equ     20h
PIC1start       equ     0C0h            ; Redirect IRQ0 to this int

Start:          jmp     Init

Acode16         ends

Code32          segment byte use32
                assume  cs:Code32

IRQ0entry       proc    near
                push    eax
                push    ebx
                push    ds
                mov     ax,0030h
                mov     ds,ax

                mov     ebx,12345678h
DataLinearAddr  equ     dword ptr $-4
EnablePatch:    jmp     @@ShutUp                ; Patch here to shut up

                mov     esi,12345678h
SampleOffs      equ     dword ptr $-4
                mov     al,[esi]

DACpatch:       shr     al,1
                out     42h,al
                nop

                inc     word ptr SampleOffs[ebx]
IncDecPatch     equ     byte ptr $-5
                sub     SBcounter[ebx],1
                jc      LastSBbyte
@@DecDMA:       sub     DMAcounter[ebx],1
                jc      LastDMAbyte

@@contIRQ0:     pop     esi
                pop     edx

@@ShutUp:       add     Counter[ebx],1234h
Int8Coeff       equ     word ptr $-2
                jc      @@DoOld

@@IRET:         mov     al,60h
                out     20h,al
                pop     ds
                pop     ebx
                pop     eax
                iretd

@@DoOld:        cmp     Speaker[ebx],0
                je      @@NoRestore
                in      al,61h
                or      al,3
                out     61h,al
                mov     al,90h
                out     43h,al
@@NoRestore:    test    PICmask[ebx],10000000b
IRQpatch5       equ     byte ptr $-1
                jne     @@IRQ7_masked
                cmp     DoAnIRQ[ebx],1
                je      LastSBbyte
@@IRQ7_masked:  mov     DoAnIRQ[ebx],0
                pop     ds
                pop     ebx
                pop     eax
                db      0EAh            ; JMP FAR
old0offset      dd      ?
old0selector    dw      ?

LastDMAbyte:    call    near ptr @@LastDMA
                jmp     @@contIRQ0
@@LastDMA:      mov     al,0
                cmp     AutoInit[ebx],al
                je      @@TurnOff
                mov     ax,word ptr DMAch1count[ebx]
                mov     DMAcounter[ebx],ax
                movzx   ax,byte ptr DMAch1page[ebx]
                shl     eax,16
                mov     ax,word ptr DMAch1ad[ebx]
                add     eax,12345678h
DeltaPhysical1  equ     dword ptr $-4
                mov     SampleOffs[ebx],eax
                mov     al,1
@@TurnOff:      test    al,al
                mov     ax,word ptr PatchData1[ebx]
                je      @@Off
                cmp     SBcounter[ebx],0FFFFh
                jne     @@ldb1
                inc     word ptr SBcounter[ebx]
@@ldb1:         cmp     DMAcounter[ebx],0FFFFh
                jne     @@ldb2
                inc     word ptr DMAcounter[ebx]
@@ldb2:         mov     ax,word ptr PatchData2[ebx]
@@Off:          mov     word ptr EnablePatch[ebx],ax
                retn

LastSBbyte:     mov     DoAnIRQ[ebx],1
                mov     Counter[ebx],-1

                mov     ax,word ptr PatchData1[ebx]
                mov     word ptr EnablePatch[ebx],ax

                test    PICmask[ebx],10000000b
IRQpatch6       equ     byte ptr $-1
                jne     @@DecDMA
                sub     DMAcounter[ebx],1
                jnc     @@SkipDMA
                call    near ptr @@LastDMA
@@SkipDMA:      mov     DoAnIRQ[ebx],0
                mov     al,60h
                out     20h,al
                mov     Port020[ebx],8007h
IRQpatch1       equ     word ptr $-2
                pop     esi
                pop     edx
                pop     ds
                pop     ebx
                pop     eax
                int     0Fh
irqpatch3       equ     byte ptr $-1
                iretd
IRQ0entry       endp

Code32          ends

Zcode16         segment dword use16
                assume  cs:Zcode16, ds:Acode16

SettleBus       macro
                out     0EEh,ax
                endm

UntrappedIn     macro
                mov     ax,1A00h
                call    QEMM_API
                endm

UntrappedOut    macro
                mov     ax,1A01h
                call    QEMM_API
                endm

CodeSegment     dw      ?
QEMM_API        dd      ?
OLD_CALLBACK    dd      ?
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
PatchData2:     push    dx
                push    si
PatchIRQ:       shr     al,1
                out     42h,al
                nop
CovoxPatch:     db      66h
                mov     dx,5FE0h
DACport         equ     word ptr $-2
                out     dx,al

; AL = 1 - enable; 0 - disable DMA
EnableDMA       proc    near
                push    bx
                mov     bx,word ptr PatchData1
                or      al,al
                je      @@DMAOff
                cmp     SBcounter,0FFFFh
                jne     @@DMASub1
                inc     SBcounter
@@DMASub1:      cmp     DMAcounter,0FFFFh
                jne     @@DMASub2
                inc     DMAcounter
@@DMASub2:      mov     bx,word ptr PatchData2
@@DMAOff:       mov     word ptr EnablePatch,bx
                pop     bx
                ret
EnableDMA       endp

; 1 - Enable sound; 0 - disable sound
EnableSB        proc    near
                push    eax
                push    bx
                or      al,al
                mov     eax,90909090h
                mov     bl,90h
                je      @@Set
                mov     eax,dword ptr PatchIRQ
                mov     bl,byte ptr PatchIRQ + 4
@@Set:          mov     dword ptr DACpatch,eax
                mov     byte ptr DACpatch+4,bl
                pop     bx
                pop     eax
                ret
EnableSB        endp

; NOTE: DESTROYS DX!
SetTimerFreq    proc    near
                push    ax
                push    bx
                mov     TimerFreq,ax

                mov     ax,IRQ0freq
                cmp     ax,MinTimerFreq
                ja      @@freqOK
                mov     ax,MinTimerFreq
@@freqOK:       or      ax,ax
                jne     @@NoZero
                mov     ax,TimerFreq
                jmp     @@PutRes
@@NoZero:       mov     bx,ax
                mov     dx,TimerFreq
                xor     ax,ax
                cmp     dx,bx
                jae     @@Overflow
                div     bx
@@PutRes:       mov     Int8Coeff,ax
                mov     dx,43h
                mov     bl,36h
                untrappedOut
                mov     bx,TimerFreq
                mov     dl,40h
                untrappedOut
                mov     bl,bh
                untrappedOut
                pop     bx
                pop     ax
                ret
@@Overflow:     dec     ax
                mov     IRQ0freq,bx
                mov     TimerFreq,bx
                jmp     @@PutRes
SetTimerFreq    endp

QEMMcallback    proc    far
                push    ds
                push    bx

                assume  CS:ACode16
                mov     ds,cs:CodeSegment
                assume  CS:Zcode16
                test    cl,cl
                jz      @@input

                push    ax
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
                cmp     dx,21h
                jne     @@OldCallBack
                mov     PICmask,al
                pop     ax
                and     al,0FEh
                push    ax
@@OldCallBack:  pop     ax
                pop     bx
                pop     ds
                assume  CS:ACode16
                jmp     cs:OLD_CALLBACK
                assume  CS:Zcode16

@@PICCR:        mov     bl,al
                and     al,06Eh
                cmp     al,00Ah
                jne     @@PICCR_1
                test    bl,1
                mov     ax,9090h
                je      @@PICCR_0
                mov     ax,word ptr @@SelfMod
@@PICCR_0:      mov     word ptr Port020sm,ax
                mov     ICRoffset,offset ds:ICRread
                jmp     @@PICCR_2
@@PICCR_1:      mov     word ptr Port020,0
@@PICCR_2:      pop     ax
                pop     bx
                pop     ds
                assume  CS:ACode16
                jmp     cs:OLD_CALLBACK
                assume  CS:Zcode16
@@SelfMod:      mov     al,ah

@@Timer_Control:test    al,11000000b
                jne     @@OldCallBack
                mov     FlipFlop,0
                pop     ax
                pop     bx
                pop     ds
                retf

@@Timer_Ch0:    and     FlipFlop,1
                movzx   bx,FlipFlop
                inc     FlipFlop
                mov     byte ptr IRQ0Freq[bx],al
                or      bx,bx
                je      @@TCH0_1
                push    dx
                mov     ax,TimerFreq
                call    SetTimerFreq
                pop     dx
@@TCH0_1:       pop     ax
                pop     bx
                pop     ds
                retf

SBport:         cmp     dx,0388h
                jae     @@AdlibPort
@@HandleSB:     cmp     dx,022Fh
                ja      @@oldCallBack
                movzx   bx,dl
                shl     bx,1
                jmp     OUTJumpTable[bx-40h]
@@AdlibPort:    cmp     dx,0389h
                ja      @@oldCallBack
                cmp     SlowAdlib,1
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
                pop     ax
                pop     bx
                pop     ds
                retf
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
In22D           label   near
In22F           label   near
                mov     al,0
                pop     bx
                pop     ds
                retf

In228           label   near
                mov     al,0
Port228         equ     byte ptr $-1
                pop     bx
                pop     ds
                retf

In22A           label   near
                mov     al,0AAh
port22Acontents equ     byte ptr $-1
                mov     port22Acontents,0AAh
                pop     bx
                pop     ds
                retf

In22A_E1a:      mov     al,01                   ; High byte of version No
                mov     In22Aoffs,offset ds:In22A_E1b
                pop     bx
                pop     ds
                retf

In22A_E1b:      mov     al,10                   ; Low byte of version No
                mov     In22Aoffs,offset ds:In22A
                pop     bx
                pop     ds
                retf

In22C           label   near
In22E           label   near
                mov     al,0
Port22E         equ     byte ptr $-1
                xor     Port22E,080h
                mov     DoAnIRQ,0
                mov     Port020,0
                pop     bx
                pop     ds
                retf

Out226          label   near
                mov     al,0
                call    EnableDMA
                mov     Out22Coffs,offset ds:Out22Ca
                mov     DoAnIRQ,al
                mov     Phase_E2,al
                pop     ax
                pop     bx
                pop     ds
                retf

Out228          label   near
                mov     Command228,al
                pop     ax
                pop     bx
                pop     ds
                retf

Out229          label   near                    ; Ignore RegNo; only data
                mov     ah,0
Command228      equ     byte ptr $-1
                cmp     ah,4
                jne     @@229_Done
                test    al,10000000b
                jne     @@229_Reset
                test    al,1
                jne     @@229_Set
@@229_Reset:    mov     Port228,0
                pop     ax
                pop     bx
                pop     ds
                retf
@@229_Set:      and     al,060h
                xor     al,0E0h
                mov     Port228,al
@@229_Done:     pop     ax
                pop     bx
                pop     ds
                retf

Out22Ca         label   near
                cmp     al,010h
                je      @@22C_10
                mov     Command,al
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
                pop     ax
                pop     bx
                pop     ds
                retf

@@22C_10:       mov     Out22Coffs,offset ds:@@22C_10a
                pop     ax
                pop     bx
                pop     ds
                retf

@@22C_14:       mov     Out22Coffs,offset ds:@@22C_14a
                pop     ax
                pop     bx
                pop     ds
                retf

@@22C_D0:       mov     al,0
                call    EnableDMA
                pop     ax
                pop     bx
                pop     ds
                retf

@@22C_D1:       mov     al,1
                call    EnableSB
                pop     ax
                pop     bx
                pop     ds
                retf

@@22C_D3:       mov     al,0
                call    EnableSB
                pop     ax
                pop     bx
                pop     ds
                retf

@@22C_D4:       mov     al,1
                call    EnableDMA
                pop     ax
                pop     bx
                pop     ds
                retf

@@22C_E1:       mov     In22Aoffs,offset ds:In22A_E1a
                jmp     @@CommandOK

@@22C_E2:       mov     Out22Coffs,offset ds:@@22C_E2a
                pop     ax
                pop     bx
                pop     ds
                retf

@@22C_F2:       mov     DoAnIRQ,0
                mov     Port020,8007h
IRQpatch2       equ     word ptr $-2
                int     0Fh                     ; Generate an IRQ7
IRQpatch4       equ     byte ptr $-1
                pop     ax
                pop     bx
                pop     ds
                retf

@@22Ca_OK:      mov     Out22Coffs,offset ds:Out22Cb
                pop     ax
                pop     bx
                pop     ds
                retf

@@22Cb_OK:      mov     Out22Coffs,offset ds:Out22Ca
                pop     ax
                pop     bx
                pop     ds
                retf

Out22Cb         label   near
                mov     ah,0
Command         equ     byte ptr $-1
                cmp     ah,040h
                je      @@22C_40
                cmp     ah,0E0h
                je      @@22C_E0
                jmp     @@CommandOK
@@22C_10a:      mov     dx,DACport
                out     dx,al
@@CommandOK:    mov     Out22Coffs,offset ds:Out22Ca
                pop     ax
                pop     bx
                pop     ds
                retf

@@22C_14a:      mov     byte ptr SBDMAcount,al
                mov     Out22Coffs,offset ds:@@22C_14b
                pop     ax
                pop     bx
                pop     ds
                retf

@@22C_14b:      mov     byte ptr SBDMAcount+1,al
                mov     Out22Coffs,offset ds:Out22Ca

                mov     ax,word ptr PatchData1
                mov     word ptr EnablePatch,ax ; Disable DMA

                mov     ax,word ptr SBDMAcount
                cmp     ax,1
                ja      @@NotTest
                mov     al,010h                 ; Give to emulator a chance
                mov     DMAcounter,ax
@@NotTest:      mov     SBcounter,ax
                mov     al,1
                call    EnableDMA
                pop     ax
                pop     bx
                pop     ds
                retf

@@22C_40:       push    dx
                not     al
                mov     ah,120
                mul     ah
                xor     dx,dx
                mov     bx,108
                div     bx
                cmp     ax,MinIRQfreq
                ja      @@22C_40_1
                mov     ax,MinIRQfreq
@@22C_40_1:     call    SetTimerFreq
                pop     dx
                jmp     @@CommandOK

@@22C_E0:       not     al
                mov     port22Acontents,al
                jmp     @@CommandOK

@@22C_E2a:      xor     Phase_E2,1
                je      @@Phase2
                mov     ah,al
                and     ax,016E9h
                sub     al,ah
                add     al,40h
                mov     PrevE2,al
                jmp     @@E2done
@@Phase2:       xor     al,0A5h
                add     al,PrevE2
@@E2done:       push    si
                push    es
                push    eax
                mov     eax,SampleOffs
                mov     si,ax
                and     si,000Fh
                shr     eax,4
                mov     es,ax
                pop     eax
                mov     es:[si],al
                mov     al,IncDecPatch
                and     al,8
                mov     ah,IncDecPatch1
                and     ah,not 8
                or      al,ah
                mov     IncDecPatch1,al
                inc     word ptr SampleOffs
IncDecPatch1    equ     byte ptr $-3
                pop     es
                pop     si
                jmp     @@CommandOK

Out22E          label   near
                mov     DoAnIRQ,0
                pop     ax
                pop     bx
                pop     ds
                retf

OUTJumpTable    dw      offset ds:Out220,offset ds:Out221
                dw      offset ds:Out222,offset ds:Out223
                dw      offset ds:Out224,offset ds:Out225
                dw      offset ds:Out226,offset ds:Out227
                dw      offset ds:Out228,offset ds:Out229
                dw      offset ds:Out22A,offset ds:Out22B
Out22Coffs      dw      offset ds:Out22Ca,offset ds:Out22D
                dw      offset ds:Out22E,offset ds:Out22F

INJumpTable     dw      offset ds:In220, offset ds:In221
                dw      offset ds:In222, offset ds:In223
                dw      offset ds:In224, offset ds:In225
                dw      offset ds:In226, offset ds:In227
                dw      offset ds:In228, offset ds:In229
In22Aoffs       dw      offset ds:In22A, offset ds:In22B
                dw      offset ds:In22C, offset ds:In22D
                dw      offset ds:In22E, offset ds:In22F

DMAport:        movzx   bx,dl
                shl     bx,1
                jmp     DMAOUTJumpTable[bx]

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
                pop     ax
                pop     bx
                pop     ds
                assume  CS:ACode16
                jmp     cs:OLD_CALLBACK
                assume  CS:Zcode16

Out2:           movzx   bx,byte ptr DMAflipFlop
                xor     byte ptr DMAflipFlop,1
                mov     byte ptr DMAch1ad[bx],al
                pop     ax
                pop     bx
                pop     ds
                retf

Out3:           movzx   bx,byte ptr DMAflipFlop
                xor     byte ptr DMAflipFlop,1
                mov     byte ptr DMAch1count[bx],al
                pop     ax
                pop     bx
                pop     ds
                retf

OutA:           mov     ah,al
                and     ah,3
                cmp     ah,1
                jne     OutF
                and     al,4
                xor     al,4
                je      @@OutA_1
                mov     ax,0FFFFh
                cmp     ReadWrite,0
                jne     @@SetCnt
                mov     ax,DMAch1count
@@SetCnt:       mov     DMAcounter,ax
                push    eax
                movzx   ax,byte ptr DMAch1page
                shl     eax,16
                mov     ax,word ptr DMAch1ad
                add     eax,12345678h
DeltaPhysical2  equ     dword ptr $-4
                mov     SampleOffs,eax
                pop     eax
@@OutA_1:       pop     ax
                pop     bx
                pop     ds
                retf

OutB            label   near
                mov     ah,al
                and     ah,3
                cmp     ah,1
                jne     OutF
                mov     ah,al
                and     ah,00010000b
                mov     AutoInit,ah
                mov     ah,al
                and     ah,00100000b
                shr     ah,2
                and     IncDecPatch,not 8
                or      IncDecPatch,ah
                and     al,00000100b
                mov     ReadWrite,al
                pop     ax
                pop     bx
                pop     ds
                retf

OutC:           mov     DMAflipFlop,0
                pop     ax
                pop     bx
                pop     ds
                assume  CS:ACode16
                jmp     cs:OLD_CALLBACK
                assume  CS:Zcode16

DMAOUTjumpTable dw      offset ds:Out0, offset ds:Out1
                dw      offset ds:Out2, offset ds:Out3
                dw      offset ds:Out4, offset ds:Out5
                dw      offset ds:Out6, offset ds:Out7
                dw      offset ds:Out8, offset ds:Out9
                dw      offset ds:OutA, offset ds:OutB
                dw      offset ds:OutC, offset ds:OutD
                dw      offset ds:OutE, offset ds:OutF
DMAINjumpTable  dw      offset ds:In00, offset ds:In01
                dw      offset ds:In02, offset ds:In03
                dw      offset ds:In04, offset ds:In05
                dw      offset ds:In06, offset ds:In07
                dw      offset ds:In08, offset ds:In09
                dw      offset ds:In0A, offset ds:In0B
                dw      offset ds:In0C, offset ds:In0D
                dw      offset ds:In0E, offset ds:In0F
                dw      ?,?                             ;10h/11h
                dw      ?,?                             ;12h/13h
                dw      ?,?                             ;14h/15h
                dw      ?,?                             ;16h/17h
                dw      ?,?                             ;18h/19h
                dw      ?,?                             ;1Ah/1Bh
                dw      ?,?                             ;1Ch/1Dh
                dw      ?,?                             ;1Eh/1Fh
ICRoffset       dw      offset ds:DirectRead

DMApage:        mov     DMAch1page,al
                pop     ax
                pop     bx
                pop     ds
                retf

@@input:        cmp     dx,220h
                jb      DMAread

                cmp     dl,88h
                jae     @@AdlibRead
@@ReadSB:       movzx   bx,dl
                shl     bx,1
                jmp     INJumpTable[bx-40h]
@@AdlibRead:    cmp     SlowAdlib,1
                je      DirectRead
                sub     dx,(388h-228h)
                jmp     @@ReadSB

ICRread:        mov     ax,0
Port020         equ     word ptr $-2
Port020sm:      mov     al,ah
                mov     ICRoffset,offset ds:DirectRead
                or      al,al
                je      DirectRead
                pop     bx
                pop     ds
                retf

DMAread:        cmp     dl,20h
                ja      NotInTable

                movzx   bx,dl
                shl     bx,1
                jmp     DMAINJumpTable[bx]

In02:           movzx   bx,byte ptr DMAflipFlop
                xor     byte ptr DMAflipFlop,1
                mov     al,byte ptr SampleOffs[bx]
                pop     bx
                pop     ds
                retf

In03:           movzx   bx,byte ptr DMAflipFlop
                xor     byte ptr DMAflipFlop,1
                mov     al,byte ptr DMAcounter[bx]
                pop     bx
                pop     ds
                retf

NotInTable:     cmp     dx,83h
                je      @@GetDMApage
                cmp     dx,40h
                jne     DirectRead
                mov     al,0
p43c            equ     byte ptr $-1
                add     p43c,104
                xor     p43c,0DEh
                rol     p43c,14
                pop     bx
                pop     ds
                retf

@@GetDMApage:   mov     al,DMAch1page
                pop     bx
                pop     ds
                retf

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
DirectRead:     pop     bx
                pop     ds
                assume  CS:ACode16
                jmp     cs:OLD_CALLBACK
                assume  CS:Zcode16
QEMMcallback    endp

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
@@BadOption:    mov     dx,offset BadOption
                jmp     PrintAndExit

@@PrintHelp:    mov     dx,offset HelpText
                jmp     PrintAndExit

@@Speaker:      inc     Speaker
                jmp     @@NextChar

@@Adlib:        sub     nPorts,2 ; was `mov nPorts,nCaughtPorts - 2`, but WASM doesn't support forward EQU references
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
CheckCmdLine    endp

SetupRoutines   proc    near
                mov     CodeSegment,cs

                mov     ah,3Fh
                mov     cx,5145h        ; 'QE'
                mov     dx,4D4Dh        ; 'MM'
                int     67h
                or      ah,ah
                jnz     @@noQEMM
                mov     word ptr QEMM_API + 2,es
                mov     word ptr QEMM_API,di
                call    CheckPosition
                mov     ah,0
                call    QEMM_API
                test    al,1            ; Bit 0 - ON/OFF: 1 - AUTO mode
                jnz     @@QEMMoff
                mov     ax,1A06h
                call    QEMM_API
                mov     word ptr OLD_CALLBACK+2,es
                mov     word ptr OLD_CALLBACK,di

                mov     cx,nPorts
                mov     si,offset CaughtPorts

; Check if ports are already watched
@@check:        lodsw
                cmp     ax,220h
                jb      @@skipIt                ; QEMM itself watches them
                xchg    dx,ax
                mov     ax,1A08h
                call    QEMM_API
                or      bl,bl
                jnz     @@portBusy
@@skipIt:       loop    @@check

                mov     cx,nPorts
                mov     si,offset CaughtPorts

@@catch:        lodsw
                xchg    dx,ax
                mov     ax,1A09h
                call    QEMM_API
                loop    @@catch

                mov     ax,1A07h
                push    cs
                pop     es
                mov     di,offset QEMMcallback
                call    QEMM_API

                in      al,61h
                and     al,11111100b
                out     61h,al
                cmp     Speaker,0
                jne     @@NoChange
                mov     eax,dword ptr CovoxPatch
                mov     dword ptr DACpatch,eax
                mov     dword ptr PatchIRQ,eax
                mov     al,byte ptr CovoxPatch+4
                mov     byte ptr DACpatch+4,al
                mov     byte ptr PatchIRQ+4,al
@@NoChange:     mov     ax,TimerFreq
                call    SetTimerFreq

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
                call    SetupInts               ; Setup IRQ0
                retn

@@noQEMM:       mov     dx,offset msgNoQEMM
                jmp     PrintAndExit

@@QEMMoff:      mov     dx,offset msgQEMMoff
                jmp     PrintAndExit

@@portBusy:     mov     dx,offset msgPortBusy
                jmp     PrintAndExit

SetupRoutines   endp

SetupInts       proc    near
                mov     ax,0DE00h
                int     67h                     ; Check VCPI ready
                test    ah,ah
                jnz     @@noVCPI
                mov     ax,0DE0Ah
                int     67h
                test    ah,ah
                jnz     @@noVCPI
                cmp     bx,8
                jne     @@PICbusy

                call    FindPhysMemory
                xor     bx,bx
                call    GetLinearAddr
                mov     DataLinearAddr,eax
                call    FindQEMMIDT
                mov     bx,small offset irq0entry
                call    SetIRQ0address

                ret

@@noVCPI:       mov     dx,offset msgNoVCPI
                jmp     PrintAndExit

@@PICbusy:      mov     dx,offset msgPICbusy
                jmp     PrintAndExit

FindQEMMIDT     proc    near
                sidt    QEMMidt
                mov     ecx,dword ptr QEMMidt + 2
                shr     ecx,12
                mov     ax,0DE06h               ; Get REAL page address
                int     67h
                movzx   eax,word ptr QEMMidt + 2
                and     ah,0Fh
                add     eax,edx
                mov     QEMMIDTaddr,eax
                ret
FindQEMMIDT     endp

FindPhysMemory  proc    near
                mov     bx,offset Buffer+4
                mov     cx,255
@@scanPBR:      push    cx
                push    bx
                mov     eax,cr3
                mov     esi,eax
                mov     bx,offset Buffer
                call    GetLinearAddr
                mov     edi,eax
                push    edi
                mov     cx,256 * 8
                call    MoveXM
                pop     edi
                pop     bx
                push    bx
                mov     eax,[bx]
                and     ax,0F000h
                test    eax,eax
                jz      @@empty
                mov     esi,eax
                mov     cx,16*8
                call    MoveXM

                mov     eax,dword ptr Buffer
                and     ax,0F000h
                test    eax,eax
                jz      @@foundPhys
@@empty:        pop     bx
                pop     cx
                add     bx,4
                loop    @@scanPBR
                mov     bx,offset Buffer
                push    cx
                push    bx
@@foundPhys:    pop     bx
                pop     cx
                sub     bx,offset Buffer
                movzx   ebx,bx
                shl     ebx,20
                mov     DeltaPhysical1,ebx
                mov     DeltaPhysical2,ebx
                ret
FindPhysMemory  endp

SetIRQ0address  proc    near
                call    GetLinearAddr
                push    eax
                mov     esi,QEMMIDTaddr
                mov     bx,offset Buffer
                call    GetLinearAddr
                mov     edi,eax
                mov     cx,16 * 8
                call    MoveXM
                mov     bx,offset Buffer + 8 * 8
                mov     ax,[bx + 6]
                shl     eax,16
                mov     ax,[bx]
                mov     old0offset,eax
                mov     ax,[bx+2]
                mov     old0selector,ax
                pop     eax
                mov     word ptr [bx],ax
                shr     eax,16
                mov     word ptr [bx+6],ax
                mov     bx,offset Buffer
                call    GetLinearAddr
                mov     esi,eax
                mov     edi,QEMMIDTaddr
                mov     cx,16 * 8
                call    MoveXM
                ret
SetIRQ0address  endp

GetLinearAddr   proc    near
                xor     ecx,ecx
                mov     cx,ds
                shr     ecx,8
                mov     ax,0DE06h               ; Get REAL page address
                int     67h
                movzx   ebx,bx
                add     edx,ebx
                mov     ax,ds
                and     eax,0FFh
                shl     eax,4
                add     eax,edx
                ret
GetLinearAddr   endp

; IN: ESI   = source address
;     EDI   = dest address
;     CX    = counter
MoveXM          proc    near
                or      esi,93000000h
                or      edi,93000000h
                mov     dword ptr DescTable + 18,esi
                mov     dword ptr DescTable + 26,edi
                mov     si,offset DescTable
                shr     cx,1
                mov     ah,87h
                mov     si,offset DescTable
                push    ds
                pop     es
                int     15h
                ret

DescTable       label   near
rept    6
                dw      0FFFFh
                dd      0
                db      08Fh
                db      0
endm
MoveXM          endp

SetupInts       endp

CheckPosition   proc    near
                mov     bx,small offset irq0entry
                call    GetLinearAddr
                xor     ebx,ebx
                mov     bx,cs
                shl     ebx,4
                add     ebx,large offset irq0entry
                cmp     eax,ebx
                je      @@ok
                mov     dx,offset msgMapped
                jmp     PrintAndExit
@@ok:           ret
CheckPosition   endp

Init:           call    CheckCmdLine
                call    SetupRoutines
                mov     ah,9
                mov     dx,offset Header
                int     21h
                mov     dx,offset LastByte
                int     27h                     ; Stay resident

PrintAndExit:   mov     ah,9
                int     21h
                int     20h

                include s386data.asm

;                NOWARN  ALN
                align 4
QEMMidt         dq      ?
QEMMIDTaddr     dd      ?
Buffer          db      16 * 8 dup (?)

CaughtPorts     dw      02h,03h
                dw      0Ah,0Bh,0Ch
                dw      20h,21h
                dw      40h,43h
                dw      83h
                dw      226h,228h,229h,22Ah,22Ch,22Eh
                dw      388h,389h

nCaughtPorts    equ     ($ - offset CaughtPorts) / 2
nPorts          dw      nCaughtPorts

msgNoQEMM       db      '■─[ VSB ]──────────────────────────[ Error ]─■',0Dh,0Ah
                db      '│Incompatible memory manager - QEMM v7.0+ req│',0Dh,0Ah
                db      '■────────────────────────────────────────────■',0Dh,0Ah,'$'
msgQEMMoff      db      '■─[ VSB ]──────────────────────────[ Error ]─■',0Dh,0Ah
                db      '│    QEMM is turned off - enable it first    │',0Dh,0Ah
                db      '■────────────────────────────────────────────■',0Dh,0Ah,'$'
msgPortBusy     db      '■─[ VSB ]──────────────────────────[ Error ]─■',0Dh,0Ah
                db      '│ VSB is already loaded - reboot to unload it│',0Dh,0Ah
                db      '■────────────────────────────────────────────■',0Dh,0Ah,'$'
msgPICbusy      db      '■─[ VSB ]──────────────────────────[ Error ]─■',0Dh,0Ah
                db      '│ A VCPI client already changed PIC mappings │',0Dh,0Ah
                db      '■────────────────────────────────────────────■',0Dh,0Ah,'$'
msgNoVCPI       db      '■─[ VSB ]──────────────────────────[ Error ]─■',0Dh,0Ah
                db      '│         VCPI interface not detected        │',0Dh,0Ah
                db      '■────────────────────────────────────────────■',0Dh,0Ah,'$'
msgMapped       db      '■─[ VSB ]──────────────────────────[ Error ]─■',0Dh,0Ah
                db      '│Cannot load VSB into mapped memory (i.e.UMB)│',0Dh,0Ah
                db      '■────────────────────────────────────────────■',0Dh,0Ah,'$'

Zcode16         ends

                end     Start
