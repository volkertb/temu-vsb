;░▒▓█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█▓▒░
;░▒▓█         Disney Sound Source emulator for Covox & PC-Squeaker        █▓▒░
;░▒▓█                (C)opyright 1993 by FRIENDS software                 █▓▒░
;░▒▓█                           Data segment                              █▓▒░
;░▒▓█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█▓▒░

Header          db      '■─[ TEMU ]─────────────────────[ Installed ]─■',0Dh,0Ah
                db      '│ Tandy 3-voice & DSS emulator for Covox&386 │',0Dh,0Ah
                db      '│ (C)opyright >',??date,'< by FRIENDS software │',0Dh,0Ah
                db      '│ Version 3.03              TEMU /? for help │',0Dh,0Ah
                db      '■────────────────────────────────────────────■',0Dh,0Ah,'$'
BadOption       db      '■─[ TEMU ]─────────────────────────[ Error ]─■',0Dh,0Ah
                db      '│  Invalid option - see below legal options  │',0Dh,0Ah
                db      '■────────────────────────────────────────────■',0Dh,0Ah
HelpText        db      '■─[ TEMU ]──────────────────────────[ Help ]─■',0Dh,0Ah
                db      '│ Tandy 3-voice & DSS emulator for Covox&386 │',0Dh,0Ah
                db      '│ Syntax : TEMU {/SLT};   Available options: │',0Dh,0Ah
                db      '│ /S   - Use PC speaker for output           │',0Dh,0Ah
                db      '│ /L#  - Use Covox in LPT# (1-4) for output  │',0Dh,0Ah
                db      '│ /T## - Set IRQ0 frequence in kHz (12-44)   │',0Dh,0Ah
                db      '│ Default output device is SeleN sound card. │',0Dh,0Ah
                db      '■────────────────────────────────────────────■',0Dh,0Ah,'$'
