;░▒▓█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█▓▒░
;░▒▓█                 A i386(R) protected mode library                    █▓▒░
;░▒▓█               (C)opyright 1993 by FRIENDS software                  █▓▒░
;░▒▓█                           Real-mode data                            █▓▒░
;░▒▓█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█▓▒░

CPUerror:       db      '■─────── This program requires an i386 or higher ───────■',0Dh,0Ah,'$'
AlreadyV86:     db      '■───── Processor already running in protected mode ─────■',0Dh,0Ah
                db      '│    Seem that you have a 386 extended memory manager   │',0Dh,0Ah
                db      '│   such as EMM386, QEMM386 etc. running. If you still  │',0Dh,0Ah
                db      '│  wish to run this program please remove it from your  │',0Dh,0Ah
                db      '■─CONFIG.SYS file and reboot... Sorry for inconvenience─■',0Dh,0Ah,'$'
A20error:       db      '■──────────────── Cannot control A20 line ──────────────■',0Dh,0Ah
                db      '│Seem that you either have an unusual keyboard controler│',0Dh,0Ah
                db      '│  or you have a not-AT compatible computer. Sorry, you │',0Dh,0Ah
                db      '■──────── can do nothing to run this program ... ───────■',0Dh,0Ah,'$'
