{Program to combine QEMM and CLEAN DOS versions into one}

uses miscUtil;
var F,R,P : File;
    BR,BP : pArrOfByte;
    SR,SP : Word;
    I     : Word;
    Rec   : record
             rOfs,rSize,
             pOfs,pSize : Word;
            end;

begin
 Assign(F,'vsb.com'); Reset(F, 1);
 if ioResult <> 0 then halt;
 Assign(R,'vsb_real.com'); Reset(R, 1);
 if ioResult <> 0 then halt;
 Assign(P,'vsb_qemm.com'); Reset(P, 1);
 if ioResult <> 0 then halt;
 SR := fileSize(R);
 GetMem(BR, SR); BlockRead(R, BR^, SR);
 Close(R);
 SP := fileSize(P);
 GetMem(BP, SP); BlockRead(P, BP^, SP);
 Close(P);
 Seek(F, 2); BlockRead(F, I, 2); Seek(F, I);
 Rec.rOfs := I + sizeOf(Rec);
 Rec.rSize := SR;
 Rec.pOfs := I + sizeOf(Rec) + SR;
 Rec.pSize := SP;
 BlockWrite(F, Rec, sizeOf(Rec));
 BlockWrite(F, BR^, SR);
 BlockWrite(F, BP^, SP);
 Truncate(F);
 Close(F);
 if ioResult <> 0 then Writeln('Error') else Writeln('Ok');
end.
