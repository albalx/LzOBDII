unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  lazSerial, lazsynaser, IniFiles;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form2: TForm2;
  INI: TINIFile;
  puerto : string;

const
  C_General = 'General';


implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.Button2Click(Sender: TObject);
begin
  Form2.Close;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  puerto := ComboBox1.Text;
  INI := TINIFile.Create('Conf.ini');
  INI.WriteString(C_General,'puerto',puerto);
  INI.Free;
  Form2.Close;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  INI := TINIFile.Create('Conf.ini');
  puerto := INI.ReadString(C_General,'puerto','');
  INI.Free;
  ComboBox1.Items.CommaText :=  GetSerialPortNames();
  ComboBox1.Text:= puerto;
 end;

end.

