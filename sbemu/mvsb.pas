{Program to combine QEMM and CLEAN DOS versions into one}

//uses miscUtil;
type
  ArrOfByte = array of Byte;
  pArrOfByte = ^ArrOfByte;
var F,R,P : File;
    BR,BP : pArrOfByte;
    SR,SP : Word;
    I     : Word;
    Rec   : record
             rOfs,rSize,
             pOfs,pSize : Word;
            end;

begin
 Assign(F,'vsb.com'); Reset(F, 1); // F will become the resulting "merged" vsb file
 if ioResult <> 0 then halt;
 Assign(R,'vsb_real.com'); Reset(R, 1); // R is she CLEAN DOS version of vsb
 if ioResult <> 0 then halt;
 Assign(P,'vsb_qemm.com'); Reset(P, 1); // P is the QEMM version of vsb
 if ioResult <> 0 then halt;
 SR := fileSize(R); // SR now contains the file size of the CLEAN DOS version of vsb
 GetMem(BR, SR); BlockRead(R, BR^, SR); // BR gets filled with the contents of the CLEAN DOS version of vsb
 Close(R); // Close the CLEAN DOS version of vsb (file)
 SP := fileSize(P); // SP now contains the file size of the QEMM versoin of vsb
 GetMem(BP, SP); BlockRead(P, BP^, SP); // BP gets filled with the contents of the QEMM version of vsb
 Close(P); // Close the QEMM version of vsb (file)
 Seek(F, 2); BlockRead(F, I, 2); Seek(F, I); // Seek merged file to position 2, read 2 more records into I, seek file to whatever you read into I.
 Rec.rOfs := I + sizeOf(Rec); // Rec.rOfs (offset?) contains whatever was read into I plus the size of Rec.
 Rec.rSize := SR; // Rec.rSize contains the file size of the CLEAN DOS version of vsb
 Rec.pOfs := I + sizeOf(Rec) + SR; // Rec.pOfs (offset?) contains whatever was read into I plus the size of Rec.
 Rec.pSize := SP; // Rec.pSize contains the file size of the QEMM version of vsb
 BlockWrite(F, Rec, sizeOf(Rec)); // Write the Record to the merged file (after having seeked earlier)
 BlockWrite(F, BR^, SR); // Write the CLEAN DOS version of vsb to the merged file
 BlockWrite(F, BP^, SP); // Write the QEMM version of vsb to the merged file
 Truncate(F);
 Close(F);
 if ioResult <> 0 then Writeln('Error') else Writeln('Ok');
end.
