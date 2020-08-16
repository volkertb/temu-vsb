;░▒▓█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█▓▒░
;░▒▓█                 A i386(R) protected mode library                    █▓▒░
;░▒▓█               (C)opyright 1993 by FRIENDS software                  █▓▒░
;░▒▓█                     Supervisor data segment                         █▓▒░
;░▒▓█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█▓▒░

Color           db      03h                     ;Text color
IntSP           dw      offset PSESP            ;Pseudo-stack pointer
IntState        db      2                       ;Interrupts state
IntMask1        db      ?                       ;Saved port[21h]
IntMask2        db      ?                       ;Saved port[A1h]
SavedIDT        dq      ?                       ;Saved from real mode IDT
Cursor          dw      ?                       ;Cursor address
RMESP           dd      ?                       ;Saved from real mode ESP
RMSS            dw      ?                       ;Saved from real mode SS
DumpSelc        dw      ?                       ;Selector for dump
DumpOffs        dd      ?                       ;Dump offset
DumpSize        dw      ?                       ;Dump size
Temp1           dd      ?                       ;Four
Temp2           dd      ?                       ; temporary
Temp3           dd      ?                       ;  variables
Temp4           dd      ?                       ;   for ISRs
;*************************** Debug dump messages *****************************
UnexpInt        db      '───═══■ Debug interrupt ■═══───',13,10,0
TaskMsg         db      'TR=',0
UnexpMsg        db      ' INT=',0
StackMsg        db      'Stack:',0
RTable          db      'GFDES'
GTable          db      'DISIBPSPBXDXCXAX'
MemMsg          db      'Memory dump; Selector=',0
GPFmsg          db      'GPF; opcode = ',0
IntController   db      'Interrupt controller #'
IntContNo       db      '1 mask = ',0

HIntFrame       i30ParmBlock <>                 ; Local interface structure

DTload          DT386   <>
TaskSegment     TSSblk  <,,,,,,,,,,,,,,,,,,,,,,,,,,offset IOportMap-offset TaskSegment>
IOportMap       db      8192 dup (0)
IOmapEnd        db      0                       ;End of IOportMap
                                                ;Theoretically speaking it
                                                ;must be 255, but who cares...
                NOWARN  ALN
                align   4
                WARN    ALN
; Stack for VM86 task
                dd      VM86Stack dup (?)
VM86SP          label   near
; here is where vm86 int's stack up pl0 esp's
                dd      PL0stack dup (?)
P0ESP           label   near
                dd      ESPstack dup (?)
PSESP           label   near
