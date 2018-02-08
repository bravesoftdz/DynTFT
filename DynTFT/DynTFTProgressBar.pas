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

unit DynTFTProgressBar;

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
  CProgressBarHorizDir = 0;
  CProgressBarVertDir = 1;

type
  TDynTFTProgressBar = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //ProgressBar properties
    Color: TColor;
    BackgroundColor: TColor;
    Min, Max, Position, OldPosition: LongInt;
    Orientation: Byte; //0 = horizontal, 1 = vertical       

    //these events are set by an owner component
    //OnOwnerInternalMouseDown: PDynTFTGenericEventHandler;
    //OnOwnerInternalMouseMove: PDynTFTGenericEventHandler;
    //OnOwnerInternalMouseUp: PDynTFTGenericEventHandler;
  end;
  PDynTFTProgressBar = ^TDynTFTProgressBar;

procedure DynTFTDrawProgressBar(AProgressBar: PDynTFTProgressBar; FullRedraw: Boolean);
function DynTFTProgressBar_CreateWithDir(ScreenIndex: Byte; Left, Top, Width, Height: TSInt; PrbDir: Byte): PDynTFTProgressBar;
function DynTFTProgressBar_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTProgressBar;
procedure DynTFTProgressBar_Destroy(var AProgressBar: PDynTFTProgressBar);
procedure DynTFTProgressBar_DestroyAndPaint(var AProgressBar: PDynTFTProgressBar);

procedure DynTFTRegisterProgressBarEvents;
function DynTFTGetProgressBarComponentType: TDynTFTComponentType;

implementation

var
  ComponentType: TDynTFTComponentType;

function DynTFTGetProgressBarComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


function PrbBarPosToDrawPos(PrbBar: PDynTFTProgressBar): Word;
var
  TotalDrawSpace: TSInt;
  TotalPositionSpace: LongInt;
begin
  if PrbBar^.Orientation = CProgressBarHorizDir then
    TotalDrawSpace := PrbBar^.BaseProps.Width
  else
    TotalDrawSpace := PrbBar^.BaseProps.Height;

  TotalDrawSpace := TotalDrawSpace - 4;
  TotalPositionSpace := PrbBar^.Max - PrbBar^.Min;

  {$IFDEF IsDesktop}
    Result := Round(LongInt(TotalDrawSpace) * PrbBar^.Position / TotalPositionSpace);
  {$ELSE}
    Result := Word(Real(Real(LongInt(TotalDrawSpace)) * Real(PrbBar^.Position) / Real(TotalPositionSpace)));
  {$ENDIF}

  Result := Result + 3;  
end;


procedure DynTFTDrawProgressBar(AProgressBar: PDynTFTProgressBar; FullRedraw: Boolean);
var
  x1, y1, x2, y2, pxy: TSInt;
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(AProgressBar))) then
    Exit;
    
  x1 := AProgressBar^.BaseProps.Left;
  y1 := AProgressBar^.BaseProps.Top;
  x2 := x1 + AProgressBar^.BaseProps.Width;
  y2 := y1 + AProgressBar^.BaseProps.Height;

  if AProgressBar^.Position < AProgressBar^.Min then
    AProgressBar^.Position := AProgressBar^.Min;

  if AProgressBar^.Position > AProgressBar^.Max then
    AProgressBar^.Position := AProgressBar^.Max;

  if AProgressBar^.Orientation = CProgressBarHorizDir then
    pxy := x1 + PrbBarPosToDrawPos(AProgressBar)
  else
    pxy := y2 - PrbBarPosToDrawPos(AProgressBar);

  if FullRedraw then
  begin
    DynTFT_Set_Pen(AProgressBar^.BackgroundColor, 1);
    DynTFT_Set_Brush(1, AProgressBar^.BackgroundColor, 0, 0, 0, 0);
    DynTFT_Rectangle(x1, y1, x2, y2);

    //border lines
    DynTFT_Set_Pen(CL_DynTFTProgressBar_DarkEdge, 1);
    DynTFT_V_Line(y1, y2, x1); //vert
    DynTFT_H_Line(x1, x2, y1); //horiz

    DynTFT_Set_Pen(CL_DynTFTProgressBar_LightEdge, 1);
    DynTFT_V_Line(y1, y2, x2); //vert
    DynTFT_H_Line(x1, x2, y2); //horiz
  end
  else
  begin
    DynTFT_Set_Pen(AProgressBar^.BackgroundColor, 1);
    DynTFT_Set_Brush(1, AProgressBar^.BackgroundColor, 0, 0, 0, 0);

    if AProgressBar^.Orientation = CProgressBarHorizDir then
      DynTFT_Rectangle(pxy - 1, y1, x2 - 1, y2)
    else
      DynTFT_Rectangle(x1, y1 + 1, x2, pxy - 1);
  end;

  DynTFT_Set_Pen(AProgressBar^.Color, 1);
  DynTFT_Set_Brush(1, AProgressBar^.Color, 0, 0, 0, 0);

  if AProgressBar^.Orientation = CProgressBarHorizDir then
    DynTFT_Rectangle(x1 + 2, y1 + 2, pxy - 2, y2 - 2)
  else
    DynTFT_Rectangle(x1 + 2, pxy + 2, x2 - 2, y2 - 2);
end;


function DynTFTProgressBar_CreateWithDir(ScreenIndex: Byte; Left, Top, Width, Height: TSInt; PrbDir: Byte): PDynTFTProgressBar;
begin
  Result := PDynTFTProgressBar(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTProgressBar was not registered. Please call RegisterProgressBarEvents before creating a PDynTFTProgressBar. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := False;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  Result^.Color := CL_DynTFTProgressBar_Progress;
  Result^.BackgroundColor := CL_DynTFTProgressBar_Background;
  Result^.Orientation := PrbDir;

  Result^.Min := 0;
  Result^.Max := 10;
  Result^.Position := 0;

  (*
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
  *)
end;


function DynTFTProgressBar_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTProgressBar;
begin
  Result := DynTFTProgressBar_CreateWithDir(ScreenIndex, Left, Top, Width, Height, CProgressBarHorizDir);
end;


function DynTFTProgressBar_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTProgressBar_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTProgressBar_Destroy(var AProgressBar: PDynTFTProgressBar);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AProgressBar)), SizeOf(AProgressBar^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(AProgressBar));
    DynTFTComponent_Destroy(ATemp, SizeOf(AProgressBar^));
    AProgressBar := PDynTFTProgressBar(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTProgressBar_DestroyAndPaint(var AProgressBar: PDynTFTProgressBar);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(AProgressBar)));
  DynTFTProgressBar_Destroy(AProgressBar);
end;


procedure DynTFTProgressBar_BaseDestroyAndPaint(var AProgressBar: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTProgressBar;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTProgressBar_DestroyAndPaint(PDynTFTProgressBar(TPtrRec(AProgressBar)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTProgressBar(TPtrRec(AProgressBar));
    DynTFTProgressBar_DestroyAndPaint(ATemp);
    AProgressBar := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTProgressBar_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  (* implement these if ProgressBar can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTProgressBar(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTProgressBar(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTProgressBar(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTProgressBar(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
  *)   
end;


procedure TDynTFTProgressBar_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  (* implement these if ProgressBar can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTProgressBar(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTProgressBar(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTProgressBar(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTProgressBar(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
  *)
end;


procedure TDynTFTProgressBar_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  (* implement these if ProgressBar can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTProgressBar(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTProgressBar(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTProgressBar(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTProgressBar(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
  *)
end;


procedure TDynTFTProgressBar_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  if Options = CREPAINTONMOUSEUP then
    Exit;
    
  DynTFTDrawProgressBar(PDynTFTProgressBar(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterProgressBarEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    //ABaseEventReg.MouseDownEvent^ := TDynTFTProgressBar_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent^ := TDynTFTProgressBar_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent^ := TDynTFTProgressBar_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint^ := TDynTFTProgressBar_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTProgressBar_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTProgressBar_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    //ABaseEventReg.MouseDownEvent := @TDynTFTProgressBar_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent := @TDynTFTProgressBar_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent := @TDynTFTProgressBar_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint := @TDynTFTProgressBar_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTProgressBar_Create;
      ABaseEventReg.CompDestroy := @DynTFTProgressBar_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTProgressBar); 
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
