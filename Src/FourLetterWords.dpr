program FourLetterWords;

uses
//  FastMM4,
  ExceptionLog,
  Forms,
  FourLetterWordsMain in 'FourLetterWordsMain.pas' {frm4LetterWordsMain},
  ExtractSubset in 'ExtractSubset.pas' {frmExtractSubset},
  MyUtils in '..\..\MyUtils\MyUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfrm4LetterWordsMain, frm4LetterWordsMain);
  Application.CreateForm(TfrmExtractSubset, frmExtractSubset);
  Application.Run;
end.
