unit FourLetterWordsMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, Grids;

const
  MAX_PATH_LEN = 100;

type
  TWordMatrix = array['a'..'z', 'a'..'z', 'a'..'z', 'a'..'z'] of boolean;

  TWordItem = record
    TheWord: string;
    Score: single;
  end;

  TWordList = class
  private
    fCount: integer;
    fItems: array of TWordItem;
    fSortedByScore: boolean;
    function GetSortedByScore: boolean;
    procedure SetSortedByScore(const Value: boolean);
    function GetCount: integer;
    procedure SetCount(const Value: integer);
    function GetItem(Idx: integer): TWordItem;
    procedure SetItem(Idx: integer; const Value: TWordItem);
    function GetMaxCount: integer;
    procedure SetMaxCount(const Value: integer);
  public
    procedure Add(const TheWord: string; TheScore: single);
    procedure Assign(WordList: TWordList; aCount: integer);
    procedure Delete(Index: integer; var aCount: integer); overload;
    procedure Clear;
    procedure Exchange(I, J: integer);
    function IndexOf(const aWord: string; MaxCount: integer = 0): integer;
    procedure Insert(Index: Integer; const aWord: string; aScore: single);
    property SortedByScore: boolean
             read GetSortedByScore
             write SetSortedByScore;
    property Count: integer
             read GetCount
             write SetCount;
    property MaxCount: integer
             read GetMaxCount
             write SetMaxCount;
    property Items[Idx: integer]: TWordItem
             read GetItem
             write SetItem; default;
    constructor Create; virtual;
  end;

  Tfrm4LetterWordsMain = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    PrintSetup1: TMenuItem;
    Print1: TMenuItem;
    N2: TMenuItem;
    SaveAs1: TMenuItem;
    Save1: TMenuItem;
    Open1: TMenuItem;
    New1: TMenuItem;
    Edit1: TMenuItem;
    N4: TMenuItem;
    Paste1: TMenuItem;
    Copy1: TMenuItem;
    Cut1: TMenuItem;
    N5: TMenuItem;
    Undo1: TMenuItem;
    Functions1: TMenuItem;
    ExctractFourLettersWordstoFile1: TMenuItem;
    lblStatus: TLabel;
    leSrcWord: TLabeledEdit;
    FindSimilarWords1: TMenuItem;
    ReCreateWordList1: TMenuItem;
    leTarget: TLabeledEdit;
    FindPathtoTarget1: TMenuItem;
    StringGrid1: TStringGrid;
    ReloadWords1: TMenuItem;
    ListofWordswithnoSimilarWords1: TMenuItem;
    ListofWordsbySimilarity1: TMenuItem;
    lblResults: TLabel;
    procedure ExctractFourLettersWordstoFile1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure leSrcWordChange(Sender: TObject);
    procedure FindSimilarWords1Click(Sender: TObject);
    procedure ReCreateWordList1Click(Sender: TObject);
    procedure FindPathtoTarget1Click(Sender: TObject);
    procedure ReloadWords1Click(Sender: TObject);
    procedure leTargetChange(Sender: TObject);
    procedure ListofWordswithnoSimilarWords1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure ListofWordsbySimilarity1Click(Sender: TObject);
  private
    { Private declarations }
{$IfDef debug}
    fLogFileName: string;
{$EndIf}    
    fNrRead: integer;
    fOutFile: TextFile;
    fPathCount: integer;
    fShortestPathLen: integer;
    fLastShortestPathLen: integer;
    fLastTicks: double;
    fStartTime: double;
    fWordMatrix: TWordMatrix;
    fWordsInProcess: TWordList;
    fShortestPathList: TWordList;
    fFourLetterWordsFileName: string;
    procedure LoadWordMatrix;
    procedure ClearList(List: TWordList); 
    function FindSimilarWords(const aWord, TargetWord: string; SimilarWords: TWordList): single;
    function Similarity(Word1, Word2: string): single;
    function FindPathToTarget(const SrcWord, TargetWord: string;
      RecursionLevel: integer): integer;
    function WordExists(const TheWord: string): boolean;
    procedure UpdateStatus(const Msg: string; BackColor: TColor = clBtnFace; FontColor: TColor = clWindowText);
    procedure DumpPath(const Title: string; Count: integer; CloseIt: boolean);
    procedure ShowShortestPath(ShortestPathList: TWordList; SrcWord,
      TargetWord: string; PathLen: integer);
    function PathsPerSecond(TotalElapsed: double): double;
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent); override;
  end;

var
  frm4LetterWordsMain: Tfrm4LetterWordsMain;

implementation

uses
  ExtractSubset, MyUtils, Math;

{$R *.dfm}

const
  COL_NR     = 0;
  COL_NAME   = 1;
  COL_SCORE  = 2;

var
  gRootPath: string;

procedure Tfrm4LetterWordsMain.LoadWordMatrix;
var
  InFile: TextFile;
  Line: string;
  ch1, ch2, ch3, ch4: char;

  function HasVowels(const aWord: string): boolean;
  var
    i: integer;
  begin
    result := false;
    for i := 1 to 4 do
      if aWord[i] in ['a', 'e', 'i', 'o', 'u', 'y'] then
        begin
          result := true;
          exit;
        end;
  end;

begin
  for ch1 := 'a' to 'z' do
    for ch2 := 'a' to 'z' do
      for ch3 := 'a' to 'z' do
        for ch4 := 'a' to 'z' do
          fWordMatrix[ch1, ch2, ch3, ch4] := false;

  AssignFile(InFile, fFourLetterWordsFileName);
  Reset(InFile);
  fNrRead := 0;
  try
    while not Eof(InFile) do
      begin
        ReadLn(InFile, Line);
        Line := CleanUpString(Line, ['a'..'z']);
        if (Length(Line) = 4) and (HasVowels(Line)) then
          begin
            fWordMatrix[Line[1], Line[2], Line[3], Line[4]] := true;
            inc(fNrRead);
          end;
      end;
  finally
    CloseFile(InFile);
    UpdateStatus(Format('%d 4 letter words loaded', [fNrRead]));
  end;
end;


constructor Tfrm4LetterWordsMain.Create(aOwner: TComponent);
begin
  inherited;
  gRootPath := ExtractFilePath(ParamStr(0));
  fFourLetterWordsFileName := gRootPath + 'words4.txt';
  LoadWordMatrix;
end;

procedure Tfrm4LetterWordsMain.ExctractFourLettersWordstoFile1Click(Sender: TObject);
begin
  with frmExtractSubset do
    ShowModal;
end;

procedure Tfrm4LetterWordsMain.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure Tfrm4LetterWordsMain.UpdateStatus(const Msg: string; BackColor, FontColor: TColor);
begin
  lblStatus.Caption    := Msg;
  lblStatus.Color      := BackColor;
  lblStatus.Font.Color := FontColor;
  Application.ProcessMessages;
end;


function Tfrm4LetterWordsMain.WordExists(const TheWord: string): boolean;
var
  aWord: string;
  ConnectedWords: TWordList;
begin
  result := false;
  aWord  := LowerCase(TheWord);
  if Length(aWord) = 4 then
    begin
      if fWordMatrix[aWord[1], aWord[2], aWord[3], aWord[4]] then
        begin
          ConnectedWords := TWordList.Create;
          try
            if FindSimilarWords(aWord, aWord, ConnectedWords) < 0 then // there are no connected words
              UpdateStatus(Format('There are no words similar to "%s"', [UpperCase(aWord)]),
                             clRed, clWhite)
            else
              UpdateStatus(Format('"%s" was found', [UpperCase(aWord)]),
                           clGreen, clWhite);
          finally
            FreeAndNil(ConnectedWords);
          end
        end
      else
        UpdateStatus(Format('"%s" was NOT found', [UpperCase(aWord)]), clYellow, clWindowText);
    end
  else
    UpdateStatus('Word must be 4 letters long', clYellow, clWindowText);
end;


procedure Tfrm4LetterWordsMain.leSrcWordChange(Sender: TObject);
begin
  WordExists(leSrcWord.Text);
end;

function Tfrm4LetterWordsMain.Similarity(Word1, Word2: string): single;
var
  i: integer;

  function IsVowelLike(ch: char): boolean;
  begin
    result := ch in (VOWELS + ['Y', 'y']);
  end;

begin
  Assert((Length(Word1) = 4) and (Length(Word2) = 4), Format('Invalid word length: "%s" or "%s"', [Word1, Word2]));
  result := 0;
  for i := 1 to 4 do
    if Word1[i] = Word2[i] then
      result := result + 1 else
    if IsVowel(Word1[i]) and IsVowel(Word2[i]) then
      result := result + 0.5 else
    if not (IsVowel(Word1[i]) or IsVowel(Word2[i])) then
      result := result + 0.5 else
    if IsVowelLike(Word1[i]) and IsVowelLike(Word2[i]) then
      result := result + 0.25;
end;

function Tfrm4LetterWordsMain.FindSimilarWords(const aWord, TargetWord: string; SimilarWords: TWordList): single;
var
  ch, ch1, ch2, ch3, ch4: char;
  Column: integer;
  TheWord: string;
  TheScore: single;
begin { FindSimilarWords }
  ch1 := aWord[1];
  ch2 := aWord[2];
  ch3 := aWord[3];
  ch4 := aWord[4];
  for Column := 1 to 4 do
    for ch := 'a' to 'z' do
      begin
        TheWord := '';
        case column of
          1: if fWordMatrix[ch, ch2, ch3, ch4] and (ch <> ch1) then
               TheWord := ch + ch2 + ch3 + ch4;
          2: if fWordMatrix[ch1, ch, ch3, ch4] and (ch <> ch2) then
               TheWord := ch1 + ch + ch3 + ch4;
          3: if fWordMatrix[ch1, ch2, ch, ch4] and (ch <> ch3) then
               TheWord := ch1 + ch2 + ch + ch4;
          4: if fWordMatrix[ch1, ch2, ch3, ch] and (ch <> ch4) then
               TheWord := ch1 + ch2 + ch3 + ch;
        end;
        if TheWord <> '' then
          begin
            TheScore := Similarity(TheWord, TargetWord);
            SimilarWords.Add(TheWord, TheScore);
          end;
      end;

  // Sort the words by similarity to the target from highest to lowest

  SimilarWords.SortedByScore := true;
  if SimilarWords.Count > 0 then
    result := Similarity(SimilarWords[0].TheWord, TargetWord)  // Top of the list is the most similar
  else
    result := -1;  // There aren't ANY similar words
end;  { FindSimilarWords }


procedure Tfrm4LetterWordsMain.FindSimilarWords1Click(Sender: TObject);
var
  SimilarWords: TWordList;
  aWord, TargetWord: string;
  i: integer;
  WordItem: TWordItem;
begin
  SimilarWords    := TWordList.Create;
  try
    aWord := LowerCase(leSrcWord.Text);
    TargetWord := LowerCase(leTarget.text);
    if Empty(TargetWord) then
      TargetWord := leSrcWord.Text;
    FindSimilarWords(aWord, TargetWord, SimilarWords);
    with StringGrid1 do
      begin
        RowCount := SimilarWords.Count;
        for i := 0 to SimilarWords.Count-1 do
          begin
            Cells[COL_NR, i]      := IntToStr(I+1);
            Cells[COL_NAME, i]    := UpperCase(SimilarWords[i].TheWord);
            WordItem              := SimilarWords[i];
            Cells[COL_SCORE, i]   := FloatToStr(RoundTo(WordItem.Score, -2));
          end;
      end;
    UpdateStatus(Format('%s has %d similar words', [UpperCase(aWord), SimilarWords.Count]));
  finally
    ClearList(SimilarWords);
    FreeAndNil(SimilarWords);
  end;
end;

procedure Tfrm4LetterWordsMain.ReCreateWordList1Click(Sender: TObject);
var
  ch1, ch2, ch3, ch4: char;
  FilePath: string;
  Count: integer;
begin
  FilePath := UniqueFileName(gRootPath + 'Words4a.txt');
  if BrowseForFile('File to create', FilePath, '.txt') then
    begin
      AssignFile(fOutFile, FilePath);
      ReWrite(fOutFile);
      Count := 0;
      try
        for ch1 := 'a' to 'z' do
          for ch2 := 'a' to 'z' do
            for ch3 := 'a' to 'z' do
              for ch4 := 'a' to 'z' do
                if fWordMatrix[ch1, ch2, ch3, ch4] then
                  begin
                    WriteLn(fOutFile, ch1, ch2, ch3, ch4);
                    Inc(Count);
                  end;
      finally
        CloseFile(fOutFile);
        MessageFmt('%d words were written to file: %s', [Count, FilePath]);
      end;
    end;
end;

procedure Tfrm4LetterWordsMain.DumpPath(const Title: string; Count: integer; CloseIt: boolean);
{$IfDef Debug}
var
  i: integer;
{$EndIf}
begin

{$IfDef Debug}
  if not CloseIt then
    begin
      fLogFileName := 'C:\temp\LogFile.txt';
      AssignFile(fOutFile, fLogFileName);
      try
        Rewrite(fOutFile);
      except
        on e:Exception do
          ErrorFmt('Error = %s when opening "%s"', [e.Message, fLogFileName]);
      end;
    end;

  WriteLn(fOutFile, Format('%s: PathLen=%d', [Title, Count]));
  WriteLn(fOutFile);

  for i := 0 to Count do
    WriteLn(fOutFile, I:3, ': ', fWordsInProcess[i].TheWord);

  WriteLn(fOutFile);
  WriteLn(fOutFile);

  if CloseIt then
    begin
      CloseFile(fOutFile);
      Sleep(3);
      FileExecute(Format('NotePad.exe %s', [fLogFileName]), false);
    end;
{$EndIF debug}

end;

function Tfrm4LetterWordsMain.PathsPerSecond(TotalElapsed: double): double;
var
  Hours, Minutes, Seconds, MSec: word;
  TotalSeconds: integer;
begin { TotalSeconds }
  DecodeTime(TotalElapsed, Hours, Minutes, Seconds, MSec);
  TotalSeconds := ((Hours *3600) + (Minutes * 60) + Seconds);

  if TotalSeconds > 0 then
    result := fPathCount / TotalSeconds
  else
    result := 0;
end;  { TotalSeconds }

function Tfrm4LetterWordsMain.FindPathToTarget(const SrcWord, TargetWord: string; RecursionLevel: integer): integer;
var
  ConnectedWords: TWordList;
  PathLen: integer;
  i        : integer;
  WordItem : TWordItem;
  Interval: double;
  TotalElapsed: double;

  function RemoveRedundantWords(Count: integer): integer;
  var
    Bottom, Top, K: integer;
    Word1, Word2: string;

    function ChangedIndex(const Word1, Word2: string): byte;
    begin
      for result := 1 to 4 do
        if Word1[result] <> Word2[result] then
          exit;
      raise Exception.CreateFmt('System error: Word1 is the same as Word2 [%s,%s]', [Word1, Word2]);
    end;

    function MisMatch(Const Word1, Word2: string): byte;
    var
      I: integer;
    begin { MisMatch }
      result := 0;
      for I := 1 to 4 do
        if Word1[I] <> Word2[I] then
          Inc(result);
    end;  { MisMatch }

  begin { RemoveRedundantWords }
    result := Count;
    DumpPath('Before', result, false);

    // remove unnecessary steps

    Bottom := result;
    repeat
      Word2 := fWordsInProcess[Bottom].TheWord;

      // starting at the end, look for the earliest previous word that differs by only one letter

      Top := 0;
      while Top <= Bottom - 1 do
        begin
          Word1 := fWordsInProcess[Top].TheWord;
          if MisMatch(Word1, Word2) = 1 then  // this is the earliest word that differs by only one letter
            begin
              // Delete all the words in between
              for k := Bottom-1 downto Top+1 do
                fWordsInProcess.Delete(K, result);
              Bottom := Top + 1;
              Break;
            end;
          Inc(top);
        end;
      Dec(Bottom);
    until (Bottom < 2);

    DumpPath('After', result, true);
  end;  { RemoveRedundantWords }

  procedure DeleteWordsInProcess(ConnectedWords, WordsInProcess: TWordList; WordsInProcessCount: integer);
  var
    i, idx, aCount: integer;
  begin { DeleteWordsInProcess }
    for i := 0 to WordsInprocessCount-1 do
      begin
        idx := ConnectedWords.IndexOf(WordsInProcess[i].TheWord);
        if idx >= 0 then
          begin
            aCount := ConnectedWords.Count;
            ConnectedWords.Delete(Idx, aCount);
            ConnectedWords.Count := aCount;
          end;
      end;
  end;  { DeleteWordsInProcess }

begin { Tfrm4LetterWordsMain.FindPathToTarget }
  result         := -1;
  inc(fPathCount);
  Interval     := (GetTickCount - fLastTicks);
  TotalElapsed := (Now - fStartTime);

  if (Interval > 0) and
     ((fShortestPathLen <> fLastShortestPathLen) or (Interval > 1000.0)) then
    begin
      UpdateStatus(Format('Recursion Level = %d, Shortest Path so far = %d steps, %0.n Paths Checked in %s, %0.n paths/sec',
                          [RecursionLevel,
                           fShortestPathLen,
                           fPathCount*1.0,
                           ElapsedTimeToStr(TotalElapsed),
                           PathsPerSecond(TotalElapsed)]),
                   clBtnFace, clBlack);
      fLastShortestPathLen := fShortestPathLen;
      fLastTicks := GetTickCount;
    end;

  if fWordsInProcess.IndexOf(SrcWord, RecursionLevel) < 0 then  // not already being processed
    begin
      WordItem.TheWord     := SrcWord;
      WordItem.Score       := Similarity(SrcWord, TargetWord);
      fWordsInProcess[RecursionLevel] := WordItem;
      ConnectedWords := TWordList.Create;
      // Find words that are similar to the current source word
      try
        if SameText(SrcWord, TargetWord) then // we found the target
          begin
            fShortestPathLen := RemoveRedundantWords(RecursionLevel);
            result := fShortestPathLen;   // we have reached the target word

            fShortestPathList.Assign(fWordsInProcess, fShortestPathLen+1);
            ShowShortestPath(fShortestPathList, leSrcWord.Text, leTarget.Text, result);
          end
        else
          begin
            FindSimilarWords(SrcWord, TargetWord, ConnectedWords);
            DeleteWordsInProcess(ConnectedWords, fWordsInProcess, RecursionLevel);
            if ConnectedWords.Count > 0 then  // There are some similar words
              begin
                for i := 0 to ConnectedWords.Count-1 do
                  begin
                    if RecursionLevel >= Pred(fShortestPathLen) then  // cannot be anything shorter at this level
                      break;

                    PathLen := FindPathToTarget(ConnectedWords[i].TheWord, TargetWord, RecursionLevel+1);
                    if (PathLen >= 0) and (PathLen < fShortestPathLen) then
                      fShortestPathLen  := PathLen;
                  end;
                result := fShortestPathLen;
              end;
          end;
      finally
        ClearList(ConnectedWords);
        ConnectedWords.Free;
      end;
    end;
end;  { Tfrm4LetterWordsMain.FindPathToTarget }

procedure Tfrm4LetterWordsMain.ShowShortestPath(ShortestPathList: TWordList;
                                 SrcWord, TargetWord: string;
                                 PathLen: integer);
var
  i: integer;
  WordItem: TWordItem;
  TimeStr: string;
  Elapsed: double;
begin
  with StringGrid1 do
    begin
      RowCount := PathLen+1;
      for i := 0 to PathLen do
        begin
          Cells[COL_NR, i]      := IntToStr(I+1);
          WordItem              := fShortestPathList[i];
          Cells[COL_NAME, i]    := UpperCase(WordItem.TheWord);
          Cells[COL_SCORE, i]   := FloatToStr(RoundTo(WordItem.Score, -2));
        end;
    end;
    
  Elapsed := Now - fStartTime;
  if Elapsed > 0 then
    TimeStr := ElapsedTimeToStr(Elapsed)
  else
    TimeStr := '0.0';
    
  lblResults.Caption := Format('A path was found from "%s" to "%s" in %d steps. %0.n paths checked in %s, %0.n paths/sec',
                              [UpperCase(SrcWord),
                               UpperCase(TargetWord),
                               PathLen,
                               fPathCount*1.0,
                               TimeStr,
                               PathsPerSecond(Elapsed)]);
  Application.ProcessMessages;
end;


procedure Tfrm4LetterWordsMain.FindPathtoTarget1Click(Sender: TObject);
var
  SrcWord, TargetWord, Temp: string;
  PathLen: integer;
begin { FindPathtoTarget1Click }
  fStartTime            := Now;
  fWordsInProcess       := TWordList.Create;
  fShortestPathList     := TWordList.Create;
  fShortestPathLen      := MAXINT;
  fPathCount            := 0;
  fLastTicks            := GetTickCount;
  fStartTime            := Now;

  try
    SrcWord    := LowerCase(leSrcWord.Text);
    TargetWord := LowerCase(leTarget.text);
    if not Empty(TargetWord) then
      begin
        PathLen := FindPathToTarget(SrcWord, TargetWord, 0);
        if (PathLen > 0) and (PathLen < MAXINT) then  // we found a path to the target
          begin
            ShowShortestPath(fShortestPathList, SrcWord, TargetWord, PathLen);
            UpdateStatus('Complete', clGreen, clWhite);
          end
        else
          begin
            temp := Format('No Path from "%s" to "%s" could be found',
                           [UpperCase(SrcWord), UpperCase(TargetWord)]);
            UpdateStatus(temp, clRed, clWhite);
          end;
      end
    else
      Alert('Target not specified');
  finally
    ClearList(fWordsInProcess);
    FreeAndNil(fWordsInProcess);
  end;
end;  { FindPathtoTarget1Click }

procedure Tfrm4LetterWordsMain.ClearList(List: TWordList);
begin
  List.Clear;
end;

{ TWordList }

procedure TWordList.Add(const TheWord: string;
  TheScore: single);
var
  WordItem: TWordItem;
  Len: integer;
begin
  WordItem.TheWord     := TheWord;
  WordItem.Score := TheScore;
  Len            := Count;
  fItems[Len]    := WordItem;
  Count          := Count + 1;
end;

procedure TWordList.Assign(WordList: TWordList; aCount: integer);
var
  i: integer;
begin
  Count := aCount;
  for i := 0 to aCount-1 do
    fItems[i] := WordList.Items[i];
end;

procedure TWordList.Clear;
begin
  fCount := 0;
end;

constructor TWordList.Create;
begin
  inherited;
  MaxCount := MAX_PATH_LEN;
end;

procedure TWordList.Delete(Index: integer; var aCount: integer);
var
  i: integer;
begin
  for i := Index to aCount-1 do
    fItems[i] := fItems[i+1];
  aCount := aCount - 1;
end;

procedure TWordList.Exchange(I, J: integer);
var
  WordItem: TWordItem;
begin
  WordItem  := fItems[i];
  fItems[i] := fItems[j];
  fItems[j] := WordItem;
end;

function TWordList.GetCount: integer;
begin
  result := fCount;
end;

function TWordList.GetItem(Idx: integer): TWordItem;
begin
  result := fItems[Idx];
end;

function TWordList.GetMaxCount: integer;
begin
  result := Length(fItems);
end;

function TWordList.GetSortedByScore: boolean;
begin
  result := fSortedByScore;
end;

function TWordList.IndexOf(const aWord: string; MaxCount: integer = 0): integer;
var
  Mode: TSearch_Type;  // SEARCHING, SEARCH_FOUND, NOT_FOUND
  I: integer;
begin
  Mode := SEARCHING;
  i    := 0;
  if MaxCount = 0 then
    MaxCount := Count;

  repeat
    if i >= MaxCount then
      Mode := NOT_FOUND else
    if SameText(aWord, fItems[i].TheWord) then
      mode := SEARCH_FOUND
    else
      Inc(i);
  until mode <> SEARCHING;
  if mode = SEARCH_FOUND then
    result := i
  else
    result := -1;
end;

procedure TWordList.Insert(Index: Integer; const aWord: string;
  aScore: single);
var
  i: integer;
  OldCount: integer;
begin
  OldCount := Count;
  Count    := Count + 1;
  for i := OldCount -1 downto Index do
    fItems[i+1] := fItems[i];
  with fItems[Index] do
    begin
      TheWord := aWord;
      Score   := aScore;
    end;
end;

procedure TWordList.SetCount(const Value: integer);
begin
  fCount := Value;
end;

procedure TWordList.SetItem(Idx: integer; const Value: TWordItem);
begin
  fItems[Idx] := Value;
end;

procedure TWordList.SetMaxCount(const Value: integer);
begin
  SetLength(fItems, Value);
end;

procedure TWordList.SetSortedByScore(const Value: boolean);
var
  i, j: integer;
begin
  for i := 0 to pred(pred(Count)) do
    for j := i + 1 to pred(Count) do
      if fItems[i].Score < fItems[j].Score then
        Exchange(i, j);
  fSortedByScore := true;
end;

procedure Tfrm4LetterWordsMain.ReloadWords1Click(Sender: TObject);
begin
  LoadWordMatrix;
end;

procedure Tfrm4LetterWordsMain.leTargetChange(Sender: TObject);
begin
  WordExists(leTarget.Text);
end;

procedure Tfrm4LetterWordsMain.ListofWordswithnoSimilarWords1Click(
  Sender: TObject);
var
  ch1, ch2, ch3, ch4: char;
  ConnectedWords: TWordList;
  SrcWord, OutFileName: string;
  count, UnConnectedCount: integer;
begin
  OutFileName := UniqueFileName(gRootPath + 'UnConnectedWords.txt');
  if BrowseForFile('Output file', OutFileName, '.txt') then
    begin
      AssignFile(fOutFile, OutFileName);
      ReWrite(fOutFile);
      ConnectedWords := TWordList.Create;
      Count := 0; UnConnectedCount := 0;
      try
        // for each of the words in the list
        for ch1 := 'a' to 'z' do
          for ch2 := 'a' to 'z' do
            for ch3 := 'a' to 'z' do
              for ch4 := 'a' to 'z' do
                if fWordMatrix[ch1, ch2, ch3, ch4] then
                  begin
                    Inc(Count);
                    SrcWord := ch1 + ch2 + ch3 + ch4;
                    UpdateStatus(Format('Processing %d/%d "%s"', [Count, fNrRead, SrcWord]));
                    Application.ProcessMessages;
                    ConnectedWords.Clear;
                    if FindSimilarWords(SrcWord, SrcWord, ConnectedWords) < 0 then // see how many words are connected to it
                      begin
                        WriteLn(fOutFile, SrcWord); // if there aren't any, then add it to the list
                        inc(UnConnectedCount);
                      end;
                  end;
      finally
        UpdateStatus(Format('COMPLETE: %d unconnected words found', [UnConnectedCount]));
        FreeAndNil(ConnectedWords);
        CloseFile(fOutFile);
        FileExecute(Format('NotePad.exe %s', [OutFileName]), false);
      end;
    end;
end;

procedure Tfrm4LetterWordsMain.SaveAs1Click(Sender: TObject);
var
  FilePath: string;
  i: integer;
begin
  FilePath := UniqueFileName(gRootPath + 'FourLetterSteps.txt');
  if BrowseForFile('Save steps to file', FilePath, '.txt') then
    begin
      AssignFile(fOutFile, FilePath);
      ReWrite(fOutFile);
      try
        for i := 0 to fShortestPathList.Count-1 do
          WriteLn(fOutFile, i+1:3, '. ', fShortestPathList[i].TheWord);
      finally
        CloseFile(fOutFile);
        FileExecute(Format('NotePad.exe %s', [FilePath]), false);
      end;
    end;
end;

procedure Tfrm4LetterWordsMain.ListofWordsbySimilarity1Click(
  Sender: TObject);
var
  ch1, ch2, ch3, ch4: char;
  ConnectedWords: TWordList;
  SrcWord, OutFileName: string;
  count: integer;
  WordList: TWordList;
  i: integer;
begin
  OutFileName := UniqueFileName(gRootPath + 'MostConnectedWords.txt');
  if BrowseForFile('Output file', OutFileName, '.txt') then
    begin
      AssignFile(fOutFile, OutFileName);
      ReWrite(fOutFile);
      ConnectedWords := TWordList.Create;
      Count := 0; 
      WordList := TWordList.Create;
      WordList.MaxCount := fNrRead;
      try
        // for each of the words in the list
        for ch1 := 'a' to 'z' do
          for ch2 := 'a' to 'z' do
            for ch3 := 'a' to 'z' do
              for ch4 := 'a' to 'z' do
                if fWordMatrix[ch1, ch2, ch3, ch4] then
                  begin
                    Inc(Count);
                    SrcWord := ch1 + ch2 + ch3 + ch4;
                    UpdateStatus(Format('Processing %d/%d "%s"', [Count, fNrRead, SrcWord]));
                    Application.ProcessMessages;
                    ConnectedWords.Clear;
                    if FindSimilarWords(SrcWord, SrcWord, ConnectedWords) > 0 then // see how many words are connected to it
                      WordList.Add(SrcWord, ConnectedWords.Count);
                  end;
        WordList.SortedByScore := true;
        for i := 0 to WordList.Count-1 do
          WriteLn(fOutFile, WordList[i].TheWord:20, Trunc(WordList[i].Score):5);
      finally
        UpdateStatus(Format('COMPLETE: %d Connected words found', [WordList.Count]));
        FreeAndNil(ConnectedWords);
        CloseFile(fOutFile);
        FileExecute(Format('NotePad.exe %s', [OutFileName]), false);
      end;
    end;
end;

end.
