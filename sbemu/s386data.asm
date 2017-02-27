;°±²ÛßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÛ²±°
;°±²Û           Sound Blaster emulator for Covox & PC-Squeaker            Û²±°
;°±²Û                (C)opyright 1993 by FRIENDS software                 Û²±°
;°±²Û                           Data segment                              Û²±°
;°±²ÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛ²±°

Header          db      'şÄ[ VSB ]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ Installed ]Äş',0Dh,0Ah
                db      '³ Virtual SoundBlaster (SB emulator) for DAC ³',0Dh,0Ah
                db      '³ (C)opyright 1993..1995 by FRIENDS software ³',0Dh,0Ah
                db      '³ Version 2.02               VSB /? for help ³',0Dh,0Ah
                db      'şÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄş',0Dh,0Ah,'$'
BadOption       db      'şÄ[ VSB ]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ Error ]Äş',0Dh,0Ah
                db      '³  Invalid option - see below legal options  ³',0Dh,0Ah
                db      'şÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄş',0Dh,0Ah
HelpText        db      'şÄ[ VSB ]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ Help ]Äş',0Dh,0Ah
                db      '³ Virtual SoundBlaster for DAC  Version 2.02 ³',0Dh,0Ah
                db      '³      Compiled on ',??date,' at ',??time,'      ³',0Dh,0Ah
                db      '³ Syntax : VSB {/SLWAI};  Available options: ³',0Dh,0Ah
                db      '³ /S   - Use PC speaker for output           ³',0Dh,0Ah
                db      '³ /L#  - Use Covox in LPT# (1-4) for output  ³',0Dh,0Ah
                db      '³ /W   - Slower ports 388h & 389h (for fast  ³',0Dh,0Ah
                db      '³        machines with real AdLib)           ³',0Dh,0Ah
                db      '³ /A   - Don`t intercept ports 388h & 389h   ³',0Dh,0Ah
                db      '³        (if you have an real AdLib card)    ³',0Dh,0Ah
                db      '³ /I#  - Set SoundBlaster IRQ number (5 or 7)³',0Dh,0Ah
                db      '³        Default is IRQ5 (factory setting :) ³',0Dh,0Ah
                db      '³ Default output device is SeleN sound card. ³',0Dh,0Ah
                db      'şÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄş',0Dh,0Ah,'$'
