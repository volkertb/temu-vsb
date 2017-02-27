{$G+}
{Program to test SB DMA playing}
uses kbConst,dos;
var sample : array[0..40000] of byte;
    f      : File;
    s      : Word;

procedure myproc; interrupt;
var i : word;
begin
 i:=0;
 asm   mov al,0Bh
       out 20h,al
       in  al,20h
       mov i.byte,al
 end;
 write(i,' / ');
 asm   mov al,0Bh
       out 20h,al
       in  al,20h
       mov i.byte,al
 end;
 write(i,' / ');
 asm   mov dx,022Eh
       in  al,dx
       mov al,0Bh
       out 20h,al
       in  al,20h
       mov i.byte,al
 end;
 writeln(i);
 asm   mov al,0
       out $c,al
       in al,3
       mov i.byte,al
       in al,3
       mov i+1.byte,al
 end;
 Writeln(I);
end;

procedure PlaySample(var Sample; Size, Freq : Word);
var W : Word;
begin
 asm    in     al,21h
        and    al,11011111b
        out    21h,al
        mov    dx,$226
        mov    al,0
        out    dx,al

        mov    dx,$22C
        mov    al,$D1
        out    dx,al
        mov    al,$40
        out    dx,al

        mov    al,not 100
        out    dx,al

        les    bx,Sample
        mov    dx,es
        mov    ax,dx
        shr    dx,12
        shl    ax,4
        add    bx,ax
        mov    cx,Size
        dec    cx

        mov    al,05h
        out    0Ah,al          { Mask DMA channel 1 }
        out    0Ch,al
        mov    al,00001001b    { Mode register }
        out    0Bh,al
        mov    al,bl
        out    02h,al
        mov    al,bh
        out    02h,al
        mov    al,cl
        out    03h,al
        mov    al,ch
        out    03h,al
        mov    al,dl
        out    83h,al
        mov    al,01h
        out    0Ah,al
        mov    dx,022Ch
        mov    al,$14
        out    dx,al
        mov    ax,Size
        dec    ax
        out    dx,al
        mov    al,ah
        out    dx,al
 end;
{ delay(100);}
end;

begin
 assign(f,'sample'); reset(f,1);
 blockread(f,sample,filesize(f),s);
 close(f);
 setintvec($0D,@myproc);
 playsample(sample, s, 10000);
 repeat until mem[0:$41A]<>mem[0:$41C];
 Write('Finally - ');
 asm   mov al,0
       out $c,al
       in al,3
       mov s.byte,al
       in al,3
       mov s+1.byte,al
 end;
 Writeln(S);
end.
