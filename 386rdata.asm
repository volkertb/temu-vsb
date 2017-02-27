;°±²ÛßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÛ²±°
;°±²Û                 A i386(R) protected mode library                    Û²±°
;°±²Û               (C)opyright 1993 by FRIENDS software                  Û²±°
;°±²Û                           Real-mode data                            Û²±°
;°±²ÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛ²±°

CPUerror:       db      'şÄÄÄÄÄÄÄ This program requires an i386 or higher ÄÄÄÄÄÄÄş',0Dh,0Ah,'$'
AlreadyV86:     db      'şÄÄÄÄÄ Processor already running in protected mode ÄÄÄÄÄş',0Dh,0Ah
                db      '³    Seem that you have a 386 extended memory manager   ³',0Dh,0Ah
                db      '³   such as EMM386, QEMM386 etc. running. If you still  ³',0Dh,0Ah
                db      '³  wish to run this program please remove it from your  ³',0Dh,0Ah
                db      'şÄCONFIG.SYS file and reboot... Sorry for inconvenienceÄş',0Dh,0Ah,'$'
A20error:       db      'şÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Cannot control A20 line ÄÄÄÄÄÄÄÄÄÄÄÄÄÄş',0Dh,0Ah
                db      '³Seem that you either have an unusual keyboard controler³',0Dh,0Ah
                db      '³  or you have a not-AT compatible computer. Sorry, you ³',0Dh,0Ah
                db      'şÄÄÄÄÄÄÄÄ can do nothing to run this program ... ÄÄÄÄÄÄÄş',0Dh,0Ah,'$'
