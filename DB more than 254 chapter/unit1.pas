unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, dbf, db, FileUtil, Forms, Controls, Graphics,
  Dialogs, DBGrids, DbCtrls, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    DataSource1: TDataSource;
    Dbf1: TDbf;
    Dbf1DB1: TStringField;
    Dbf1DB10: TStringField;
    Dbf1DB11: TStringField;
    Dbf1DB12: TStringField;
    Dbf1DB13: TStringField;
    Dbf1DB14: TStringField;
    Dbf1DB15: TStringField;
    Dbf1DB2: TStringField;
    Dbf1DB3: TStringField;
    Dbf1DB4: TStringField;
    Dbf1DB5: TStringField;
    Dbf1DB6: TStringField;
    Dbf1DB7: TStringField;
    Dbf1DB8: TStringField;
    Dbf1DB9: TStringField;
    Dbf1ID: TStringField;
    DBGrid5: TDBGrid;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure DBGrid5CellClick(Column: TColumn);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure Memo1EditingDone(Sender: TObject);
    procedure Memo1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { private declarations }
  public
    { public declarations }
    Function IIF(const ACondition: boolean; const ATrueResult, AFaultResult: Integer) : Integer; Overload;
    Function IIF(const ACondition: boolean; const ATrueResult, AFaultResult: Double) : Double; Overload;
    Function IIF(const ACondition: boolean; const ATrueResult, AFaultResult: String) : String; Overload;
    Function IIF(const ACondition: boolean; const ATrueResult, AFaultResult: Variant) : Variant; Overload;
    Function CheckFolder(CurrentFolder: String; CurrentDbf:String; CurrentDocument:String; CurrentDocumentDoc:String;
             CurrentTemporary:String; CurrentTemporaryDoc:String) : Integer;
    Function OpenDbf(DbfX: Tdbf; CurrentFolder: String; CurrentDbfFolder: String; CurrentDbfFile: String) : Integer;
    Function SetDbfToReadyReturnMaxID(DbfX: Tdbf; FilterX: String; FieldID: String; MoveRecordToLast: boolean) : Integer;
    Function ReadDbfReturnString(DbfX: Tdbf;
             Db1X: String; Db2X: String; Db3X: String; Db4X: String; Db5X: String; Db6X: String; Db7X: String; Db8X: String;
             Db9X: String; Db10X: String; Db11X: String; Db12X: String; Db13X: String; Db14X: String; Db15X: String) : String;
    Procedure ShiftValue(var DataX: Array of String; Y: Integer; X: Integer; Empty_String: String);
    Function RealTimeSaveRecord(SourceTxt: TMemo; DbfX: Tdbf; ID_Control: String; IndexCurrent: Integer;
             TotalChaperPerRceord: Integer; Db1X: String; Db2X: String; Db3X: String; Db4X: String; Db5X: String; Db6X: String;
             Db7X: String; Db8X: String; Db9X: String; Db10X: String; Db11X: String; Db12X: String; Db13X: String; Db14X: String;
             Db15X: String) : String;
    Function DeleteRecord(DbfX: Tdbf; ID_Control: String; SaveUndo: boolean) : String;
    Procedure ClearRedo();
  end;

var
  Form1: TForm1;
  DB_Index: integer;
  CurrentP:String;
  RealTimeSaveRecordStatic: array [1..50,1..2] of String; //PhysicalRecNo/ID
  RealTimeSaveRecordIndex: integer;
  UndoData_: array [1..400,1..57] of String; //Page/ActionNumber/DbfName/PhysicalRecNo/PhyRecTop/ID/Data1..51
                                             //New => Page/1/DbfName/PhysicalRecNo/''/''/''..
                                             //Delete=>Page/2/DbfName/PhysicalRecNo/PhyRecTop/ID/Data1..51
  UndoIndex: Integer;
  RedoData_: array [1..400,1..57] of String; //Page/ActionNumber/DbfName/PhysicalRecNo/PhyRecTop/ID/Data1..51
                                             //New => Page/1/DbfName/PhysicalRecNo/''/''/''..
                                             //Delete=>Page/2/DbfName/PhysicalRecNo/PhyRecTop/ID/Data1..51
  RedoIndex: Integer;
implementation

{$R *.lfm}

{ TForm1 }
Function TForm1.IIF(const ACondition: boolean; const ATrueResult, AFaultResult: Integer) : Integer;
begin
  if ACondition then
    Result := ATrueResult
  else
    Result := AFaultResult;
end;

Function TForm1.IIF(const ACondition: boolean; const ATrueResult, AFaultResult: Double) : Double;
begin
  if ACondition then
    Result := ATrueResult
  else
    Result := AFaultResult;
end;

Function TForm1.IIF(const ACondition: boolean; const ATrueResult, AFaultResult: String) : String;
begin
  if ACondition then
    Result := ATrueResult
  else
    Result := AFaultResult;
end;

Function TForm1.IIF(const ACondition: boolean; const ATrueResult, AFaultResult: Variant) : Variant;
begin
  if ACondition then
    Result := ATrueResult
  else
    Result := AFaultResult;
end;

Function TForm1.CheckFolder(CurrentFolder: String; CurrentDbf:String; CurrentDocument:String; CurrentDocumentDoc:String;
         CurrentTemporary:String; CurrentTemporaryDoc:String) : Integer;
var
  i:integer;
  i2:integer;
  tem:boolean;
begin
  //showmessage(FloatToStr(Diskfree(0) div (1024*1024)));
  if Diskfree(0) div (1024*1024) < 100 then
  begin
    showmessage('Drive ' + ExtractFileDrive(Paramstr(0)) + ' memory to low' + chr(13) + 'Memory should be more then 100MB');
    Halt;
  end;

  //case GetDriveType(PChar(ExtractFileDrive(Paramstr(0)))) of
  //  DRIVE_REMOVABLE:
  //    showmessage('Removable or Floppy Drive');
  //  DRIVE_FIXED:
  //    showmessage(' Fixed Drive');
  //  DRIVE_REMOTE:
  //    showmessage(' Network Drive');
  //  DRIVE_CDROM:
  //    showmessage(' CD-ROM Drive');
  //  DRIVE_RAMDISK:
  //    showmessage(' RAM Disk');
  //end;

  if (GetDriveType(PChar(ExtractFileDrive(Paramstr(0)))) = DRIVE_CDROM) or (GetDriveType(PChar(ExtractFileDrive(Paramstr(0)))) = DRIVE_RAMDISK ) then
  begin
    showmessage('Software not run on CD-ROM Drive and RAM Disk');
    Halt;
  end;

  //vMutex := CreateMutex(nil, True,  Pchar(Application.Title));
  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    showmessage('Program already open');
    Halt;
  end;
  //If FileExists(ParamStr(0)) Then showmessage(ParamStr(0));

  If (NOT FileExists(CurrentFolder+iif(RightStr(CurrentFolder,1)='\','','\')+CurrentDbf)) Then
  begin
    showmessage('No data base found');
    halt;
  end;

  If (NOT DirectoryExists(GetCurrentDir+iif(RightStr(CurrentFolder,1)='\','','\')+CurrentDocument)) then
   begin
    showmessage('No Documents folder found');
    halt;
  end;

  tem := False;
  i2:=0;
  for i := 1 to 36 do
  begin
    //showmessage(GetCurrentDir+iif(RightStr(GetCurrentDir,1)='\','','\')+CurrentDocumentDoc+IntToStr(i));
    If (NOT DirectoryExists(CurrentFolder+iif(RightStr(CurrentFolder,1)='\','','\')+CurrentDocumentDoc+IntToStr(i))) and (i2=0) Then
    begin
      tem := True;
      i2:=i;
    end;

  if tem = true then
  begin
    showmessage('Documents folder not correct');
    halt;
  end;

  If (NOT DirectoryExists(GetCurrentDir+iif(RightStr(CurrentFolder,1)='\','','\')+CurrentTemporary)) then
   begin
    showmessage('No Temporary folder found');
    halt;
  end;

  tem := False;
  i2:=0;
  end;
  for i := 1 to 36 do
  begin
    If (NOT DirectoryExists(CurrentFolder+iif(RightStr(CurrentFolder,1)='\','','\')+CurrentTemporaryDoc+IntToStr(i))) and (i2=0) Then
    begin
      tem := True;
      i2:=i;
    end;
  end;

  if tem = true then
  begin
    showmessage('Temporary folder not correct');
    halt;
  end;
end;
Function TForm1.OpenDbf(DbfX: Tdbf; CurrentFolder: String; CurrentDbfFolder: String; CurrentDbfFile: String) : Integer;
begin
  DbfX.FilePath:=CurrentP+iif(RightStr(CurrentFolder,1)='\','','\')+CurrentDbfFolder;
  DbfX.FilePathFull:=CurrentP+iif(RightStr(CurrentFolder,1)='\','','\')+CurrentDbfFolder;
  DbfX.TableName:=CurrentDbfFile;
end;

Function TForm1.SetDbfToReadyReturnMaxID(DbfX: Tdbf; FilterX: String; FieldID: String; MoveRecordToLast: boolean) : Integer;
var
  i: integer;
  Tem: integer;
begin
  Result := 0;
  DbfX.Open;

  DbfX.Filter:=FilterX;
  DbfX.Filtered:=True;
  DbfX.First;
  if DbfX.ExactRecordCount > 0 then
  begin
    i:=DbfX.ExactRecordCount;
    //showmessage(IntToStr(i));
    for i:=1 to DbfX.ExactRecordCount do
    begin
       DbfX.Delete;
       DbfX.Next;
    end;
    DbfX.PackTable;
  end;
    DbfX.Filter:='';
    DbfX.Filtered:=False;
    DbfX.First;

    if DbfX.ExactRecordCount <= 0 then
    begin
      DbfX.Edit;
      DbfX.Append;
      DbfX.Post;
    end;

    for i:=1 to DbfX.PhysicalRecordCount do
    begin
      if Result <= StrToInt(iif(TryStrToInt(DbfX.FieldByName(FieldID).Text,tem),DbfX.FieldByName(FieldID).Text,'0')) then Result := StrToInt(iif(TryStrToInt(Dbf1.FieldByName(FieldID).Text,tem),Dbf1.FieldByName(FieldID).Text,'0'))+1;
      DbfX.Next;
    end;

  DbfX.Last;
  if DbfX.FieldByName(FieldID).Text <> '' then
  begin
    DbfX.Edit;
    DbfX.Append;
    DbfX.Post;
  end;
  if MoveRecordToLast then DbfX.Last else DbfX.First;
end;

Function TForm1.ReadDbfReturnString(DbfX: Tdbf;
         Db1X: String; Db2X: String; Db3X: String; Db4X: String; Db5X: String; Db6X: String; Db7X: String; Db8X: String;
         Db9X: String; Db10X: String; Db11X: String; Db12X: String; Db13X: String; Db14X: String; Db15X: String) : String;
var
  i:String;
  i2:Integer;
  i3:Integer;
  i4:String;
begin
  If (DbfX.ExactRecordCount > 0) then
  begin
    i:='';
    if Db1X <> '' then i:=i+DbfX.FieldByName(Db1X).Text;
    if Db2X <> '' then i:=i+DbfX.FieldByName(Db2X).Text;
    if Db3X <> '' then i:=i+DbfX.FieldByName(Db3X).Text;
    if Db4X <> '' then i:=i+DbfX.FieldByName(Db4X).Text;
    if Db5X <> '' then i:=i+DbfX.FieldByName(Db5X).Text;
    if Db6X <> '' then i:=i+DbfX.FieldByName(Db6X).Text;
    if Db7X <> '' then i:=i+DbfX.FieldByName(Db7X).Text;
    if Db8X <> '' then i:=i+DbfX.FieldByName(Db8X).Text;
    if Db9X <> '' then i:=i+DbfX.FieldByName(Db9X).Text;
    if Db10X <> '' then i:=i+DbfX.FieldByName(Db10X).Text;
    if Db11X <> '' then i:=i+DbfX.FieldByName(Db11X).Text;
    if Db12X <> '' then i:=i+DbfX.FieldByName(Db12X).Text;
    if Db13X <> '' then i:=i+DbfX.FieldByName(Db13X).Text;
    if Db14X <> '' then i:=i+DbfX.FieldByName(Db14X).Text;
    if Db15X <> '' then i:=i+DbfX.FieldByName(Db15X).Text;


    //i:= Dbf1.FieldByName('DB1').Text + Dbf1.FieldByName('DB2').Text+  Dbf1.FieldByName('DB3').Text;
    //i:= i + Dbf1.FieldByName('DB4').Text +  Dbf1.FieldByName('DB5').Text +  Dbf1.FieldByName('DB6').Text;
    //i:= i + Dbf1.FieldByName('DB7').Text +  Dbf1.FieldByName('DB8').Text +  Dbf1.FieldByName('DB9').Text;
    //i:= i + Dbf1.FieldByName('DB10').Text +  Dbf1.FieldByName('DB11').Text +  Dbf1.FieldByName('DB12').Text;
    //i:= i + Dbf1.FieldByName('DB13').Text +  Dbf1.FieldByName('DB14').Text +  Dbf1.FieldByName('DB15').Text;

    i3:=0; i4:='';
    for i2:=1 to Length(i) do
    begin
      i3:=ord(i[i2]);
      i4:= i4+chr((i3));
      i3:=0;
    end;

    Result:=i4;
  end;
end;

procedure TForm1.ShiftValue(var DataX: Array of String; Y: Integer; X: Integer; Empty_String: String);
var
  i:integer;
  i2:integer;
begin
  //Setlength(Image_,Shape_Unit);
  //if not Assigned(Image_[Shape_Unit-1]) then

  //for i := X to ((Y-1)*X) do Memo2.Text:=Memo2.Text+','+IntToStr(i);

  i:=X;
  while i <= (Y-1)*(X) do
   begin
     //Memo2.Text:=Memo2.Text+chr(13)+IntToStr(i-X)+'-'+IntToStr(i)+','+IntToStr(i-1)+'-'+IntToStr(i+1);
     for i2:=1 to X do DataX[i-i2]:=DataX[i+X-i2];
     //DataX[i-X]:=DataX[i];
     //DataX[i-1]:=DataX[i+1];
     i:=i+X;
   end;
  //Memo2.Text:='';
  for i2:=((Y-1)*(X)) to (Y*X)-1 do DataX[i2]:=Empty_String;  //Memo2.Text:=Memo2.Text+chr(13)+ IntToStr(i2);
  //DataX[0]:='4';
  //DataX[1]:='5';
  //DataX[2]:='6';

end;

Function TForm1.RealTimeSaveRecord(SourceTxt: TMemo; DbfX: Tdbf; ID_Control: String; IndexCurrent: Integer;
  TotalChaperPerRceord: Integer;
  Db1X: String; Db2X: String; Db3X: String; Db4X: String; Db5X: String; Db6X: String; Db7X: String; Db8X: String;
  Db9X: String; Db10X: String; Db11X: String; Db12X: String; Db13X: String; Db14X: String; Db15X: String) : String;
var
  i:string;
  i2:integer;
  tem:integer;
  Tem2:integer;
begin
  //RealTimeSaveRecordStatic: array [1..50,1..2] of String; //PhysicalRecNo/ID
  DbfX.Edit;
  i:='';
  for i2:=1 to  Length(SourceTxt.Text) do i:=i+Chr(StrToInt(FormatFloat('000',ord(SourceTxt.Text[i2]))));

  if (ID_Control <> '') and (SourceTxt.Text <> '') then
  begin
    Tem2:=0;
    for i2:=1 to 50 do
    begin
      if (RealTimeSaveRecordStatic[i2,1]<>'') then
        if (DbfX.PhysicalRecNo=StrToInt(RealTimeSaveRecordStatic[i2,1])) then Tem2:=i2;
    end;
    if (Not TryStrToInt(DbfX.FieldByName(ID_Control).Text,tem)) and (Tem2=0) then
    begin
      DbfX.FieldByName(ID_Control).Text:= IntToStr(IndexCurrent);
      IndexCurrent:=IndexCurrent+1;
    end;
    if (Not TryStrToInt(DbfX.FieldByName(ID_Control).Text,tem)) and (Tem2<>0) then
    begin
      DbfX.FieldByName(ID_Control).Text:= RealTimeSaveRecordStatic[Tem2,2];
      RealTimeSaveRecordStatic[Tem2,1]:='';
      RealTimeSaveRecordStatic[Tem2,2]:='';
    end;
    //Memo2.Text:=IntToStr(Tem2);
    //for i2:=1 to 50 do Memo2.Text:=Memo2.Text + chr(13)+ RealTimeSaveRecordStatic[i2,1] + ',' + RealTimeSaveRecordStatic[i2,2] ;
  end;

  Tem2:=0;
  if (ID_Control <> '') and (SourceTxt.Text = '') then
  begin
    if (DbfX.FieldByName(ID_Control).Text<>'') then
    begin
      for tem:=1 to 50 do
      begin
        if RealTimeSaveRecordStatic[tem,1]=IntToStr(DbfX.PhysicalRecNo) then
        begin
          RealTimeSaveRecordStatic[tem,1]:=IntToStr(DbfX.PhysicalRecNo);
          RealTimeSaveRecordStatic[tem,2]:=DbfX.FieldByName(ID_Control).Text;
          Tem2:=1;
        end;
      end;
      if Tem2=0 then
      begin
        ShiftValue(RealTimeSaveRecordStatic[1,1],50,2,'');
        RealTimeSaveRecordStatic[50,1]:=IntToStr(DbfX.PhysicalRecNo);
        RealTimeSaveRecordStatic[50,2]:=DbfX.FieldByName(ID_Control).Text;
      end;
      DbfX.FieldByName(ID_Control).Text:='';
    end;
    //Memo3.Text:='';
    //for i2:=1 to 50 do Memo3.Text:=Memo3.Text + chr(13)+ RealTimeSaveRecordStatic[i2,1] + ',' + RealTimeSaveRecordStatic[i2,2] ;
  end;

  Result:=IntToStr(IndexCurrent);

  Tem2:=TotalChaperPerRceord;
  if Db1X <> '' then
  begin
    if Tem2=TotalChaperPerRceord then
    begin
      DbfX.FieldByName(Db1X).Text:= (LeftStr((i),TotalChaperPerRceord));
      Tem2:=Tem2+TotalChaperPerRceord;
    end;
  end;

  if Db2X <> '' then
  begin
    if Tem2=TotalChaperPerRceord then
      DbfX.FieldByName(Db2X).Text:= (LeftStr((i),TotalChaperPerRceord))
    else
      DbfX.FieldByName(Db2X).Text:= (RightStr(LeftStr((i),Tem2),iif(Length((i))>=Tem2,TotalChaperPerRceord,Length((i))-(Tem2-TotalChaperPerRceord))));
    Tem2:=Tem2+TotalChaperPerRceord;
  end;

  if Db3X <> '' then
  begin
    if Tem2=TotalChaperPerRceord then
      DbfX.FieldByName(Db3X).Text:= (LeftStr((i),TotalChaperPerRceord))
    else
      DbfX.FieldByName(Db3X).Text:= (RightStr(LeftStr((i),Tem2),iif(Length((i))>=Tem2,TotalChaperPerRceord,Length((i))-(Tem2-TotalChaperPerRceord))));
    Tem2:=Tem2+TotalChaperPerRceord;
  end;

  if Db4X <> '' then
  begin
    if Tem2=TotalChaperPerRceord then
      DbfX.FieldByName(Db4X).Text:= (LeftStr((i),TotalChaperPerRceord))
    else
      DbfX.FieldByName(Db4X).Text:= (RightStr(LeftStr((i),Tem2),iif(Length((i))>=Tem2,TotalChaperPerRceord,Length((i))-(Tem2-TotalChaperPerRceord))));
    Tem2:=Tem2+TotalChaperPerRceord;
  end;

  if Db5X <> '' then
  begin
    if Tem2=TotalChaperPerRceord then
      DbfX.FieldByName(Db5X).Text:= (LeftStr((i),TotalChaperPerRceord))
    else
      DbfX.FieldByName(Db5X).Text:= (RightStr(LeftStr((i),Tem2),iif(Length((i))>=Tem2,TotalChaperPerRceord,Length((i))-(Tem2-TotalChaperPerRceord))));
    Tem2:=Tem2+TotalChaperPerRceord;
  end;

  if Db6X <> '' then
  begin
    if Tem2=TotalChaperPerRceord then
      DbfX.FieldByName(Db6X).Text:= (LeftStr((i),TotalChaperPerRceord))
    else
      DbfX.FieldByName(Db6X).Text:= (RightStr(LeftStr((i),Tem2),iif(Length((i))>=Tem2,TotalChaperPerRceord,Length((i))-(Tem2-TotalChaperPerRceord))));
    Tem2:=Tem2+TotalChaperPerRceord;
  end;

  if Db7X <> '' then
  begin
    if Tem2=TotalChaperPerRceord then
      DbfX.FieldByName(Db7X).Text:= (LeftStr((i),TotalChaperPerRceord))
    else
      DbfX.FieldByName(Db7X).Text:= (RightStr(LeftStr((i),Tem2),iif(Length((i))>=Tem2,TotalChaperPerRceord,Length((i))-(Tem2-TotalChaperPerRceord))));
    Tem2:=Tem2+TotalChaperPerRceord;
  end;

  if Db8X <> '' then
  begin
    if Tem2=TotalChaperPerRceord then
      DbfX.FieldByName(Db8X).Text:= (LeftStr((i),TotalChaperPerRceord))
    else
      DbfX.FieldByName(Db8X).Text:= (RightStr(LeftStr((i),Tem2),iif(Length((i))>=Tem2,TotalChaperPerRceord,Length((i))-(Tem2-TotalChaperPerRceord))));
    Tem2:=Tem2+TotalChaperPerRceord;
  end;

  if Db9X <> '' then
  begin
    if Tem2=TotalChaperPerRceord then
      DbfX.FieldByName(Db9X).Text:= (LeftStr((i),TotalChaperPerRceord))
    else
      DbfX.FieldByName(Db9X).Text:= (RightStr(LeftStr((i),Tem2),iif(Length((i))>=Tem2,TotalChaperPerRceord,Length((i))-(Tem2-TotalChaperPerRceord))));
    Tem2:=Tem2+TotalChaperPerRceord;
  end;

  if Db10X <> '' then
  begin
    if Tem2=TotalChaperPerRceord then
      DbfX.FieldByName(Db10X).Text:= (LeftStr((i),TotalChaperPerRceord))
    else
      DbfX.FieldByName(Db10X).Text:= (RightStr(LeftStr((i),Tem2),iif(Length((i))>=Tem2,TotalChaperPerRceord,Length((i))-(Tem2-TotalChaperPerRceord))));
    Tem2:=Tem2+TotalChaperPerRceord;
  end;

  if Db11X <> '' then
  begin
    if Tem2=TotalChaperPerRceord then
      DbfX.FieldByName(Db11X).Text:= (LeftStr((i),TotalChaperPerRceord))
    else
      DbfX.FieldByName(Db11X).Text:= (RightStr(LeftStr((i),Tem2),iif(Length((i))>=Tem2,TotalChaperPerRceord,Length((i))-(Tem2-TotalChaperPerRceord))));
    Tem2:=Tem2+TotalChaperPerRceord;
  end;

  if Db12X <> '' then
  begin
    if Tem2=TotalChaperPerRceord then
      DbfX.FieldByName(Db12X).Text:= (LeftStr((i),TotalChaperPerRceord))
    else
      DbfX.FieldByName(Db12X).Text:= (RightStr(LeftStr((i),Tem2),iif(Length((i))>=Tem2,TotalChaperPerRceord,Length((i))-(Tem2-TotalChaperPerRceord))));
    Tem2:=Tem2+TotalChaperPerRceord;
  end;

  if Db13X <> '' then
  begin
    if Tem2=TotalChaperPerRceord then
      DbfX.FieldByName(Db13X).Text:= (LeftStr((i),TotalChaperPerRceord))
    else
      DbfX.FieldByName(Db13X).Text:= (RightStr(LeftStr((i),Tem2),iif(Length((i))>=Tem2,TotalChaperPerRceord,Length((i))-(Tem2-TotalChaperPerRceord))));
    Tem2:=Tem2+TotalChaperPerRceord;
  end;

  if Db14X <> '' then
  begin
    if Tem2=TotalChaperPerRceord then
      DbfX.FieldByName(Db14X).Text:= (LeftStr((i),TotalChaperPerRceord))
    else
      DbfX.FieldByName(Db14X).Text:= (RightStr(LeftStr((i),Tem2),iif(Length((i))>=Tem2,TotalChaperPerRceord,Length((i))-(Tem2-TotalChaperPerRceord))));
    Tem2:=Tem2+TotalChaperPerRceord;
  end;

  if Db15X <> '' then
  begin
    if Tem2=TotalChaperPerRceord then
      DbfX.FieldByName(Db15X).Text:= (LeftStr((i),TotalChaperPerRceord))
    else
      DbfX.FieldByName(Db15X).Text:= (RightStr(LeftStr((i),Tem2),iif(Length((i))>=Tem2,TotalChaperPerRceord,Length((i))-(Tem2-TotalChaperPerRceord))));
    Tem2:=Tem2+TotalChaperPerRceord;
  end;

    //DbfX.FieldByName(Db1X).Text:= (LeftStr((i),TotalChaperPerRceord));
    //DbfX.FieldByName(Db2X).Text:= (RightStr(LeftStr((i),120),iif(Length((i))>=120,TotalChaperPerRceord,Length((i))-60)));
    //DbfX.FieldByName(Db3X).Text:= (RightStr(LeftStr((i),180),iif(Length((i))>=180,TotalChaperPerRceord,Length((i))-120)));
    //DbfX.FieldByName(Db4X).Text:= (RightStr(LeftStr((i),240),iif(Length((i))>=240,TotalChaperPerRceord,Length((i))-180)));
    //DbfX.FieldByName(Db5X).Text:= (RightStr(LeftStr((i),300),iif(Length((i))>=300,TotalChaperPerRceord,Length((i))-240)));
    //DbfX.FieldByName(Db6X).Text:= (RightStr(LeftStr((i),360),iif(Length((i))>=360,TotalChaperPerRceord,Length((i))-300)));
    //DbfX.FieldByName(Db7X).Text:= (RightStr(LeftStr((i),420),iif(Length((i))>=420,TotalChaperPerRceord,Length((i))-360)));
    //DbfX.FieldByName(Db8X).Text:= (RightStr(LeftStr((i),480),iif(Length((i))>=480,TotalChaperPerRceord,Length((i))-420)));
    //DbfX.FieldByName(Db9X).Text:= (RightStr(LeftStr((i),540),iif(Length((i))>=540,TotalChaperPerRceord,Length((i))-480)));
    //DbfX.FieldByName(Db10X).Text:= (RightStr(LeftStr((i),600),iif(Length((i))>=600,TotalChaperPerRceord,Length((i))-540)));
    //DbfX.FieldByName(Db11X).Text:= (RightStr(LeftStr((i),660),iif(Length((i))>=660,TotalChaperPerRceord,Length((i))-600)));
    //DbfX.FieldByName(Db12X).Text:= (RightStr(LeftStr((i),720),iif(Length((i))>=720,TotalChaperPerRceord,Length((i))-660)));
    //DbfX.FieldByName(Db13X).Text:= (RightStr(LeftStr((i),780),iif(Length((i))>=780,TotalChaperPerRceord,Length((i))-720)));
    //DbfX.FieldByName(Db14X).Text:= (RightStr(LeftStr((i),840),iif(Length((i))>=840,TotalChaperPerRceord,Length((i))-780)));
    //DbfX.FieldByName(Db15X).Text:= (RightStr(LeftStr((i),900),iif(Length((i))>=900,TotalChaperPerRceord,Length((i))-840)));

    DbfX.Post;

  //showmessage(IntToStr(DbfX.RecNo));
  if (ID_Control <> '') and (SourceTxt.Text <> '') then
  begin
    if (DbfX.RecNo >= DbfX.RecordCount) and (DbfX.FieldByName(ID_Control).Text <> '') then
    begin
      tem:= DbfX.RecNo;
      DbfX.Edit;
      DbfX.Append;
      DbfX.Post;
      DbfX.RecNo:=tem;
    end;
  end
  else
  begin
    if (DbfX.RecNo >= DbfX.RecordCount) and (SourceTxt.Text <> '') then
    begin
      tem:= DbfX.RecNo;
      DbfX.Edit;
      DbfX.Append;
      DbfX.Post;
      DbfX.RecNo:=tem;
    end;
  end;
end;

Function TForm1.DeleteRecord(DbfX: Tdbf; ID_Control: String; SaveUndo: boolean) : String;
var
  tem:String;
  tem2:Boolean;
  tem3:Integer;
  Reply:Integer;
  i2:Integer;
begin
  if (DbfX.ExactRecordCount > 0) and (((DbfX.FieldByName(ID_Control).Text = '') and (DbfX.PhysicalRecNo<>DbfX.PhysicalRecordCount)) or (DbfX.FieldByName(ID_Control).Text <> '')) then
  begin
    Result:='';
    Reply:=Application.MessageBox('มีความต้องการลบข้อมูล'+sLineBreak+'กด Yes เพื่อตกลง','ข้อมูลกำลังจะถูกลบ',MB_ICONWARNING+MB_YESNO);
    if Reply=IDYES then
    begin

      tem:=DbfX.Filter;
      tem2:=DbfX.Filtered;
      tem3:=DbfX.RecNo;

      for i2:=1 to 50 do
      begin
      if (RealTimeSaveRecordStatic[i2,1]<>'') then
        if (DbfX.PhysicalRecNo=StrToInt(RealTimeSaveRecordStatic[i2,1])) then
        begin
          RealTimeSaveRecordStatic[i2,1]:='';
          RealTimeSaveRecordStatic[i2,2]:='';
        end;
      end;

      if SaveUndo then
      begin
        //UndoData_: array [1..400,1..57] of String; //Page/ActionNumber/DbfName/PhysicalRecNo/PhyRecTop/ID/Data1..51
        //                                           //New => Page/1/DbfName/PhysicalRecNo/''/''/''..
        //                                           //Delete=>Page/2/DbfName/PhysicalRecNo/PhyRecTop/ID/Data1..51
        //UndoIndex: Integer;
        UndoData_[UndoIndex,1]:='1';
        UndoData_[UndoIndex,2]:='2';
        UndoData_[UndoIndex,3]:='Dbf1';
        UndoData_[UndoIndex,4]:=IntToStr(Dbf1.PhysicalRecNo);
        UndoData_[UndoIndex,5]:=IntToStr(Dbf1.PhysicalRecNo-1);
        UndoData_[UndoIndex,6]:=Dbf1.FieldByName('ID').Text;
        //showmessage(Dbf1.Fields.Fields[0].DisplayName);
        for i2:=7 to 21 do UndoData_[UndoIndex,i2]:=Dbf1.Fields.Fields[i2-6].Text;
        //showmessage(UndoData_[UndoIndex,7]+','+UndoData_[UndoIndex,8]+','+UndoData_[UndoIndex,9]);
        UndoIndex:=UndoIndex+1;
        ClearRedo;
      end;

      DbfX.Delete;
      DbfX.PackTable;

      DbfX.Filtered := False;
      DbfX.Last;

      if (DbfX.FieldByName(ID_Control).Text <> '') then
      begin
        DbfX.Edit;
        DbfX.Append;
        DbfX.Post;
      end;

      DbfX.Filter:=tem;
      DbfX.Filtered:=tem2;
      DbfX.RecNo:=tem3;

      Result:='Delete'
    end;
  end;
end;

procedure TForm1.ClearRedo();
var
  i:integer;
  i2:integer;
begin
  RedoIndex:=1;
  for i:=1 to 400 do
    for i2:=1 to 57 do
      RedoData_[i,i2]:='';
end;

procedure TForm1.DBGrid5CellClick(Column: TColumn);
//var
  //i:String;
  //i2:Integer;
  //i3:Integer;
  //i4:String;
begin

  Memo1.Text:=ReadDbfReturnString(Dbf1,'DB1','DB2','DB3','DB4','DB5','DB6','DB7','DB8',
                           'DB9', 'DB10', 'DB11', 'DB12', 'DB13', 'DB14', 'DB15');

  //If (Dbf1.ExactRecordCount > 0) then // and (Dbf1.FieldByName('ID').Text<>'') and (Dbf1.FieldByName('DB1').Text<>'') then
  //begin
  //  i:= Dbf1.FieldByName('DB1').Text + Dbf1.FieldByName('DB2').Text+  Dbf1.FieldByName('DB3').Text;
  //  i:= i + Dbf1.FieldByName('DB4').Text +  Dbf1.FieldByName('DB5').Text +  Dbf1.FieldByName('DB6').Text;
  //  i:= i + Dbf1.FieldByName('DB7').Text +  Dbf1.FieldByName('DB8').Text +  Dbf1.FieldByName('DB9').Text;
  //  i:= i + Dbf1.FieldByName('DB10').Text +  Dbf1.FieldByName('DB11').Text +  Dbf1.FieldByName('DB12').Text;
  //  i:= i + Dbf1.FieldByName('DB13').Text +  Dbf1.FieldByName('DB14').Text +  Dbf1.FieldByName('DB15').Text;
  //  i3:=0; i4:='';
  //  for i2:=1 to Length(i) do
  //  begin
  //    i3:=ord(i[i2]);
  //    i4:= i4+chr((i3));
  //    i3:=0;
  //  end;
  //
  //  Memo1.Text:=i4;
  //end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  dbf1.Close;
  //OpenDialog1.Close;
  //OpenDialog1.CleanupInstance;
  //OpenDialog1.Free;
  Halt;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  tem:String;
//  tem2:Boolean;
//  tem3:Integer;
//  Reply : Integer;
begin
  tem:=DeleteRecord(Dbf1,'ID',True);
  Memo1.Text:=ReadDbfReturnString(Dbf1,'DB1','DB2','DB3','DB4','DB5','DB6','DB7','DB8',
                               'DB9', 'DB10', 'DB11', 'DB12', 'DB13', 'DB14', 'DB15');

  //if (Dbf1.ExactRecordCount > 0) and (Dbf1.FieldByName('ID').Text <> '') then
  //begin
  //  Reply:=Application.MessageBox('มีความต้องการลบข้อมูล'+sLineBreak+'กด Yes เพื่อตกลง','ข้อมูลกำลังจะถูกลบ',MB_ICONWARNING+MB_YESNO);
  //  if Reply=IDYES then
  //  begin
  //
  //    tem:=Dbf1.Filter;
  //    tem2:=Dbf1.Filtered;
  //    tem3:=Dbf1.RecNo;
  //
  //    Dbf1.Delete;
  //    Dbf1.PackTable;
  //
  //    Dbf1.Filtered := False;
  //    Dbf1.Last;
  //
  //    if (Dbf1.FieldByName('ID').Text <> '') then
  //    begin
  //      Dbf1.Edit;
  //      Dbf1.Append;
  //      Dbf1.Post;
  //    end;
  //
  //    Dbf1.Filter:=tem;
  //    Dbf1.Filtered:=tem2;
  //    Dbf1.RecNo:=tem3;
  //
  //    Memo1.Text:=ReadDbfReturnString(Dbf1,'DB1','DB2','DB3','DB4','DB5','DB6','DB7','DB8',
  //                             'DB9', 'DB10', 'DB11', 'DB12', 'DB13', 'DB14', 'DB15');
  //  end;
  //end;

end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i:String;
  i2:Integer;
  i3:Integer;
  i4:String;
begin
  //UndoData_: array [1..400,1..57] of String; //Page/ActionNumber/DbfName/PhysicalRecNo/PhyRecTop/ID/Data1..51
                                             //New => Page/1/DbfName/PhysicalRecNo/''/''/''..
                                             //Delete=>Page/ActionNumber/DbfName/PhysicalRecNo/PhyRecTop/ID/Data1..51
  //UndoIndex: Integer;
  //RedoData_: array [1..400,1..57] of String; //Page/ActionNumber/DbfName/PhysicalRecNo/PhyRecTop/ID/Data1..51
                                             //New => Page/1/DbfName/PhysicalRecNo/''/''/''..
                                             //Delete=>Page/2/DbfName/PhysicalRecNo/PhyRecTop/ID/Data1..51
  //RedoIndex: Integer;

  if UndoIndex >1 then
  begin
    //showmessage(UndoData_[UndoIndex-1,1]+','+UndoData_[UndoIndex-1,2]+','+UndoData_[UndoIndex-1,3]+','+UndoData_[UndoIndex-1,4]+','+UndoData_[UndoIndex-1,5]+','+UndoData_[UndoIndex-1,6]);
    If (UndoData_[UndoIndex-1,1]='1') and (UndoData_[UndoIndex-1,2]='2') and (UndoData_[UndoIndex-1,3]='Dbf1') then
    begin
      Dbf1.Last;
      i:='';
      for i2:=7 to 21 do i:=i+UndoData_[UndoIndex-1,i2];
      i3:=0; i4:='';
      for i2:=1 to Length(i) do
      begin
        i3:=ord(i[i2]);
        i4:= i4+chr((i3));
        i3:=0;
      end;
      Memo1.Text:=i4;
      i2:=StrToInt(UndoData_[UndoIndex-1,6]);
      i2:=StrToInt(RealTimeSaveRecord(Memo1, Dbf1, 'ID', i2,
                                 60, 'DB1', 'DB2', 'DB3', 'DB4', 'DB5', 'DB6',
                                 'DB7', 'DB8', 'DB9', 'DB10', 'DB11', 'DB12', 'DB13', 'DB14', 'DB15'));
      Memo1.Text:=ReadDbfReturnString(Dbf1,'DB1','DB2','DB3','DB4','DB5','DB6','DB7','DB8',
                                    'DB9', 'DB10', 'DB11', 'DB12', 'DB13', 'DB14', 'DB15');
      UndoData_[UndoIndex-1,4]:=IntToStr(Dbf1.PhysicalRecNo);
      UndoData_[UndoIndex-1,5]:=IntToStr(Dbf1.PhysicalRecNo-1);
    end;
    showmessage('Undo สำเร็จ'+chr(13)+UndoData_[UndoIndex-1,4]+','+UndoData_[UndoIndex-1,6]+','+UndoData_[UndoIndex-1,7]);

    for i2:=1 to 57 do
    begin
      RedoData_[RedoIndex,i2]:=UndoData_[UndoIndex-1,i2];
      UndoData_[UndoIndex-1,i2]:='';
    end;
    RedoIndex:=RedoIndex+1;
    UndoIndex:=UndoIndex-1;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i:integer;
  tem:String;
begin
  //UndoData_: array [1..400,1..57] of String; //Page/ActionNumber/DbfName/PhysicalRecNo/PhyRecTop/ID/Data1..51
                                             //New => Page/1/DbfName/PhysicalRecNo/''/''/''..
                                             //Delete=>Page/ActionNumber/DbfName/PhysicalRecNo/PhyRecTop/ID/Data1..51
  //UndoIndex: Integer;
  //RedoData_: array [1..400,1..57] of String; //Page/ActionNumber/DbfName/PhysicalRecNo/PhyRecTop/ID/Data1..51
                                             //New => Page/1/DbfName/PhysicalRecNo/''/''/''..
                                             //Delete=>Page/2/DbfName/PhysicalRecNo/PhyRecTop/ID/Data1..51
  //RedoIndex: Integer;
  if RedoIndex >1 then
  begin
    //showmessage(RedoData_[RedoIndex-1,1]+','+RedoData_[RedoIndex-1,2]+','+RedoData_[RedoIndex-1,3]+','+RedoData_[UndoIndex-1,4]+','+RedoData_[UndoIndex-1,5]+','+RedoData_[UndoIndex-1,6]);
    If (RedoData_[RedoIndex-1,1]='1') and (RedoData_[RedoIndex-1,2]='2') and (RedoData_[RedoIndex-1,3]='Dbf1') then
    begin
      Dbf1.PhysicalRecNo:=StrToInt(RedoData_[RedoIndex-1,4]);
      tem:=DeleteRecord(Dbf1,'ID',False);
      Memo1.Text:=ReadDbfReturnString(Dbf1,'DB1','DB2','DB3','DB4','DB5','DB6','DB7','DB8',
                                      'DB9', 'DB10', 'DB11', 'DB12', 'DB13', 'DB14', 'DB15');
    end;
    for i:=1 to 57 do
    begin
      UndoData_[UndoIndex,i]:=RedoData_[RedoIndex-1,i];
      RedoData_[RedoIndex-1,i]:='';
    end;
    RedoIndex:=RedoIndex-1;
    UndoIndex:=UndoIndex+1;
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Dbf1.Last;
  Memo1.Text:=ReadDbfReturnString(Dbf1,'DB1','DB2','DB3','DB4','DB5','DB6','DB7','DB8',
                               'DB9', 'DB10', 'DB11', 'DB12', 'DB13', 'DB14', 'DB15');

  //UndoData_: array [1..400,1..57] of String; //Page/ActionNumber/DbfName/PhysicalRecNo/PhyRecTop/ID/Data1..51
  //                                           //New => Page/1/DbfName/PhysicalRecNo/''/''/''..
  //                                           //Delete=>Page/2/DbfName/PhysicalRecNo/PhyRecTop/ID/Data1..51
  //UndoIndex: Integer;
  if (UndoData_[UndoIndex,1]<>'1') or (UndoData_[UndoIndex,2]<>'1') or (UndoData_[UndoIndex,3]<>'Dbf1')
     or (UndoData_[UndoIndex,4]<>IntToStr(Dbf1.PhysicalRecNo)) then
  begin
    UndoData_[UndoIndex,1]:='1';
    UndoData_[UndoIndex,2]:='1';
    UndoData_[UndoIndex,3]:='Dbf1';
    UndoData_[UndoIndex,4]:=IntToStr(Dbf1.PhysicalRecNo);
    UndoIndex:=UndoIndex+1;
    ClearRedo;
  end;
  Memo1.SetFocus;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i:integer;
  i2:integer;
begin
  RealTimeSaveRecordIndex:=1;
  for i:=1 to 50 do
    for i2:=1 to 2 do
      RealTimeSaveRecordStatic[i,i2]:='';

  UndoIndex:=1;
  for i:=1 to 400 do
    for i2:=1 to 57 do
      UndoData_[i,i2]:='';

  ClearRedo;

  DB_Index:=0;

  CurrentP:= GetCurrentDir;
  //showmessage(GetCurrentDir);
  //showmessage(Application.Location);
  //showmessage(Paramstr(0));
  //showmessage(ExtractFileName(GetCurrentDir));
  //showmessage(ExtractFilePath(GetCurrentDir));
  //showmessage(ExtractFileExt(GetCurrentDir));
  //showmessage(ExtractFileDir(GetCurrentDir));
  //showmessage(ExtractFileDrive(GetCurrentDir));
  //showmessage(ExtractFileDrive(Paramstr(0)));

  CheckFolder(CurrentP,'Data\lookerup.dbf','Documents','Documents\Docu','Temporary','Temporary\Docu');


  //showmessage(intTostr(GetFontData(Form1.Handle).Orientation));
  //showmessage((GetFontData(Form1.Handle).Name));
  //for i := 1 to  Screen.Fonts.Count-1 do
  //begin
  //screen.Fonts.GetNameValue(i,i6,i7);
  //Listbox17.Items.Add(i7);
  //end;
  //Screen.Fonts.GetNameValue(0,i6,i7);
  //showmessage(i6+i7);
  //showmessage(intTostr(Screen.Fonts.IndexOfName((GetFontData(Form1.Handle).Name))));

  OpenDbf(Dbf1,CurrentP,'Data\','lookerup.dbf');

  DB_Index:=SetDbfToReadyReturnMaxID(Dbf1, 'ID = "" OR DB1 = ""','id', True);

  DBGrid5.Columns.Items[0].Title.Caption:='ID';
  DBGrid5.Columns.Items[0].Width:=40;
  DBGrid5.Columns.Items[1].Title.Caption:='ที่อยู่';
  DBGrid5.Columns.Items[1].Width:=200;
  DBGrid5.Columns.Items[2].Title.Caption:='...';
  DBGrid5.Columns.Items[2].Width:=200;
  DBGrid5.Columns.Items[15].Destroy;
  DBGrid5.Columns.Items[14].Destroy;
  DBGrid5.Columns.Items[13].Destroy;
  DBGrid5.Columns.Items[12].Destroy;
  DBGrid5.Columns.Items[11].Destroy;
  DBGrid5.Columns.Items[10].Destroy;
  DBGrid5.Columns.Items[9].Destroy;
  DBGrid5.Columns.Items[8].Destroy;
  DBGrid5.Columns.Items[7].Destroy;
  DBGrid5.Columns.Items[6].Destroy;
  DBGrid5.Columns.Items[5].Destroy;
  DBGrid5.Columns.Items[4].Destroy;
  DBGrid5.Columns.Items[3].Destroy;
end;

procedure TForm1.Memo1EditingDone(Sender: TObject);
//var
//  i:string;
//  i2:integer;
//  tem:integer;
begin
  //  Dbf1.Edit;
  //  i:='';
  //  for i2:=1 to  Length(Memo1.Text) do
  //   i:=i+Chr(StrToInt(FormatFloat('000',ord(Memo1.Text[i2]))));
  //
  //  if Not TryStrToInt(Dbf1.FieldByName('ID').Text,tem) then
  //  begin
  //    Dbf1.FieldByName('ID').Text:= IntToStr(DB_Index);
  //    DB_Index:=DB_Index+1;
  //  end;
  //
  //  Dbf1.FieldByName('DB1').Text:= (LeftStr((i),60));
  //  Dbf1.FieldByName('DB2').Text:= (RightStr(LeftStr((i),120),iif(Length((i))>=120,60,Length((i))-60)));
  //  Dbf1.FieldByName('DB3').Text:= (RightStr(LeftStr((i),180),iif(Length((i))>=180,60,Length((i))-120)));
  //  Dbf1.FieldByName('DB4').Text:= (RightStr(LeftStr((i),240),iif(Length((i))>=240,60,Length((i))-180)));
  //  Dbf1.FieldByName('DB5').Text:= (RightStr(LeftStr((i),300),iif(Length((i))>=300,60,Length((i))-240)));
  //  Dbf1.FieldByName('DB6').Text:= (RightStr(LeftStr((i),360),iif(Length((i))>=360,60,Length((i))-300)));
  //  Dbf1.FieldByName('DB7').Text:= (RightStr(LeftStr((i),420),iif(Length((i))>=420,60,Length((i))-360)));
  //  Dbf1.FieldByName('DB8').Text:= (RightStr(LeftStr((i),480),iif(Length((i))>=480,60,Length((i))-420)));
  //  Dbf1.FieldByName('DB9').Text:= (RightStr(LeftStr((i),540),iif(Length((i))>=540,60,Length((i))-480)));
  //  Dbf1.FieldByName('DB10').Text:= (RightStr(LeftStr((i),600),iif(Length((i))>=600,60,Length((i))-540)));
  //  Dbf1.FieldByName('DB11').Text:= (RightStr(LeftStr((i),660),iif(Length((i))>=660,60,Length((i))-600)));
  //  Dbf1.FieldByName('DB12').Text:= (RightStr(LeftStr((i),720),iif(Length((i))>=720,60,Length((i))-660)));
  //  Dbf1.FieldByName('DB13').Text:= (RightStr(LeftStr((i),780),iif(Length((i))>=780,60,Length((i))-720)));
  //  Dbf1.FieldByName('DB14').Text:= (RightStr(LeftStr((i),840),iif(Length((i))>=840,60,Length((i))-780)));
  //  Dbf1.FieldByName('DB15').Text:= (RightStr(LeftStr((i),900),iif(Length((i))>=900,60,Length((i))-840)));
  //
  //  Dbf1.Post;
  //
  ////showmessage(IntToStr(Dbf1.RecNo));
  //if (Dbf1.RecNo >= Dbf1.RecordCount) and (Dbf1.FieldByName('ID').Text <> '') then
  //begin
  //  tem:= Dbf1.RecNo;
  //  Dbf1.Edit;
  //  Dbf1.Append;
  //  Dbf1.Post;
  //  Dbf1.RecNo:=tem;
  //end;

  DB_Index:=StrToInt(RealTimeSaveRecord(Memo1, Dbf1, 'ID', DB_Index,
             60, 'DB1', 'DB2', 'DB3', 'DB4', 'DB5', 'DB6',
             'DB7', 'DB8', 'DB9', 'DB10', 'DB11', 'DB12', 'DB13', 'DB14', 'DB15'));
end;

procedure TForm1.Memo1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
//var
//  i:string;
//  i2:integer;
begin


  DB_Index:=StrToInt(RealTimeSaveRecord(Memo1, Dbf1, 'ID', DB_Index,
             60, 'DB1', 'DB2', 'DB3', 'DB4', 'DB5', 'DB6',
             'DB7', 'DB8', 'DB9', 'DB10', 'DB11', 'DB12', 'DB13', 'DB14', 'DB15'));

//     Dbf1.Edit;
//    i:='';
//    for i2:=1 to  Length(Memo1.Text) do
//     i:=i+Chr(StrToInt(FormatFloat('000',ord(Memo1.Text[i2]))));
//
//    if Length((i)) <= 60 then
//    begin
//      Dbf1.FieldByName('DB1').Text:= (LeftStr((i),Length((i))));
//      Dbf1.FieldByName('DB2').Text:='';
//      Dbf1.FieldByName('DB3').Text:='';
//      Dbf1.FieldByName('DB4').Text:='';
//      Dbf1.FieldByName('DB5').Text:='';
//      Dbf1.FieldByName('DB6').Text:='';
//      Dbf1.FieldByName('DB7').Text:='';
//      Dbf1.FieldByName('DB8').Text:='';
//      Dbf1.FieldByName('DB9').Text:='';
//      Dbf1.FieldByName('DB10').Text:='';
//      Dbf1.FieldByName('DB11').Text:='';
//      Dbf1.FieldByName('DB12').Text:='';
//      Dbf1.FieldByName('DB13').Text:='';
//      Dbf1.FieldByName('DB14').Text:='';
//      Dbf1.FieldByName('DB15').Text:='';
//    end;
//    if (Length((i)) > 60) and (Length((i)) <= 120) then
//    begin
//      Dbf1.FieldByName('DB1').Text:= (LeftStr((i),60));
//      Dbf1.FieldByName('DB2').Text:= (RightStr(LeftStr((i),120),iif(Length((i))>=120,60,Length((i))-60)));
//      Dbf1.FieldByName('DB3').Text:='';
//      Dbf1.FieldByName('DB4').Text:='';
//      Dbf1.FieldByName('DB5').Text:='';
//      Dbf1.FieldByName('DB6').Text:='';
//      Dbf1.FieldByName('DB7').Text:='';
//      Dbf1.FieldByName('DB8').Text:='';
//      Dbf1.FieldByName('DB9').Text:='';
//      Dbf1.FieldByName('DB10').Text:='';
//      Dbf1.FieldByName('DB11').Text:='';
//      Dbf1.FieldByName('DB12').Text:='';
//      Dbf1.FieldByName('DB13').Text:='';
//      Dbf1.FieldByName('DB14').Text:='';
//      Dbf1.FieldByName('DB15').Text:='';
//    end;
//    if (Length((i)) > 120) and (Length((i)) <= 180) then
//    begin
//      Dbf1.FieldByName('DB1').Text:= (LeftStr((i),60));
//      Dbf1.FieldByName('DB2').Text:= (RightStr(LeftStr((i),120),60));
//      Dbf1.FieldByName('DB3').Text:= (RightStr(LeftStr((i),180),iif(Length((i))>=180,60,Length((i))-120)));
//      Dbf1.FieldByName('DB4').Text:='';
//      Dbf1.FieldByName('DB5').Text:='';
//      Dbf1.FieldByName('DB6').Text:='';
//      Dbf1.FieldByName('DB7').Text:='';
//      Dbf1.FieldByName('DB8').Text:='';
//      Dbf1.FieldByName('DB9').Text:='';
//      Dbf1.FieldByName('DB10').Text:='';
//      Dbf1.FieldByName('DB11').Text:='';
//      Dbf1.FieldByName('DB12').Text:='';
//      Dbf1.FieldByName('DB13').Text:='';
//      Dbf1.FieldByName('DB14').Text:='';
//      Dbf1.FieldByName('DB15').Text:='';
//    end;
//    if (Length((i)) > 180) and (Length((i)) <= 240) then
//    begin
//      Dbf1.FieldByName('DB1').Text:= (LeftStr((i),60));
//      Dbf1.FieldByName('DB2').Text:= (RightStr(LeftStr((i),120),60));
//      Dbf1.FieldByName('DB3').Text:= (RightStr(LeftStr((i),180),60));
//      Dbf1.FieldByName('DB4').Text:= (RightStr(LeftStr((i),240),iif(Length((i))>=240,60,Length((i))-180)));
//      Dbf1.FieldByName('DB5').Text:='';
//      Dbf1.FieldByName('DB6').Text:='';
//      Dbf1.FieldByName('DB7').Text:='';
//      Dbf1.FieldByName('DB8').Text:='';
//      Dbf1.FieldByName('DB9').Text:='';
//      Dbf1.FieldByName('DB10').Text:='';
//      Dbf1.FieldByName('DB11').Text:='';
//      Dbf1.FieldByName('DB12').Text:='';
//      Dbf1.FieldByName('DB13').Text:='';
//      Dbf1.FieldByName('DB14').Text:='';
//      Dbf1.FieldByName('DB15').Text:='';
//    end;
//    if (Length((i)) > 240) and (Length((i)) <= 300) then
//    begin
//      Dbf1.FieldByName('DB1').Text:= (LeftStr((i),60));
//      Dbf1.FieldByName('DB2').Text:= (RightStr(LeftStr((i),120),60));
//      Dbf1.FieldByName('DB3').Text:= (RightStr(LeftStr((i),180),60));
//      Dbf1.FieldByName('DB4').Text:= (RightStr(LeftStr((i),240),60));
//      Dbf1.FieldByName('DB5').Text:= (RightStr(LeftStr((i),300),iif(Length((i))>=300,60,Length((i))-240)));
//      Dbf1.FieldByName('DB6').Text:='';
//      Dbf1.FieldByName('DB7').Text:='';
//      Dbf1.FieldByName('DB8').Text:='';
//      Dbf1.FieldByName('DB9').Text:='';
//      Dbf1.FieldByName('DB10').Text:='';
//      Dbf1.FieldByName('DB11').Text:='';
//      Dbf1.FieldByName('DB12').Text:='';
//      Dbf1.FieldByName('DB13').Text:='';
//      Dbf1.FieldByName('DB14').Text:='';
//      Dbf1.FieldByName('DB15').Text:='';
//    end;
//    if (Length((i)) > 300) and (Length((i)) <= 360)  then
//    begin
//      Dbf1.FieldByName('DB1').Text:= (LeftStr((i),60));
//      Dbf1.FieldByName('DB2').Text:= (RightStr(LeftStr((i),120),60));
//      Dbf1.FieldByName('DB3').Text:= (RightStr(LeftStr((i),180),60));
//      Dbf1.FieldByName('DB4').Text:= (RightStr(LeftStr((i),240),60));
//      Dbf1.FieldByName('DB5').Text:= (RightStr(LeftStr((i),300),60));
//      Dbf1.FieldByName('DB6').Text:= (RightStr(LeftStr((i),360),iif(Length((i))>=360,60,Length((i))-300)));
//      Dbf1.FieldByName('DB7').Text:='';
//      Dbf1.FieldByName('DB8').Text:='';
//      Dbf1.FieldByName('DB9').Text:='';
//      Dbf1.FieldByName('DB10').Text:='';
//      Dbf1.FieldByName('DB11').Text:='';
//      Dbf1.FieldByName('DB12').Text:='';
//      Dbf1.FieldByName('DB13').Text:='';
//      Dbf1.FieldByName('DB14').Text:='';
//      Dbf1.FieldByName('DB15').Text:='';
//    end;
//    if (Length((i)) > 360) and (Length((i)) <= 420)  then
//    begin
//      Dbf1.FieldByName('DB1').Text:= (LeftStr((i),60));
//      Dbf1.FieldByName('DB2').Text:= (RightStr(LeftStr((i),120),60));
//      Dbf1.FieldByName('DB3').Text:= (RightStr(LeftStr((i),180),60));
//      Dbf1.FieldByName('DB4').Text:= (RightStr(LeftStr((i),240),60));
//      Dbf1.FieldByName('DB5').Text:= (RightStr(LeftStr((i),300),60));
//      Dbf1.FieldByName('DB6').Text:= (RightStr(LeftStr((i),360),60));
//      Dbf1.FieldByName('DB7').Text:= (RightStr(LeftStr((i),420),iif(Length((i))>=420,60,Length((i))-360)));
//      Dbf1.FieldByName('DB8').Text:='';
//      Dbf1.FieldByName('DB9').Text:='';
//      Dbf1.FieldByName('DB10').Text:='';
//      Dbf1.FieldByName('DB11').Text:='';
//      Dbf1.FieldByName('DB12').Text:='';
//      Dbf1.FieldByName('DB13').Text:='';
//      Dbf1.FieldByName('DB14').Text:='';
//      Dbf1.FieldByName('DB15').Text:='';
//    end;
//    if (Length((i)) > 420) and (Length((i)) <= 480)  then
//    begin
//      Dbf1.FieldByName('DB1').Text:= (LeftStr((i),60));
//      Dbf1.FieldByName('DB2').Text:= (RightStr(LeftStr((i),120),60));
//      Dbf1.FieldByName('DB3').Text:= (RightStr(LeftStr((i),180),60));
//      Dbf1.FieldByName('DB4').Text:= (RightStr(LeftStr((i),240),60));
//      Dbf1.FieldByName('DB5').Text:= (RightStr(LeftStr((i),300),60));
//      Dbf1.FieldByName('DB6').Text:= (RightStr(LeftStr((i),360),60));
//      Dbf1.FieldByName('DB7').Text:= (RightStr(LeftStr((i),420),60));
//      Dbf1.FieldByName('DB9').Text:='';
//      Dbf1.FieldByName('DB10').Text:='';
//      Dbf1.FieldByName('DB11').Text:='';
//      Dbf1.FieldByName('DB12').Text:='';
//      Dbf1.FieldByName('DB13').Text:='';
//      Dbf1.FieldByName('DB14').Text:='';
//      Dbf1.FieldByName('DB15').Text:='';
//    end;
//    if (Length((i)) > 480) and (Length((i)) <= 540)  then
//    begin
//      Dbf1.FieldByName('DB1').Text:= (LeftStr((i),60));
//      Dbf1.FieldByName('DB2').Text:= (RightStr(LeftStr((i),120),60));
//      Dbf1.FieldByName('DB3').Text:= (RightStr(LeftStr((i),180),60));
//      Dbf1.FieldByName('DB4').Text:= (RightStr(LeftStr((i),240),60));
//      Dbf1.FieldByName('DB5').Text:= (RightStr(LeftStr((i),300),60));
//      Dbf1.FieldByName('DB6').Text:= (RightStr(LeftStr((i),360),60));
//      Dbf1.FieldByName('DB7').Text:= (RightStr(LeftStr((i),420),60));
//      Dbf1.FieldByName('DB8').Text:= (RightStr(LeftStr((i),480),60));
//      Dbf1.FieldByName('DB9').Text:= (RightStr(LeftStr((i),540),iif(Length((i))>=540,60,Length((i))-480)));
//      Dbf1.FieldByName('DB10').Text:='';
//      Dbf1.FieldByName('DB11').Text:='';
//      Dbf1.FieldByName('DB12').Text:='';
//      Dbf1.FieldByName('DB13').Text:='';
//      Dbf1.FieldByName('DB14').Text:='';
//      Dbf1.FieldByName('DB15').Text:='';
//    end;
//    if (Length((i)) > 540) and (Length((i)) <= 600)  then
//    begin
//      Dbf1.FieldByName('DB1').Text:= (LeftStr((i),60));
//      Dbf1.FieldByName('DB2').Text:= (RightStr(LeftStr((i),120),60));
//      Dbf1.FieldByName('DB3').Text:= (RightStr(LeftStr((i),180),60));
//      Dbf1.FieldByName('DB4').Text:= (RightStr(LeftStr((i),240),60));
//      Dbf1.FieldByName('DB5').Text:= (RightStr(LeftStr((i),300),60));
//      Dbf1.FieldByName('DB6').Text:= (RightStr(LeftStr((i),360),60));
//      Dbf1.FieldByName('DB7').Text:= (RightStr(LeftStr((i),420),60));
//      Dbf1.FieldByName('DB8').Text:= (RightStr(LeftStr((i),480),60));
//      Dbf1.FieldByName('DB9').Text:= (RightStr(LeftStr((i),540),60));
//      Dbf1.FieldByName('DB10').Text:= (RightStr(LeftStr((i),600),iif(Length((i))>=600,60,Length((i))-540)));
//      Dbf1.FieldByName('DB11').Text:='';
//      Dbf1.FieldByName('DB12').Text:='';
//      Dbf1.FieldByName('DB13').Text:='';
//      Dbf1.FieldByName('DB14').Text:='';
//      Dbf1.FieldByName('DB15').Text:='';
//    end;
//    if (Length((i)) > 600) and (Length((i)) <= 660)  then
//    begin
//      Dbf1.FieldByName('DB1').Text:= (LeftStr((i),60));
//      Dbf1.FieldByName('DB2').Text:= (RightStr(LeftStr((i),120),60));
//      Dbf1.FieldByName('DB3').Text:= (RightStr(LeftStr((i),180),60));
//      Dbf1.FieldByName('DB4').Text:= (RightStr(LeftStr((i),240),60));
//      Dbf1.FieldByName('DB5').Text:= (RightStr(LeftStr((i),300),60));
//      Dbf1.FieldByName('DB6').Text:= (RightStr(LeftStr((i),360),60));
//      Dbf1.FieldByName('DB7').Text:= (RightStr(LeftStr((i),420),60));
//      Dbf1.FieldByName('DB8').Text:= (RightStr(LeftStr((i),480),60));
//      Dbf1.FieldByName('DB9').Text:= (RightStr(LeftStr((i),540),60));
//      Dbf1.FieldByName('DB10').Text:= (RightStr(LeftStr((i),600),60));
//      Dbf1.FieldByName('DB11').Text:= (RightStr(LeftStr((i),660),iif(Length((i))>=660,60,Length((i))-600)));
//      Dbf1.FieldByName('DB12').Text:='';
//      Dbf1.FieldByName('DB13').Text:='';
//      Dbf1.FieldByName('DB14').Text:='';
//      Dbf1.FieldByName('DB15').Text:='';
//    end;
//    if (Length((i)) > 660) and (Length((i)) <= 720)  then
//    begin
//      Dbf1.FieldByName('DB1').Text:= (LeftStr((i),60));
//      Dbf1.FieldByName('DB2').Text:= (RightStr(LeftStr((i),120),60));
//      Dbf1.FieldByName('DB3').Text:= (RightStr(LeftStr((i),180),60));
//      Dbf1.FieldByName('DB4').Text:= (RightStr(LeftStr((i),240),60));
//      Dbf1.FieldByName('DB5').Text:= (RightStr(LeftStr((i),300),60));
//      Dbf1.FieldByName('DB6').Text:= (RightStr(LeftStr((i),360),60));
//      Dbf1.FieldByName('DB7').Text:= (RightStr(LeftStr((i),420),60));
//      Dbf1.FieldByName('DB8').Text:= (RightStr(LeftStr((i),480),60));
//      Dbf1.FieldByName('DB9').Text:= (RightStr(LeftStr((i),540),60));
//      Dbf1.FieldByName('DB10').Text:= (RightStr(LeftStr((i),600),60));
//      Dbf1.FieldByName('DB11').Text:= (RightStr(LeftStr((i),660),60));
//      Dbf1.FieldByName('DB12').Text:= (RightStr(LeftStr((i),720),iif(Length((i))>=720,60,Length((i))-660)));
//      Dbf1.FieldByName('DB13').Text:='';
//      Dbf1.FieldByName('DB14').Text:='';
//      Dbf1.FieldByName('DB15').Text:='';
//    end;
//    if (Length((i)) > 720)  then
//    begin
//      Dbf1.FieldByName('DB1').Text:= (LeftStr((i),60));
//      Dbf1.FieldByName('DB2').Text:= (RightStr(LeftStr((i),120),60));
//      Dbf1.FieldByName('DB3').Text:= (RightStr(LeftStr((i),180),60));
//      Dbf1.FieldByName('DB4').Text:= (RightStr(LeftStr((i),240),60));
//      Dbf1.FieldByName('DB5').Text:= (RightStr(LeftStr((i),300),60));
//      Dbf1.FieldByName('DB6').Text:= (RightStr(LeftStr((i),360),60));
//      Dbf1.FieldByName('DB7').Text:= (RightStr(LeftStr((i),420),60));
//      Dbf1.FieldByName('DB8').Text:= (RightStr(LeftStr((i),480),60));
//      Dbf1.FieldByName('DB9').Text:= (RightStr(LeftStr((i),540),60));
//      Dbf1.FieldByName('DB10').Text:= (RightStr(LeftStr((i),600),60));
//      Dbf1.FieldByName('DB11').Text:= (RightStr(LeftStr((i),660),60));
//      Dbf1.FieldByName('DB12').Text:= (RightStr(LeftStr((i),720),60));
//      Dbf1.FieldByName('DB13').Text:= (RightStr(LeftStr((i),780),iif(Length((i))>=780,60,Length((i))-720)));
//      Dbf1.FieldByName('DB14').Text:='';
//      Dbf1.FieldByName('DB15').Text:='';
//    end;
//    Dbf1.Post;
end;

end.

