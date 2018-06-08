{   DynTFT  - graphic components for microcontrollers
    Copyright (C) 2017 VCC
    release date: 29 Dec 2017
    author: VCC

    This file is part of DynTFT project.

    DynTFT is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, version 3 of the License.

    DynTFT is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with DynTFT, in COPYING.LESSER file.
    If not, see <http://www.gnu.org/licenses/>.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
    OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

unit DynTFTMessageBox;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTBaseDrawing, DynTFTConsts, DynTFTUtils,
  DynTFTButton, DynTFTLabel

  {$IFDEF IsDesktop}
    ,SysUtils, Forms, Math, TFT
  {$ENDIF}
  ;

const
  CMessageBoxMaxTitleLength = 19; //n * 4 - 1
  CMessageBoxMaxTextLength = 159;

  //constants from Windows unit (Delphi)
  CDynTFT_MB_OK = $0000;
  CDynTFT_MB_OKCANCEL = $0001;
  //CDynTFT_MB_ABORTRETRYIGNORE = $0002;
  //CDynTFT_MB_YESNOCANCEL = $0003;
  CDynTFT_MB_YESNO = $0004;
  //CDynTFT_MB_RETRYCANCEL = $0005;

  CDynTFT_IDOK = 1;
  CDynTFT_IDCANCEL = 2;
  CDynTFT_IDYES = 6;
  CDynTFT_IDNO = 7;

type
  TDynTFTMessageBox = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //MessageBox properties
    Title: string[CMessageBoxMaxTitleLength];
    Text: string[CMessageBoxMaxTextLength];

    BtnOK, BtnCancel: PDynTFTButton;   //Yes, No
    ExteriorLabel: PDynTFTLabel;
    Done: Boolean;
    ButtonsType: Integer;
    CloseResult: Integer;
  end;
  PDynTFTMessageBox = ^TDynTFTMessageBox;

  TDynTFTMessageBoxMainLoopHandler = procedure(AMessageBox: PDynTFTMessageBox);
  PDynTFTMessageBoxMainLoopHandler = ^TDynTFTMessageBoxMainLoopHandler;

procedure DynTFTDrawMessageBox(AMessageBox: PDynTFTMessageBox; FullRedraw: Boolean);
function DynTFTMessageBox_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTMessageBox;
procedure DynTFTMessageBox_Destroy(var AMessageBox: PDynTFTMessageBox);
procedure DynTFTMessageBox_DestroyAndPaint(var AMessageBox: PDynTFTMessageBox);

function DynTFTShowMessageBox(ScreenIndex: Byte; var MBMsg, MBTitle: string; ButtonsType: Integer): Integer;

procedure DynTFTRegisterMessageBoxEvents;
function DynTFTGetMessageBoxComponentType: TDynTFTComponentType;


var
  DynTFTMessageBoxMainLoopHandler: PDynTFTMessageBoxMainLoopHandler;  //this must be set to a procedure, which calls DynTFT_GUI_LoopIteration in a loop, with a stop condition defined by TDynTFTMessageBox. 

implementation

var
  ComponentType: TDynTFTComponentType;


function DynTFTGetMessageBoxComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


procedure DynTFTDrawMessageBox(AMessageBox: PDynTFTMessageBox; FullRedraw: Boolean);
var
  Col1, Col2, BkCol: TColor;
  x1, y1, x2, y2: TSInt;
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(AMessageBox))) then
    Exit;

  x1 := AMessageBox^.BaseProps.Left;
  y1 := AMessageBox^.BaseProps.Top;
  x2 := x1 + AMessageBox^.BaseProps.Width;
  y2 := y1 + AMessageBox^.BaseProps.Height;

  BkCol := CL_DynTFTMessageBox_Background;

  if FullRedraw then
  begin
    DynTFT_Set_Pen(BkCol, 1);
    DynTFT_Set_Brush(1, BkCol, 0, 0, 0, 0);
    DynTFT_Rectangle(x1, y1, x2, y2);

    Col1 := CL_DynTFTMessageBox_LightEdge;
    Col2 := CL_DynTFTMessageBox_DarkEdge;

    //border lines
    DynTFT_Set_Pen(Col1, 1);
    DynTFT_V_Line(y1, y2, x1); //vert
    DynTFT_H_Line(x1, x2, y1); //horiz

    DynTFT_Set_Pen(Col2, 1);
    DynTFT_V_Line(y1, y2, x2); //vert
    DynTFT_H_Line(x1, x2, y2); //horiz

    DynTFT_Set_Pen(CL_DynTFTMessageBox_TitleBar, 1);
    DynTFT_Set_Brush(1, CL_DynTFTMessageBox_TitleBar, 0, 0, 0, 0);
    DynTFT_Rectangle(x1 + 2, y1 + 2, x2 - 2, y1 + 20);
  end;

  DynTFTDrawButton(AMessageBox^.BtnOK, FullRedraw);
  DynTFTDrawButton(AMessageBox^.BtnCancel, FullRedraw);

  //draw text
  DynTFT_Set_Font(@TFT_defaultFont, CL_DynTFTMessageBox_MessageFont, FO_HORIZONTAL);
  DynTFT_Write_Text(AMessageBox^.Text, x1 + 10, y1 + 30);

  //draw title
  DynTFT_Set_Font(@TFT_defaultFont, CL_DynTFTMessageBox_TitleFont, FO_HORIZONTAL);
  DynTFT_Write_Text(AMessageBox^.Title, x1 + 10, y1 + 2);
end;


procedure ShowMessageBoxAndBringToFront(AMessageBox: PDynTFTMessageBox);
begin
  DynTFTShowComponentWithDelay(PDynTFTBaseComponent(TPtrRec(AMessageBox)));
  DynTFTComponent_BringMultipleComponentsToFront(PDynTFTBaseComponent(TPtrRec(AMessageBox)), PDynTFTBaseComponent(TPtrRec(AMessageBox^.ExteriorLabel)));
end;


function OKButtonResponse(AMessageBox: PDynTFTMessageBox): Integer;
begin
  case AMessageBox^.ButtonsType of
    CDynTFT_MB_OKCANCEL: Result := CDynTFT_IDOK;
    CDynTFT_MB_YESNO: Result := CDynTFT_IDYES
  else
    Result := CDynTFT_IDOK;
  end;
end;


function CancelButtonResponse(AMessageBox: PDynTFTMessageBox): Integer;
begin
  case AMessageBox^.ButtonsType of
    CDynTFT_MB_OKCANCEL: Result := CDynTFT_IDCANCEL;
    CDynTFT_MB_YESNO: Result := CDynTFT_IDNO
  else
    Result := CDynTFT_IDOK;
  end;
end;


procedure TDynTFTMessageBox_OnDynTFTChildOKButtonInternalMouseUp(ABase: PPtrRec);
var
  AMessageBox: PDynTFTMessageBox;
begin
  if PDynTFTBaseComponent(TPtrRec(PDynTFTBaseComponent(TPtrRec(ABase))^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    AMessageBox := PDynTFTMessageBox(TPtrRec(PDynTFTBaseComponent(TPtrRec(ABase))^.BaseProps.Parent));
    AMessageBox^.Done := True;
    AMessageBox^.CloseResult := OKButtonResponse(AMessageBox);

    AMessageBox^.BtnOK^.BaseProps.Visible := CHIDDEN;
    AMessageBox^.BtnCancel^.BaseProps.Visible := CHIDDEN;

    DynTFTComponent_BringMultipleComponentsToFront(PDynTFTBaseComponent(TPtrRec(AMessageBox^.ExteriorLabel)), nil);
    DynTFTComponent_BringMultipleComponentsToFront(PDynTFTBaseComponent(TPtrRec(AMessageBox^.BtnCancel)), nil);
    DynTFTMessageBox_DestroyAndPaint(AMessageBox);
  end; //if is MessageBox
end;


procedure TDynTFTMessageBox_OnDynTFTChildCancelButtonInternalMouseUp(ABase: PPtrRec);
var
  AMessageBox: PDynTFTMessageBox;
begin
  if PDynTFTBaseComponent(TPtrRec(PDynTFTBaseComponent(TPtrRec(ABase))^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    AMessageBox := PDynTFTMessageBox(TPtrRec(PDynTFTBaseComponent(TPtrRec(ABase))^.BaseProps.Parent));
    AMessageBox^.Done := True;
    AMessageBox^.CloseResult := CancelButtonResponse(AMessageBox);

    AMessageBox^.BtnOK^.BaseProps.Visible := CHIDDEN;
    AMessageBox^.BtnCancel^.BaseProps.Visible := CHIDDEN;

    DynTFTComponent_BringMultipleComponentsToFront(PDynTFTBaseComponent(TPtrRec(AMessageBox^.ExteriorLabel)), nil);
    DynTFTComponent_BringMultipleComponentsToFront(PDynTFTBaseComponent(TPtrRec(AMessageBox^.BtnOK)), nil);
    DynTFTMessageBox_DestroyAndPaint(AMessageBox);
  end; //if is MessageBox
end;


procedure TDynTFTMessageBox_OnDynTFTChildExtLabelInternalMouseDown(ABase: PPtrRec);
var
  AMessageBox: PDynTFTMessageBox;
begin
  if PDynTFTBaseComponent(TPtrRec(PDynTFTBaseComponent(TPtrRec(ABase))^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    AMessageBox := PDynTFTMessageBox(TPtrRec(PDynTFTBaseComponent(TPtrRec(ABase))^.BaseProps.Parent));
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AMessageBox)));
  end; //if is MessageBox
end;


function DynTFTMessageBox_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTMessageBox;
begin
  Result := PDynTFTMessageBox(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTMessageBox was not registered. Please call RegisterMessageBoxEvents before creating a PDynTFTMessageBox. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := False;   //Allow events to be processed by subcomponents.
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));


  Result^.BtnOK := DynTFTButton_Create(ScreenIndex, Left + Width - 120, Top + 70, 50, 20);
  Result^.BtnCancel := DynTFTButton_Create(ScreenIndex, Left + Width - 60, Top + 70, 50, 20);
  Result^.ExteriorLabel := DynTFTLabel_Create(ScreenIndex, 0, 0, 32767, 32767);     //bigger than any screen

  Result^.BtnOK^.BaseProps.Parent := PPtrRec(TPtrRec(Result));
  Result^.BtnCancel^.BaseProps.Parent := PPtrRec(TPtrRec(Result));
  Result^.ExteriorLabel^.BaseProps.Parent := PPtrRec(TPtrRec(Result));

  {$IFDEF IsDesktop}
    Result^.BtnOK^.BaseProps.OnMouseUpUser^ := TDynTFTMessageBox_OnDynTFTChildOKButtonInternalMouseUp;
    Result^.BtnCancel^.BaseProps.OnMouseUpUser^ := TDynTFTMessageBox_OnDynTFTChildCancelButtonInternalMouseUp;
    Result^.ExteriorLabel^.BaseProps.OnMouseDownUser^ := TDynTFTMessageBox_OnDynTFTChildExtLabelInternalMouseDown;
  {$ELSE}
    Result^.BtnOK^.BaseProps.OnMouseUpUser := @TDynTFTMessageBox_OnDynTFTChildOKButtonInternalMouseUp;
    Result^.BtnCancel^.BaseProps.OnMouseUpUser := @TDynTFTMessageBox_OnDynTFTChildCancelButtonInternalMouseUp;
    Result^.ExteriorLabel^.BaseProps.OnMouseDownUser := @TDynTFTMessageBox_OnDynTFTChildExtLabelInternalMouseDown;
  {$ENDIF}

  Result^.Done := False;

  Result^.BtnOK^.BaseProps.Visible := CVISIBLE;
  Result^.BtnCancel^.BaseProps.Visible := CVISIBLE;
  Result^.ExteriorLabel^.BaseProps.Visible := CVISIBLE; //CHIDDEN;
  Result^.ExteriorLabel^.Color := -1;

  Result^.BtnOK^.Caption := 'OK';
  Result^.BtnCancel^.Caption := 'Cancel';
  Result^.ButtonsType := CDynTFT_MB_OKCANCEL;
end;


function DynTFTMessageBox_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTMessageBox_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTMessageBox_Destroy(var AMessageBox: PDynTFTMessageBox);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AMessageBox^.BtnOK)), SizeOf(AMessageBox^.BtnOK^));
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AMessageBox^.BtnCancel)), SizeOf(AMessageBox^.BtnCancel^));
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AMessageBox^.ExteriorLabel)), SizeOf(AMessageBox^.ExteriorLabel^));

    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AMessageBox)), SizeOf(AMessageBox^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(AMessageBox^.BtnOK));
    DynTFTComponent_Destroy(ATemp, SizeOf(AMessageBox^.BtnOK^));
    AMessageBox^.BtnOK := PDynTFTButton(TPtrRec(ATemp));

    ATemp := PDynTFTBaseComponent(TPtrRec(AMessageBox^.BtnCancel));
    DynTFTComponent_Destroy(ATemp, SizeOf(AMessageBox^.BtnCancel^));
    AMessageBox^.BtnCancel := PDynTFTButton(TPtrRec(ATemp));

    ATemp := PDynTFTBaseComponent(TPtrRec(AMessageBox^.ExteriorLabel));
    DynTFTComponent_Destroy(ATemp, SizeOf(AMessageBox^.ExteriorLabel^));
    AMessageBox^.ExteriorLabel := PDynTFTLabel(TPtrRec(ATemp));

    ATemp := PDynTFTBaseComponent(TPtrRec(AMessageBox));
    DynTFTComponent_Destroy(ATemp, SizeOf(AMessageBox^));
    AMessageBox := PDynTFTMessageBox(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTMessageBox_DestroyAndPaint(var AMessageBox: PDynTFTMessageBox);
begin
  DynTFTRepaintScreenComponentsFromArea(PDynTFTBaseComponent(TPtrRec(AMessageBox)));
  DynTFTMessageBox_Destroy(AMessageBox);
end;


procedure DynTFTMessageBox_BaseDestroyAndPaint(var AMessageBox: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTMessageBox;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTMessageBox_DestroyAndPaint(PDynTFTMessageBox(TPtrRec(AMessageBox)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTMessageBox(TPtrRec(AMessageBox));
    DynTFTMessageBox_DestroyAndPaint(ATemp);
    AMessageBox := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


function DynTFTShowMessageBox(ScreenIndex: Byte; var MBMsg, MBTitle: string; ButtonsType: Integer): Integer;
var
  AMessageBox: PDynTFTMessageBox;
  TextWidth, TextHeight: Word;
  Left, Top: Integer;
begin
  GetTextWidthAndHeight(MBMsg, TextWidth, TextHeight);
  TextWidth := Max(170, TextWidth + 20);

  if TextWidth > TFT_DISP_WIDTH then
    Left := 0
  else
    Left := (Integer(TFT_DISP_WIDTH) - Integer(TextWidth)) shr 1;

  Top := (TFT_DISP_HEIGHT - 100) shr 1;  // 100 is the initial height

  AMessageBox := DynTFTMessageBox_Create(ScreenIndex, Left, Top, TextWidth, 100);

  if Length(MBTitle) > CMessageBoxMaxTitleLength then
  begin
    {$IFDEF IsDesktop}
      AMessageBox^.Title := Copy(MBTitle, 1, CMessageBoxMaxTitleLength);
    {$ELSE}
      DynTFTCopyStr(MBTitle, 1, CMessageBoxMaxTitleLength, AMessageBox^.Title);
    {$ENDIF}
  end
  else
    AMessageBox^.Title := MBTitle;

  if Length(MBMsg) > CMessageBoxMaxTextLength then
  begin
    {$IFDEF IsDesktop}
      AMessageBox^.Text := Copy(MBMsg, 1, CMessageBoxMaxTextLength);
    {$ELSE}
      DynTFTCopyStr(MBMsg, 1, CMessageBoxMaxTextLength, AMessageBox^.Text);
    {$ENDIF}
  end
  else
    AMessageBox^.Text := MBMsg;

  AMessageBox^.ButtonsType := ButtonsType;

  case ButtonsType of
    CDynTFT_MB_OK :
    begin
      AMessageBox^.BtnOK^.BaseProps.Left := AMessageBox^.BtnCancel^.BaseProps.Left;
      AMessageBox^.BtnCancel^.BaseProps.Visible := CHIDDEN;
    end;
    
    CDynTFT_MB_YESNO :
    begin
      AMessageBox^.BtnOK^.Caption := 'Yes';
      AMessageBox^.BtnCancel^.Caption := 'No';
    end;
  end;

  ShowMessageBoxAndBringToFront(AMessageBox);

  AMessageBox^.CloseResult := 0;

  {$IFDEF IsDesktop}
    if Assigned(DynTFTMessageBoxMainLoopHandler) then
      if Assigned(DynTFTMessageBoxMainLoopHandler^) then
  {$ELSE}
    if DynTFTMessageBoxMainLoopHandler <> nil then
  {$ENDIF}
      DynTFTMessageBoxMainLoopHandler^(AMessageBox);
                                             
  Result := AMessageBox^.CloseResult;    
end;


procedure TDynTFTMessageBox_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  (*  implement these if MessageBox can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTMessageBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTMessageBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTMessageBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTMessageBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
  *)
end;


procedure TDynTFTMessageBox_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  (*  implement these if MessageBox can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTMessageBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTMessageBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTMessageBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTMessageBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
  *)
end;


procedure TDynTFTMessageBox_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  (*  implement these if MessageBox can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTMessageBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTMessageBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTMessageBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTMessageBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
  *)
end;


procedure TDynTFTMessageBox_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
{var
  AMessageBox: PDynTFTMessageBox;}
begin
  if Options = CREPAINTONMOUSEUP then
  begin
    {AMessageBox := PDynTFTMessageBox(TPtrRec(ABase));
    SetEditReadonlyState(AMessageBox);

    AMessageBox^.DroppedDown := False;

    HideComponent(PDynTFTBaseComponent(TPtrRec(AMessageBox^.ListBox)));
    RepaintScreenComponentsFromArea(PDynTFTBaseComponent(TPtrRec(AMessageBox^.ListBox)));
    AMessageBox^.ExteriorLabel^.BaseProps.Visible := AMessageBox^.ListBox^.BaseProps.Visible;
               }
    Exit;
  end;

  if Options = CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT then
  begin
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTMessageBox(TPtrRec(ABase))^.BtnOK)));
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTMessageBox(TPtrRec(ABase))^.BtnCancel)));
    Exit;
  end;
  {
  if Options = CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT then
  begin
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTMessageBox(TPtrRec(ABase))^.BtnOK)));
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTMessageBox(TPtrRec(ABase))^.BtnCancel)));
    Exit;
  end;  
  }
  DynTFTDrawMessageBox(PDynTFTMessageBox(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterMessageBoxEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    //ABaseEventReg.MouseDownEvent^ := TDynTFTMessageBox_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent^ := TDynTFTMessageBox_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent^ := TDynTFTMessageBox_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint^ := TDynTFTMessageBox_OnDynTFTBaseInternalRepaint;

    if DynTFTMessageBoxMainLoopHandler <> nil then
      DynTFTMessageBoxMainLoopHandler^ := nil;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTMessageBox_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTMessageBox_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    //ABaseEventReg.MouseDownEvent := @TDynTFTMessageBox_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent := @TDynTFTMessageBox_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent := @TDynTFTMessageBox_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint := @TDynTFTMessageBox_OnDynTFTBaseInternalRepaint;
    DynTFTMessageBoxMainLoopHandler := nil;
    
    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTMessageBox_Create;
      ABaseEventReg.CompDestroy := @DynTFTMessageBox_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTMessageBox); 
  {$ENDIF}

  ComponentType := DynTFTRegisterComponentType(@ABaseEventReg);

  {$IFDEF IsDesktop}
    DynTFTDisposeInternalHandlers(ABaseEventReg);
  {$ENDIF}
end;


{$IFDEF IsDesktop}
begin
  ComponentType := -1;
  DynTFTMessageBoxMainLoopHandler := nil;
{$ENDIF}

end.
