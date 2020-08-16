;░▒▓█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█▓▒░
;░▒▓█                 A i386(R) protected mode library                    █▓▒░
;░▒▓█               (C)opyright 1993 by FRIENDS software                  █▓▒░
;░▒▓█                   Descriptor tables (GDT & IDT)                     █▓▒░
;░▒▓█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█▓▒░

;********************* Global Descriptor Table (GDT) *************************
; NULL descriptor
                GDTdescr GDT
; Supervisor code segment
                GDTdescr gdCode,dfCode
; Supervisor data segment
                GDTdescr gdData,dfData
; Flat segment (with zero base and 4Gb limit) descriptor
                GDTdescr gdFlat,dfData,df4GbLimit
; Video segment descriptor
                GDTdescr gdVideo,dfData
; TSS itself
                GDTdescr gdTSS,dfTSS

GDTlen          equ      $-GDT

;******************* Interrupt descriptor table (IDT) ************************
IDTentry        =        0
IDT             label    near
                rept     TopInt+1
                IDTdescr idInt%IDTentry,Int%IDTentry,dfIntGate
IDTentry        =        IDTentry+1
                endm
IDTlen          equ      $-IDT
