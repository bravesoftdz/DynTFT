program DynTFTSim;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
{$IFnDEF FPC}
{$ELSE}
  Interfaces,
{$ENDIF}
  Forms,
  DynTFTSimMainForm in 'DynTFTSimMainForm.pas' {frmDynTFTSimMain},
  DynTFTSimScreenForm in 'DynTFTSimScreenForm.pas' {frmDynTFTSimScreen};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmDynTFTSimMain, frmDynTFTSimMain);
  Application.CreateForm(TfrmDynTFTSimScreen, frmDynTFTSimScreen);
  Application.Run;
end.
