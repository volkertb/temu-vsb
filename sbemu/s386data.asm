;░▒▓█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█▓▒░
;░▒▓█           Sound Blaster emulator for Covox & PC-Squeaker            █▓▒░
;░▒▓█                (C)opyright 1993 by FRIENDS software                 █▓▒░
;░▒▓█                           Data segment                              █▓▒░
;░▒▓█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█▓▒░

Header          db      '■─[ VSB ]──────────────────────[ Installed ]─■',0Dh,0Ah
                db      '│ Virtual SoundBlaster (SB emulator) for DAC │',0Dh,0Ah
                db      '│ (C)opyright 1993..1995 by FRIENDS software │',0Dh,0Ah
                db      '│ Version 2.02               VSB /? for help │',0Dh,0Ah
                db      '■────────────────────────────────────────────■',0Dh,0Ah,'$'
BadOption       db      '■─[ VSB ]──────────────────────────[ Error ]─■',0Dh,0Ah
                db      '│  Invalid option - see below legal options  │',0Dh,0Ah
                db      '■────────────────────────────────────────────■',0Dh,0Ah
HelpText        db      '■─[ VSB ]───────────────────────────[ Help ]─■',0Dh,0Ah
                db      '│ Virtual SoundBlaster for DAC  Version 2.02 │',0Dh,0Ah
                ;db      '│      Compiled on ',??date,' at ',??time,'      │',0Dh,0Ah
                db      '│ Syntax : VSB {/SLWAI};  Available options: │',0Dh,0Ah
                db      '│ /S   - Use PC speaker for output           │',0Dh,0Ah
                db      '│ /L#  - Use Covox in LPT# (1-4) for output  │',0Dh,0Ah
                db      '│ /W   - Slower ports 388h & 389h (for fast  │',0Dh,0Ah
                db      '│        machines with real AdLib)           │',0Dh,0Ah
                db      '│ /A   - Don`t intercept ports 388h & 389h   │',0Dh,0Ah
                db      '│        (if you have an real AdLib card)    │',0Dh,0Ah
                db      '│ /I#  - Set SoundBlaster IRQ number (5 or 7)│',0Dh,0Ah
                db      '│        Default is IRQ5 (factory setting :) │',0Dh,0Ah
                db      '│ Default output device is SeleN sound card. │',0Dh,0Ah
                db      '■────────────────────────────────────────────■',0Dh,0Ah,'$'
