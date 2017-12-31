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
   
unit DynTFTPanel;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTBaseDrawing, DynTFTConsts, DynTFTUtils
  {$IFDEF IsDesktop}
    ,SysUtils, Forms
  {$ENDIF}
  ;

const
  CMaxPanelStringLength = 19; //n * 4 - 1

type
  TDynTFTPanel = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //panel properties
    Caption: string[CMaxPanelStringLength];
    Color: TColor;
    Font_Color: TColor;

    //these events are set by an owner component, e.g. a scroll bar
    OnOwnerInternalMouseDown: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseMove: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseUp: PDynTFTGenericEventHandler;
  end;
  PDynTFTPanel = ^TDynTFTPanel;

procedure DynTFTDrawPanel(APanel: PDynTFTPanel; FullRedraw: Boolean);
function DynTFTPanel_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTPanel;
procedure DynTFTPanel_Destroy(var APanel: PDynTFTPanel);
procedure DynTFTPanel_DestroyAndPaint(var APanel: PDynTFTPanel);

procedure DynTFTRegisterPanelEvents;
function DynTFTGetPanelComponentType: TDynTFTComponentType;

implementation

var
  ComponentType: TDynTFTComponentType;

{$DEFINE CenterTextOnComponent}  //to draw centered text on a component

function DynTFTGetPanelComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


procedure DynTFTDrawPanel(APanel: PDynTFTPanel; FullRedraw: Boolean);
var
  BkCol: TColor;
  x1, y1, x2, y2: TSInt;
  {$IFDEF CenterTextOnComponent}
    TextXOffset: TSInt; //used to compute the X coord of text on button to make the text centered
    HalfWidth, HalfHeight: TSInt;
    TextWidth, TextHeight: Word;
  {$ENDIF}
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(APanel))) then
    Exit;

  x1 := APanel^.BaseProps.Left;
  y1 := APanel^.BaseProps.Top;
  x2 := x1 + APanel^.BaseProps.Width;
  y2 := y1 + APanel^.BaseProps.Height;

  BkCol := APanel^.Color;

  if FullRedraw then   
  begin
    DynTFT_Set_Pen(BkCol, 1);
    DynTFT_Set_Brush(1, BkCol, 0, 0, 0, 0);
    DynTFT_Rectangle(x1, y1, x2, y2);
  end;

  //border lines
  DynTFT_Set_Pen(CL_DynTFTPanel_LightEdge, 1);
  DynTFT_Line(x1, y1, x1, y2); //vert
  DynTFT_Line(x1, y1, x2, y1); //horiz

  DynTFT_Set_Pen(CL_DynTFTPanel_DarkEdge, 1);
  DynTFT_Line(x2, y1, x2, y2); //vert
  DynTFT_Line(x1, y2, x2, y2); //horiz

  //Draw focus rectangle from lines
  if APanel^.BaseProps.Focused and CFOCUSED = CFOCUSED then
    BkCol := CL_DynTFTPanel_FocusRectangle
  else
    BkCol := APanel^.Color;
    
  DynTFT_Set_Pen(BkCol, 1);
  DynTFT_Line(x1 + 4, y1 + 3, x1 + 4, y2 - 3); //vert
  DynTFT_Line(x1 + 4, y1 + 3, x2 - 4, y1 + 3); //horiz
  DynTFT_Line(x2 - 4, y1 + 3, x2 - 4, y2 - 3); //vert
  DynTFT_Line(x1 + 4, y2 - 3, x2 - 4, y2 - 3); //horiz

  if Length(APanel^.Caption) > 0 then
  begin
    //Caption
    if APanel^.BaseProps.Enabled = 0 then
      DynTFT_Set_Font(@TFT_defaultFont, CL_DynTFTPanel_DisabledFont, FO_HORIZONTAL)
    else
      DynTFT_Set_Font(@TFT_defaultFont, APanel^.Font_Color, FO_HORIZONTAL);

    {$IFDEF CenterTextOnComponent}
      HalfWidth := APanel^.BaseProps.Width shr 1;
      HalfHeight := APanel^.BaseProps.Height shr 1;
      
      GetTextWidthAndHeight(APanel^.Caption, TextWidth, TextHeight);
      TextXOffset := HalfWidth - TSInt(TextWidth shr 1);
      DynTFT_Write_Text(APanel^.Caption, x1 + TextXOffset, y1 + HalfHeight - TSInt(TextHeight shr 1));
    {$ELSE}
      DynTFT_Write_Text(APanel^.Caption, x1 + 4, y1 + HalfHeight - 6);
    {$ENDIF}
  end;
end;


function DynTFTPanel_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTPanel;
begin
  Result := PDynTFTPanel(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTPanel was not registered. Please call RegisterPanelEvents before creating a PDynTFTPanel. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := True;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  Result^.Color := CL_DynTFTPanel_Background;
  Result^.Font_Color := CL_DynTFTPanel_EnabledFont;
  Result^.Caption := '';

  {$IFDEF IsDesktop}
    New(Result^.OnOwnerInternalMouseDown);
    New(Result^.OnOwnerInternalMouseMove);
    New(Result^.OnOwnerInternalMouseUp);

    Result^.OnOwnerInternalMouseDown^ := nil;
    Result^.OnOwnerInternalMouseMove^ := nil;
    Result^.OnOwnerInternalMouseUp^ := nil;
  {$ELSE}
    Result^.OnOwnerInternalMouseDown := nil;
    Result^.OnOwnerInternalMouseMove := nil;
    Result^.OnOwnerInternalMouseUp := nil;
  {$ENDIF}
end;


function DynTFTPanel_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTPanel_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTPanel_Destroy(var APanel: PDynTFTPanel);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    Dispose(APanel^.OnOwnerInternalMouseDown);
    Dispose(APanel^.OnOwnerInternalMouseMove);
    Dispose(APanel^.OnOwnerInternalMouseUp);
  {$ENDIF}

  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(APanel)), SizeOf(APanel^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(APanel));
    DynTFTComponent_Destroy(ATemp, SizeOf(APanel^));
    APanel := PDynTFTPanel(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTPanel_DestroyAndPaint(var APanel: PDynTFTPanel);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(APanel)));
  DynTFTPanel_Destroy(APanel);
end;


procedure DynTFTPanel_BaseDestroyAndPaint(var APanel: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTPanel;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTPanel_DestroyAndPaint(PDynTFTPanel(TPtrRec(APanel)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTPanel(TPtrRec(APanel));
    DynTFTPanel_DestroyAndPaint(ATemp);
    APanel := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTPanel_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTPanel(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTPanel(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTPanel(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTPanel(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
end;


procedure TDynTFTPanel_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTPanel(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTPanel(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTPanel(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTPanel(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
end;


procedure TDynTFTPanel_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  DynTFTDrawPanel(PDynTFTPanel(TPtrRec(ABase)), False);

  {$IFDEF IsDesktop}
    if Assigned(PDynTFTPanel(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTPanel(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTPanel(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTPanel(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
end;


procedure TDynTFTPanel_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  DynTFTDrawPanel(PDynTFTPanel(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterPanelEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    ABaseEventReg.MouseDownEvent^ := TDynTFTPanel_OnDynTFTBaseInternalMouseDown;
    ABaseEventReg.MouseMoveEvent^ := TDynTFTPanel_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent^ := TDynTFTPanel_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint^ := TDynTFTPanel_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTPanel_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTPanel_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    ABaseEventReg.MouseDownEvent := @TDynTFTPanel_OnDynTFTBaseInternalMouseDown;
    ABaseEventReg.MouseMoveEvent := @TDynTFTPanel_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent := @TDynTFTPanel_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint := @TDynTFTPanel_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTPanel_Create;
      ABaseEventReg.CompDestroy := @DynTFTPanel_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTPanel); 
  {$ENDIF}

  ComponentType := DynTFTRegisterComponentType(@ABaseEventReg);

  {$IFDEF IsDesktop}
    DynTFTDisposeInternalHandlers(ABaseEventReg);
  {$ENDIF}  
end;

{$IFDEF IsDesktop}
begin
  ComponentType := -1;
{$ENDIF}

end.
