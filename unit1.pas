unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, DbCtrls, ComCtrls, ExtCtrls, unit2, LazSerial, sqlite3conn, sqldb, db,
  IniFiles, strutils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    BtnCon: TButton;
    BtnDesc: TButton;
    Button4: TButton;
    Button5: TButton;
    DataSource1: TDataSource;
    DBMemo1: TDBMemo;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    ListBox1: TListBox;
    Memo1: TMemo;
    Serie: TLazSerial;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    DBconector: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    Timer2: TTimer;
    Timer3: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure BtnConClick(Sender: TObject);
    procedure BtnDescClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1SelectionChange(Sender: TObject; User: boolean);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure SerieRxData(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  INI: TINIFile;
  puerto, palabra, reci, datoSN, NumFall, CodFall : string;
  dato : integer;

const
  C_General = 'General';

implementation

{$R *.lfm}

{ TForm1 }

Function HexToStr(s: String): String;
Var i: Integer;
Begin
  Result:=''; i:=1;
  While i<Length(s) Do Begin
    Result:=Result+Chr(StrToIntDef('$'+Copy(s,i,2),0));
    Inc(i,2);
  End;
End;

procedure NumeroFallas;
begin

end;

procedure CodFallas;
begin

end;

procedure SerialNumber;
 var
 letra : char;
 par1 :string;
 par : integer;
begin
 datoSN:= DelSpace(datoSN);
 letra := #$0A;
 datoSN:= DelChars(datoSN, letra);
 delete(datoSN,1,16);
 delete(datoSN,3,6);
 delete(datoSN,11,6);
 delete(datoSN,19,6);
 delete(datoSN,27,6);
 delete(datoSN,35,6);
 //Edit1.Text:= HexToStr(datoSN);
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  //Serie.ShowSetupDialog;
  Form2.ShowModal;
 end;

procedure TForm1.SerieRxData(Sender: TObject);

begin
  reci := reci + Serie.ReadData;
  if palabra = 'OK' then
  if Pos(palabra, reci) <> 0  then StatusBar1.SimpleText:= 'Adaptador Conectado';

  if palabra = 'VIN' then
  begin
    datoSN:= reci;
    SerialNumber;
 //   Memo1.Text:=datoSN;
 //   Edit1.Text:= HexToStr(datoSN);
    palabra:= 'FIN';
  end;

  if palabra = 'NUM_FALLA' then
   begin
     NumFall:= reci;
     NumeroFallas;
     palabra:= 'FIN';
  end;

  if palabra = 'COD_FALLA' then
   begin
     CodFall:= reci;
     CodFallas;
     palabra:= 'FIN';
  end;


end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if palabra = 'VIN' then
  begin
   reci := '';
   Serie.WriteData('0101'+#$D);
   palabra := 'NUM_FALLA';
   Timer2.Enabled:=True;
  end;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  if palabra = 'NUM_FALLA' then
  begin
   reci := '';
   Serie.WriteData('03'+#$D);
   palabra := 'COD_FALLA';
   Timer3.Enabled:=True;
  end;
end;

procedure TForm1.Timer3Timer(Sender: TObject);
begin

end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  Form1.close;
end;

procedure TForm1.BtnConClick(Sender: TObject);
begin
  INI := TINIFile.Create('Conf.ini');
  puerto := INI.ReadString(C_General,'puerto','');
  Serie.Device := puerto;
  INI.Free;
  Serie.Open;
  reci := '';
  sleep(500);
  Serie.WriteData('at sp 0'+#$D);
  palabra := 'OK';
  BtnDesc.Enabled:=True;
  BtnCon.Enabled:=False;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  reci := '';
  Edit2.Text:='';
  palabra:= 'VIN';
 // Serie.WriteData(#$D);
  Serie.WriteData('0902'+#$D);
  Timer1.Enabled:=True;


  //palabra:= 'FIN';
end;

procedure TForm1.BtnDescClick(Sender: TObject);
begin
  Serie.Close;
  BtnDesc.Enabled:=False;
  BtnCon.Enabled:=True;
  StatusBar1.SimpleText:= 'Adaptador desconectado'
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  puerto := Serie.Device;
  INI := TINIFile.Create('Conf.ini');
  INI.WriteString(C_General,'puerto',puerto);
  INI.Free;
  SQLQuery1.Close;
  SQLTransaction1.Active:= False;
  DBConector.Connected:= False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  INI := TINIFile.Create('Conf.ini');
  puerto := INI.ReadString(C_General,'puerto','');
  Serie.Device := puerto;
  INI.Free;
end;

procedure TForm1.ListBox1SelectionChange(Sender: TObject; User: boolean);
var
falla : string;
begin
  SQLQuery1.Close;
  SQLQuery1.SQL.Text:= 'select Falla from generico where Codigo = :CodFalla';
  falla:=  ListBox1.GetSelectedText;
  SQLQuery1.Params.ParamByName('CodFalla').AsString := falla;
  DBConector.Connected:= True;
  SQLTransaction1.Active:= True;
  SQLQuery1.Open;

end;


end.


