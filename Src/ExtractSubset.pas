unit ExtractSubset;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ovcsc, ovcbase, ovcef, ovcpb, ovcnf;

type
  TfrmExtractSubset = class(TForm)
    leInFileName: TLabeledEdit;
    leOutFileName: TLabeledEdit;
    btnCancel: TButton;
    btnOK: TButton;
    ovcWordLen: TOvcNumericField;
    OvcSpinner1: TOvcSpinner;
    Label1: TLabel;
    lblStatus: TLabel;
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent); override;
  end;

var
  frmExtractSubset: TfrmExtractSubset;

implementation

uses MyUtils;

{$R *.dfm}

{ TfrmExtractSubset }

constructor TfrmExtractSubset.Create(aOwner: TComponent);
begin
  inherited;
  ovcWordLen.AsInteger := 4;
end;

procedure TfrmExtractSubset.btnOKClick(Sender: TObject);
var
  InFile, OutFile: textfile;
  Line: string;
  NrRead, NrWritten: integer;
  Temp: string;
begin
  AssignFile(InFile, leInFileName.Text);
  Reset(InFile);
  AssignFile(OutFile, leOutFileName.Text);
  ReWrite(OutFile);
  NrRead := 0;
  NrWritten := 0;
  try
    while not Eof(InFile) do
      begin
        ReadLn(InFile, Line);
        Inc(NrRead);
        Line := Trim(Line);
        if Length(Line) = ovcWordLen.AsInteger then
          begin
            WriteLn(OutFile, Line);
            Inc(NrWritten);
          end;
        ReadLn(InFile, Line);
        if (NrRead mod 100) = 0 then
          begin
            lblStatus.Caption := Format('%d read, %d written', [NrRead, NrWritten]);
            Application.ProcessMessages;
          end;
      end;
  finally
    CloseFile(OutFile);
    CloseFile(InFile);
    lblStatus.Caption := Format('COMPLETE. %d read, %d written', [NrRead, NrWritten]);
    Application.ProcessMessages;
    temp := Format('Notepad.exe %s', [leOutFileName.Text]);
    FileExecute(temp, false);
  end;
end;

end.
