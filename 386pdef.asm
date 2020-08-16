;░▒▓█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█▓▒░
;░▒▓█                 A i386(R) protected mode library                    █▓▒░
;░▒▓█               (C)opyright 1993 by FRIENDS software                  █▓▒░
;░▒▓█                     Equates and definitions                         █▓▒░
;░▒▓█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█▓▒░

                locals  @@

TopInt          equ     3Fh       ; Number of interrupt gates in IDT
PL0stack        equ     64        ; PL0 stack size
VM86stack       equ     1         ; VM86 task stack size
ESPstack        equ     16        ; Stack into which are pushed PL0 ESPs
;Debug           equ     1         ; Set to 0 to disable debug dumping
StartIOPL       equ     3000h     ; Start I/O priviledge level
PMinterrupts    equ     0         ; Set to 0 if in protected mode interrupts
                                  ; are disabled - everything will work faster
                                  ; Note: PM interrupts are non-functional
                                  ; now - must be debugged & changed hw handler

;*********************** Descriptor flags EQUates ****************************
df4GbLimit      equ     10001111b ; +6
dfUse32         equ     01000000b ; +6
dfPresent       equ     10000000b ; +5
dfDPL3          equ     01100000b ; +5
dfDPL2          equ     01000000b ; +5
dfDPL1          equ     00100000b ; +5
dfDPL0          equ     00000000b ; +5
dfNoSystem      equ     00010000b ; +5
dfExecutable    equ     00001000b ; +5
dfExpandDown    equ     00000100b ; +5
dfConforming    equ     00000100b ; +5
dfWriteable     equ     00000010b ; +5
dfReadable      equ     00000010b ; +5
dfTSSbusy       equ     00000010b ; +5
dfAccessed      equ     00000001b ; +5

dfTrapGate386   equ     00001111b ; +5
dfIntGate386    equ     00001110b ; +5
dfCallGate386   equ     00001100b ; +5
dfTSS386        equ     00001001b ; +5
dfTrapGate286   equ     00000111b ; +5
dfIntGate286    equ     00000110b ; +5
dfTaskGate386   equ     00000101b ; +5
dfCallGate286   equ     00000100b ; +5
dfLDT386        equ     00000010b ; +5
dfTSS286        equ     00000001b ; +5

;************************ Usual flags combination ****************************
dfCode          equ     dfPresent or dfDPL0 or dfNoSystem or dfExecutable or dfReadable
dfData          equ     dfPresent or dfDPL0 or dfNoSystem or dfWriteable
dfStack         equ     dfPresent or dfDPL0 or dfNoSystem or dfExpandDown or dfWriteable
dfLDT           equ     dfPresent or dfDPL0 or dfLDT386
dfTaskGate      equ     dfPresent or dfDPL0 or dfTaskGate386
dfIntGate       equ     dfPresent or dfDPL0 or dfIntGate386
dfCallGate      equ     dfPresent or dfDPL0 or dfCallGate386
dfTSS           equ     dfPresent or dfDPL0 or dfTSS386

;*********************** 386 Descriptor structure ****************************
Desc386         struc
SegLimit        dw      ?       ; limit bits (0..15)
Base0to15       dw      ?       ; base bits (0..15)
Base16to23      db      ?       ; base bits (16..23)
AccessRights    db      ?       ; access rights byte
Granularity     db      ?       ; granularity & default op. size
Base24to31      db      ?       ; base bits (24..31)
Desc386         ends

;********************* LGDT & LIDT operand structure *************************
DT386           struc
TableSize       dw      ?
TableAddr       dd      ?
DT386           ends

;************************ Macro to create a GDT entry ************************
GDToffset       =       0

GDTdescr        macro   Name,DFlags,Granularity
Name:           Desc386 <0FFFFh,,,DFlags,Granularity>
@&Name          =       GDToffset
GDToffset       =       GDToffset+8
                endm

;************************ Macro to create a IDT entry ************************
IDToffset       =       0

IDTdescr        macro   Name,IntOffs,DFlags
Name:           Desc386 <small IntOffs,@gdCode,,DFlags>
@&Name          =       IDToffset
IDToffset       =       IDToffset+8
                endm

;************************ TSS structure definition ***************************
TSSblk          struc
TSSlink         dd      ?
TSSespP0        dd      ?
TSSssP0         dd      ?
TSSespP1        dd      ?
TSSssP1         dd      ?
TSSespP2        dd      ?
TSSssP2         dd      ?
TSScr3          dd      ?
TSSeip          dd      ?
TSSeflags       dd      ?
TSSeax          dd      ?
TSSecx          dd      ?
TSSedx          dd      ?
TSSebx          dd      ?
TSSesp          dd      ?
TSSebp          dd      ?
TSSesi          dd      ?
TSSedi          dd      ?
TSSes           dd      ?
TSScs           dd      ?
TSSss           dd      ?
TSSds           dd      ?
TSSfs           dd      ?
TSSgs           dd      ?
TSSldt          dd      ?
                dw      ?
TSSiomap        dw      ?
TSSblk          ends

;*****************************************************************************
; Call interrupt 30h with ES:EBX pointing to a parameter block
; with this structure:
i30ParmBlock    struc         ; +00 flag - if 1 then resave es, ds, fs & gs
i30Flag         dd      ?     ; into parameter block after call
i30IntNo        db      ?     ; +04 int number (0-255)   (required)
                db      ?,?,?
i30Eflags       dd      ?     ; +08 eflags               (required)
i30ESP          dd      ?     ; +12 vm86 esp             (required)
i30SS           dd      ?     ; +16 vm86 ss              (required)
i30ES           dd      ?     ; +20 vm86 es
i30DS           dd      ?     ; +24 vm86 ds
i30FS           dd      ?     ; +28 vm86 fs
i30GS           dd      ?     ; +32 vm86 gs
i30EBP          dd      ?     ; +36 vm86 ebp  ( to replace that used in call )
i30EBX          dd      ?     ; +40 vm86 ebx  ( to replace that used in call )
                ends
; all other registers will be passed to vm86 routine
;*****************************************************************************

;************* Set descriptor begin to point to a specified address **********
SetAddr         macro   Descriptor,NearLabel
                xor     eax,eax
                mov     ax,cs
                shl     eax,4
                add     eax,large offset NearLabel
                mov     Descriptor.Base0to15,ax
                shr     eax,16
                mov     Descriptor.Base16to23,al
                endm

;************************* Wait bus to settle down ***************************
SettleBus       macro
                jmp     short $+2
                endm
