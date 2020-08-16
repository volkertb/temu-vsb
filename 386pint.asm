;░▒▓█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█▓▒░
;░▒▓█		      A i386(R) protected mode library			  █▓▒░
;░▒▓█		    (C)opyright 1993 by FRIENDS software		  █▓▒░
;░▒▓█			     Interrupt handlers 			  █▓▒░
;░▒▓█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█▓▒░

; Note - We don't emulate lock, IRETD, PUSHFD, POPFD yet

BreakpointID	=	80h
Break		macro				; Macro works as breakpoint
		push	BreakpointID
BreakpointID	=	BreakpointID+1
		jmp	NotIO
		endm

;********************* Interrupt gates points here ***************************
DefInt		macro	N
Int&N		label	near
		push	&N
		jmp	IntDump
		endm

;*****************************************************************************
; This code defines interrupt handlers from 0 to TOPINT
; (TOPINT is defined in 386pDef.asm)
IntNo		=	0
		rept	TopInt+1
		DefInt	%IntNo
IntNo		=	IntNo + 1
		endm

;**** If we made it here, we have an hardware or an unexpected interrupt *****
;**************** so crank out a debug dump and exit to dos ******************
IntDump:	cmp	byte ptr [esp],6
		jbe	EmulateInt		; Emulate INTs 0, 1, 3 ...
		cmp	byte ptr [esp],20h
		jb	NotIO
		cmp	byte ptr [esp],2Fh
		ja	NotIO
		jmp	HWint
NotIO:		pushad
		push	ss
		push	es
		push	ds
		push	fs
		push	gs
		mov	ax,@gdData
		mov	ds,ax
; do dump
		call	CRLF
		mov	bx,offset UnexpInt
		call	WriteMsg
		mov	cx,5
		mov	bx,offset RTable
IntL1:		mov	al,[bx]
		inc	bx
		call	OutChar
		mov	al,'S'
		call	OutChar
		mov	al,'='
		call	OutChar
		pop	ax
		call	HexOut2
		push	cx
		mov	cx,2
lsp1:		mov	al,' '
		call	OutChar
		loop	lsp1
		pop	cx
		loop	IntL1
		xor	cx,cx
		mov	bx,offset GTable
IntL2:		test	cl,011b
		jnz	short NoCRint
		call	CRLF
NoCRint:	mov	al,'E'
		call	OutChar
		mov	al,[bx]
		inc	bx
		call	OutChar
		mov	al,[bx]
		inc	bx
		call	OutChar
		mov	al,'='
		call	OutChar
		pop	eax
		cmp	cl,3
		jne	NoESP
		add	eax,2
NoESP:		call	HexOut4
		mov	al,' '
		call	OutChar
		inc	cl
		cmp	cl,8
		jne	short IntL2
		call	CRLF
		mov	bx,offset TaskMsg
		call	WriteMsg
		str	ax
		call	HexOut2
		mov	bx,offset UnexpMsg
		call	WriteMsg
		pop	ax
		call	HexOut
		call	CRLF
		mov	byte ptr ss:IntContNo,'1'
		mov	bx,offset IntController
		call	WriteMsg
		in	al,21h
		call	HexOut
		call	CRLF
		mov	byte ptr ss:IntContNo,'2'
		mov	bx,offset IntController
		call	WriteMsg
		in	al,0A1h
		call	HexOut

; stack dump
		mov	dx,offset P0ESP-1
		mov	esi,TaskSegment.TSSespP0
		call	CRLF
		mov	bx,offset StackMsg
		call	WriteMsg
		mov	cl,15
IntL3:		cmp	sp,dx
		jae	short IntAbt
		cmp	cl,14
		jbe	short NoScr
		call	CRLF
		mov	cl,0
NoScr:		pop	ax
		mov	bl,Color
		cmp	esp,esi
		jne	NoHighlight		; Use for first word in
		mov	Color,15		; stack with white color
NoHighlight:	call	HexOut2
		mov	Color,bl
		inc	cl
		mov	al,' '
		call	OutChar
		jmp	IntL3

; check for memory dump request
IntAbt: 	call	CRLF
		mov	ax,word ptr DumpSelc
		or	ax,ax
		jz	NoMemDump
; come here to do memory dump
		mov	es,ax
		push	ds
		push	cs
		pop	ds
		mov	bx,offset MemMsg
		call	WriteMsg
		pop	ds
		mov	ax,es
		call	HexOut2
		call	CRLF
		mov	esi,DumpOffs
		mov	cx,DumpSize
		add	cx,15
		shr	cx,4			;Number of rows

@@D_0:		mov	eax,esi
		call	HexOut4
		mov	al,' '
		call	OutChar
		mov	al,'│'
		call	OutChar
		mov	al,' '
		call	OutChar
		mov	dx,16
@@D_1:		mov	al,es:[esi]
		inc	esi
		call	HexOut
		mov	al,' '
		call	OutChar
		dec	dx
		jne	@@D_1
		mov	dl,16
		sub	esi,16
		mov	al,'│'
		call	OutChar
		mov	al,' '
		call	OutChar
@@D_2:		mov	al,es:[esi]
		inc	esi
		cmp	al,' '
		ja	@@D_OK
		mov	al,'.'
@@D_OK: 	call	OutChar
		dec	dx
		jne	@@D_2
		call	CRLF
		loop	@@D_0
NoMemDump:	jmp	Back2DOS

;*****************************************************************************
;			Here we check the GP fault
;   If the mode isn't vm86 we do a debug dump; otherwise we try and emulate
;      an instruction; if the instruction isn't known, we do a debug dump
;*****************************************************************************
Int13h:
If PMinterrupts EQ 1
		test	dword ptr [esp+0Ch],00020000h
		jz	short Sim13		; wasn't a vm86 interrupt!
EndIf
		mov	[esp],eax		; remove error code & push eax
		push	ebx
		push	ds
		push	ebp
		mov	ebp,esp 		; point to stack frame
		add	ebp,14
		mov	ax,@gdFlat
		mov	ds,ax
		movzx	ebx,word ptr [ebp+4]	; get CS
		shl	ebx,4
		add	ebx,[ebp]		; get EIP
		xor	eax,eax
		jmp	InLoop

; al = opcode byte
; ah = # of bytes skipped over
; bit 31 of eax=1 if 'opsize' prefix encountered
FSet:		or	eax,80000000h
InLoop: 	mov	ah,[ebx]
		inc	al
		inc	ebx
		cmp	ah,66h	     ; opsize prefix
		je	FSet

; Scan for instructions
;		 cmp	 ah,9Dh
;		 je	 DoPopf
;		 cmp	 ah,9Ch
;		 je	 DoPushf
;		 cmp	 ah,0FAh
;		 je	 DoCli
;		 cmp	 ah,0FBh
;		 je	 DoSti
;		 cmp	 ah,0CCh
;		 je	 DoInt03
;		 cmp	 ah,0CDh
;		 je	 DoIntNN
;		 cmp	 ah,0CFh
;		 je	 DoIret
;		 cmp	 ah,0F0h
;		 je	 DoLock

IfDef		PortHandler
%		Include PortHandler
EndIf

		cmp	ah,0CDh
		je	DoIntNN
		cmp	ah,0CCh
		je	DoInt03
		cmp	ah,0F4h
		je	DoHalt
		cmp	ah,00Fh
		je	PMinstr

; whoops! what the $#$&$#! is that?
FailGPF:	dec	ebx
		push	ds
		push	bx
		mov	ax,@gdData
		mov	ds,ax
		call	CRLF
		mov	bx,offset GPFmsg
		call	WriteMsg
		pop	bx
		pop	ds
		mov	bp,16
DisplayInvComm: mov	al,[ebx]
		inc	ebx
		call	HexOut
		dec	bp
		jne	DisplayInvComm
		pop	ebp
		pop	ds
		pop	ebx
		pop	eax
		push	0DEADh			;simulate errorNo
sim13:		push	13
		jmp	NotIO

;*****************************************************************************
; The following routines emulate vm86 instructions; On entry:
; eax[31] = 1 if 'opsize' preceeded instruction;
; ah	  = count to adjust eip on stack
; al	  = instruction
; [ebx]   = next opcode byte
; ds	  = zerobase segment
; [ebp]   = address of stack frame
;******* This routine emulates PM instructions (mov to/from CRx & DRx) *******
PMinstr:	mov	ah,[ebx]
		inc	al
		cmp	ah,20h
		jb	FailGPF
		cmp	ah,23h
		ja	FailGPF
		inc	ebx
		cmp	ah,22h
		je	MovToCRx
ThreeBytes:	mov	byte ptr ss:MakeInstr+1,ah
		mov	ah,[ebx]
		inc	al
		mov	byte ptr ss:MakeInstr+2,ah
DoneInstr:	cbw
		add	[ebp],ax		;fix return addr
		pop	ebp
		pop	ds
		pop	ebx
		pop	eax
MakeInstr:	mov	eax,cr0
		iretd
MovToCRx:	add	word ptr [ebp],3	;fix return addr
		pop	ebp
		pop	ds
		pop	ebx
		pop	eax
		iretd

If StartIOPL EQ 0

;********************* This routine emulates a popf **************************
DoPopF: 	cbw
		add	[ebp],ax		;fix return addr
		movzx	ebx,word ptr [ebp+10h]	;Get SS
		shl	ebx,4
		add	ebx,[ebp+0Ch]		;get linear addr of SS:ESP
		movzx	eax,word ptr [ebx]
		or	eax,00020200h
		and	eax,0FFFECFFFh		;Clear RF & IOPL
		mov	[ebp+08h],eax		;save his real flag image
		add	word ptr [ebp+0Ch],2	;adjust SP (Not ESP!)
		pop	ebp
		pop	ds
		pop	ebx
		pop	eax
		iretd

;************************ Routine to emulate pushf ***************************
DoPushF:	cbw
		add	[ebp],ax		;Adjust IP
		mov	eax,[ebp+08h]		;get his flags
		movzx	ebx,word ptr [ebp+10h]
		shl	ebx,4
		add	ebx,[ebp+0Ch]
		mov	[ebx],ax
		and	byte ptr [ebp+0Ah],0FEh ;Clear RF
		sub	word ptr [ebp+0Ch],2	;Adjust SP (Not ESP!)
		pop	ebp
		pop	ds
		pop	ebx
		pop	eax
		iretd

;******************************** Emulate cli ********************************
DoCli:		cbw
		add	[ebp],ax		;fix ip
		mov	eax,[ebp+8]		;get flags
		and	eax,0FFFECDFFh		;clear RF,IOPL & IF
		mov	[ebp+8],eax		;Replace flags
		pop	ebp
		pop	ds
		pop	ebx
		pop	eax
		iretd

;***************************** Emulate sti ***********************************
DoSti:		cbw
		add	[ebp],ax		;fix ip
		mov	eax,[ebp+8]		;get flags
		or	ax,0200h		;set IF
		and	eax,0FFFECFFFh		;clear RF & IOPL
		or	ah,2
		mov	[ebp+8],eax		;replace flags
		pop	ebp
		pop	ds
		pop	ebx
		pop	eax
		iretd

;****************************** Emulate lock prefix **************************
DoLock: 	pop	ebp
		pop	ds
		pop	ebx
		pop	eax
		push	large 0FFFFFFFFh
		push	13h			;simulate errno
		jmp	NotIO

;************************** Emulate iret instruction *************************
DoIret: 	push	esi
		movzx	esi,word ptr [ebp+10h]	;SS
		shl	esi,4
		movzx	eax,[ebp+0Ch]		;get ESP
		movzx	ebx,word ptr [esi+eax]	;get IP
		add	ax,2

If PMinterrupts EQ 1
; If top of stack=0:0 then return control to PL0 supervisor
		or	bx,word ptr [esi+eax]
		jz	ReturnToPL0
		sub	ax,2
		mov	bx,word ptr [esi+eax]	;get IP
		add	ax,2
EndIf

; Not equal then this is a real IRET
; Build a "fake" PL0 frame
		mov	[ebp],ebx
		movzx	ebx,word ptr [esi+eax]	;Get CS
		add	ax,2
		mov	[ebp+4],ebx
		movzx	ebx,word ptr [esi+eax]	;Get FLAGS
		or	ebx,00020200h
		and	bh,0CFh 		;clr RF & IOPL
		mov	[ebp+8],ebx
		add	word ptr [ebp+0Ch],6	;Adjust SP (Not ESP!)
		pop	esi
		pop	ebp
		pop	ds
		pop	ebx
		pop	eax
		iretd

;──────────────────>
If PMinterrupts eq 1

ReturnToPL0:	mov	ax,@gdData
		mov	ds,ax
		mov	bx,IntSP		;Get prior PL0 ESP
		mov	eax,[bx]		;from local stack
		add	IntSP,4
		mov	TaskSegment.TSSespP0,eax;restore to TSS
		sub	eax,4+4+4		;Skip EIP, CS & EFLAGS
		mov	Temp1,eax
		pop	ebp
		pop	ds
		pop	ebx
		pop	eax
		mov	esp,ss:Temp1
		iretd				;Return to PL0
;──────────────────>
EndIf

EndIf						;If StartIOPL<>0

;***************** This routine emulates an Int nn instruction ***************
DoIntNN:	push	ecx
		push	edx
		push	esi
		movzx	esi,word ptr [ebp+10h]	;SS
		shl	esi,4
		movzx	edx,word ptr [ebp+0Ch]	;ESP
		sub	dx,2
		mov	cx,[ebp+08h]		;Get VM86 flags
		mov	[esi+edx],cx		;Put into new stack frame
		sub	dx,2
		and	word ptr [ebp+08h],1111110011111111b;Clear IF & TF
		mov	cx,[ebp+04h]		;Get VM86 CS
		mov	[esi+edx],cx		;Put into new stack frame
		sub	dx,2
		cbw
		inc	ax			;Comand length+1 (intno)
		add	ax,[ebp]		;Add VM86 IP
		mov	[esi+edx],ax		;Put into new stack frame
		sub	word ptr [ebp+0Ch],6	;adjust SP (Not ESP!)
		movzx	ebx,byte ptr [ebx]
		movzx	eax,word ptr [ebx*4]
		mov	[ebp],eax
		movzx	eax,word ptr [ebx*4+2]
		mov	[ebp+4],eax
		pop	esi
		pop	edx			;Restore all
		pop	ecx			;previously saved
		pop	ebp			;registers
		pop	ds
		pop	ebx
		pop	eax
		iretd				; Go, go, go !!!

;****************** This routine emulates an Int3 instruction ****************
DoInt03:	cmp	word ptr [ebp+04h],01234h; Get VM86 CS
PatchCS2	equ	word ptr $-2
		je	DoMOVSD
		push	ecx
		push	edx
		push	esi
		movzx	esi,word ptr [ebp+10h]	;SS
		shl	esi,4
		movzx	edx,word ptr [ebp+0Ch]	;ESP
		sub	dx,2
		mov	cx,[ebp+08h]		;Get VM86 flags
		mov	[esi+edx],cx		;Put into new stack frame
		sub	dx,2
		and	word ptr [ebp+08h],1111110011111111b;Clear IF & TF
		mov	cx,[ebp+04h]		;Get VM86 CS
		mov	[esi+edx],cx		;Put into new stack frame
		sub	dx,2
		cbw
		add	ax,[ebp]		;Add VM86 IP
		mov	[esi+edx],ax		;Put into new stack frame
		sub	word ptr [ebp+0Ch],6	;adjust SP (Not ESP!)
		mov	ax,ds:[3*4]
		mov	[ebp],ax
		mov	ax,ds:[3*4+2]
		mov	[ebp+4],ax
		pop	esi
		pop	edx			;Restore all
		pop	ecx			;previously saved
		pop	ebp			;registers
		pop	ds
		pop	ebx
		pop	eax
		iretd				;Go, go, go !!!

DoMOVSD:	inc	word ptr [ebp]
		pop	ebp
		pop	ds
		pop	ebx
		pop	eax
		mov	ax,@gdFlat
		mov	ds,ax
		mov	es,ax
		rep	movs word ptr [esi], word ptr [edi]
		iretd

DoHalt: 	cbw
		add	[ebp],ax		;fix ip
		pop	ebp			;Ignore it
		pop	ds
		pop	ebx
		pop	eax
		iretd

;*****************************************************************************
; This is the interface routine to allow a protected mode program call vm86
; interrupts. Call with es:bx pointing to a I30parmBlock structure.

Int30h:
;──────────────────>
If PMinterrupts eq 1
		break
		push	es:[bx].i30gs		;Build a fake stack frame
		push	es:[bx].i30fs
		push	es:[bx].i30ds
		push	es:[bx].i30es
		push	es:[bx].i30ss
		push	es:[bx].i30esp
; force vm86=1 in eflags
		xchg	eax,es:[bx].i30eflags
		or	eax,20000h		;Set VM
		and	eax,0FFFECFFFh		;Clear RF & IOPL
		push	eax
		xchg	eax,es:[bx].i30eflags
		push	eax
		push	ds
		mov	ax,@gdFlat
		mov	ds,ax
		movzx	ebx,byte ptr es:[bx].i30IntNo
		movzx	ebx,word ptr [ebx*4]	;Interrupt offset
		movzx	eax,word ptr [ebx*4+2]	;Segment
		pop	ds
		xchg	eax,[esp]		;CS
		push	ebx			;EIP
; Go ahead.... make my interrupt
		push	ebp
		mov	ebp,esp
		push	eax
		push	ebx
		movzx	ebx,word ptr [ebp+14h]
		shl	ebx,4
		add	ebx,[ebp+10h]		;Linear SS:ESP
		mov	cx,[ebp+0Ch]		;Get VM86 flags
		mov	[ebx-02h],cx		;Put into new stack frame
		mov	cx,[ebp+08h]		;Get VM86 CS
		mov	[ebx-04h],cx		;Put into new stack frame
		mov	cx,[ebp+04h]		;Get VM86 IP
		mov	[edx-06h],cx		;Put into new stack frame
		sub	word ptr [ebp+0Ch],6	;adjust SP (Not ESP!)
		pop	ebx			;Restore all
		pop	eax			;previously saved
		pop	ebp			;registers
		mov	ebx,es:[bx].i30ebx
		iretd				;Thrash forever!!!
;──────────────────>
EndIf

;*****************************************************************************
;			 Handle hardware interrupt
;*****************************************************************************
HWint:		xchg	ax,[esp]
		sub	al,18h
		cmp	al,0Fh
		jbe	IRQset
		add	al,48h+18h		;Vector IRQ8-F to int 70-77
IRQset:
If PMinterrupts eq 1
		test	byte ptr [esp+12],2	;Check VM
		je	@@PMHW			;If zero then do a PM interrupt
EndIf
		push	ecx
		push	edx
		push	esi
		mov	dx,@gdFlat
		mov	ds,dx
		movzx	esi,word ptr [esp+1Eh]	;SS
		shl	esi,4
		movzx	edx,word ptr [esp+1Ah]	;ESP
		sub	dx,2
		mov	cx,[esp+16h]		;Get VM86 flags
		mov	[esi+edx],cx		;Put into new stack frame
		sub	dx,2
		and	word ptr [esp+16h],1111110011111111b;Clear IF & TF
FlagsMask	equ	word ptr $-2
		mov	ss:FlagsMask,1111110011111111b
		mov	cx,[esp+12h]		;Get VM86 CS
		mov	[esi+edx],cx		;Put into new stack frame
		sub	dx,2
		mov	cx,[esp+0Eh]		;Get VM86 IP
		mov	[esi+edx],cx		;Put into new stack frame
		sub	word ptr [esp+1Ah],6	;adjust SP (Not ESP!)
		movzx	edx,al
		mov	ax,[edx*4+2]
		mov	[esp+12h],ax
		mov	ax,[edx*4]
		mov	[esp+0Eh],ax
		pop	esi
		pop	edx
		pop	ecx
		pop	ax
		iretd				;Go, go, go !!!

If PMinterrupts eq 1
@@PMHW: 	break				;This part doesn't work
		mov	ss:Temp2,ebx		;right now!!!!!!!!!!!!!
		mov	bx,@gdData
		mov	ds,bx
		sub	IntSP,4
		mov	bx,IntSP
		mov	word ptr Temp4,ax
		pop	ax			;Remember AX
		mov	Temp3,eax
		mov	eax,esp
		add	eax,4+4+4+8		;Skip EIP+CS+EFLAGS
		mov	[bx],eax
		mov	TaskSegment.TSSespP0,esp

		sub	esp,4+4+4+4		;Skip GS+FS+DS+ES
		push	large 1234h		;VM86 SS
PatchSS1	equ	word ptr $-4
		push	large offset VM86SP-6	;VM86 SP
		push	large 00020000h 	;Pseudo-flags

		mov	bx,offset VM86SP-6
		mov	word ptr ss:[bx+04h],0	;Emulate flags
		mov	dword ptr ss:[bx],12345678h
QIRETaddr	equ	dword ptr $-4		;Put QIRET's SEG:OFFSET

		mov	bx,@gdFlat
		mov	ds,bx
		movzx	ebx,word ptr ss:Temp4
		movzx	eax,word ptr [ebx*4+2]
		push	eax
		movzx	eax,word ptr [ebx*4]
		push	eax
		mov	ebx,ss:Temp2
		mov	eax,ss:Temp3
		iretd				;Go !!!
EndIf

;**** Following interpret interrupt number number as-is and pass control ****
;****************************** to VM86 handler *****************************
EmulateInt:	xchg	ax,[esp]
		jmp	IRQset

If PMinterrupts EQ 1
;*****************************************************************************
; Push zeroes as return address - supervisor will handle this as return to PM
QIRET:		push	0			;Flags
		push	large 0 		;CS:IP
		iret
EndIf
