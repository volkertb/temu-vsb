;°±²ÛßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÛ²±°
;°±²Û         Disney Sound Source emulator for Covox & PC-Squeaker        Û²±°
;°±²Û                (C)opyright 1993 by FRIENDS software                 Û²±°
;°±²Û                           Data segment                              Û²±°
;°±²ÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛ²±°

Header          db      'şÄ[ TEMU ]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ Installed ]Äş',0Dh,0Ah
                db      '³ Tandy 3-voice & DSS emulator for Covox&386 ³',0Dh,0Ah
                db      '³ (C)opyright >',??date,'< by FRIENDS software ³',0Dh,0Ah
                db      '³ Version 3.03              TEMU /? for help ³',0Dh,0Ah
                db      'şÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄş',0Dh,0Ah,'$'
BadOption       db      'şÄ[ TEMU ]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ Error ]Äş',0Dh,0Ah
                db      '³  Invalid option - see below legal options  ³',0Dh,0Ah
                db      'şÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄş',0Dh,0Ah
HelpText        db      'şÄ[ TEMU ]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ Help ]Äş',0Dh,0Ah
                db      '³ Tandy 3-voice & DSS emulator for Covox&386 ³',0Dh,0Ah
                db      '³ Syntax : TEMU {/SLT};   Available options: ³',0Dh,0Ah
                db      '³ /S   - Use PC speaker for output           ³',0Dh,0Ah
                db      '³ /L#  - Use Covox in LPT# (1-4) for output  ³',0Dh,0Ah
                db      '³ /T## - Set IRQ0 frequence in kHz (12-44)   ³',0Dh,0Ah
                db      '³ Default output device is SeleN sound card. ³',0Dh,0Ah
                db      'şÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄş',0Dh,0Ah,'$'
