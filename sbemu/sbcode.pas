{$G+}
{Program which tests undocumented feature of original SoundBlaster which allows}
{to encrypt (weak encryption since I was able to reverse-engineer it :-) data}
{used in many Creative Labs software including CT-VOICE.DRV driver}

uses crt,dos;
var bff    : array[0..$4000] of byte;
    buffer : array[0..32768] of byte;
    f      : File;
    s      : Word;

procedure myproc; interrupt; assembler;
asm       mov dx,$22e
          in  al,dx
          mov al,$20
          out $20,al
end;

procedure Recode;
begin
 asm    in     al,21h
        and    al,11011111b
        out    21h,al
        mov    dx,$226
        mov    al,0
        out    dx,al
        mov    cx,$ffff
@@1:    loop   @@1
        in     al,dx

        lea    bx,buffer
        mov    dx,ds
        mov    ax,dx
        shr    dx,12
        shl    ax,4
        add    bx,ax
        adc    dx,0
        mov    cx,32768
        dec    cx

        mov    al,05h
        out    0Ah,al          { Mask DMA channel 1 }
        out    0Ch,al
        mov    al,01000101b    { Mode register }
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
        mov    bx,offset buffer
        mov    cx,32768
@@2:    in     al,dx
        or     al,al
        js     @@2
        mov    al,$E2
        out    dx,al
@@3:    in     al,dx
        or     al,al
        js     @@3
        mov    al,[bx]
        out    dx,al
        inc    bx
        loop   @@2

@@4:    in     al,dx
        or     al,al
        js     @@4
        mov    al,$E4
        out    dx,al
@@5:    in     al,dx
        or     al,al
        js     @@5
        mov    al,$AA
        out    dx,al
@@6:    in     al,dx
        or     al,al
        js     @@6
        mov    al,$E8
        out    dx,al

        in     al,21h
        or     al,10000000b
        out    21h,al
 end;
 delay(100);
end;

var old0f : pointer;
    i     : Integer;

begin
 if ((seg(buffer)+ofs(buffer) div 16+$800) div $1000)<>
    ((seg(buffer)+ofs(buffer) div 16) div $1000)
    then begin
          writeln('Invalid buffer alignment - please load program');
          writeln('to a different segment ...');
          halt(1);
         end;
{ getintvec($0f,old0f);
 setintvec($0f,@myproc);}
 for i:=0 to 16383 do
     begin
      buffer[i*2]:=i div 256;
      buffer[i*2+1]:=i;
     end;
 Recode;
 assign(f,'sblaster.dat'); rewrite(f,1);
 blockwrite(f, buffer, 32768); close(f);
end.
