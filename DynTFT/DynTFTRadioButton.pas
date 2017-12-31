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

unit DynTFTRadioButton;

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
  CMaxRadioButtonStringLength = 19; //n * 4 - 1  

type
  TDynTFTRadioButton = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //RadioButton properties
    Checked: {$IFDEF IsDesktop} LongBool; {$ELSE} Boolean; {$ENDIF}
    ButtonIndex: LongInt;  //button number inside RadioGroup
    Caption: string[CMaxRadioButtonStringLength];
    Color: TColor;
    Font_Color: TColor;

    //these events are set by an owner component, e.g. a radio group, and called by a radio button
    OnOwnerInternalMouseDown: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseMove: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseUp: PDynTFTGenericEventHandler;
    OnOwnerInternalBeforeDestroy: PDynTFTGenericEventHandler;
  end;
  PDynTFTRadioButton = ^TDynTFTRadioButton;

procedure DynTFTDrawRadioButton(ARadioButton: PDynTFTRadioButton; FullRedraw: Boolean);
function DynTFTRadioButton_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTRadioButton;
procedure DynTFTRadioButton_Destroy(var ARadioButton: PDynTFTRadioButton);
procedure DynTFTRadioButton_DestroyAndPaint(var ARadioButton: PDynTFTRadioButton);
  
procedure DynTFTRegisterRadioButtonEvents;
function DynTFTGetRadioButtonComponentType: TDynTFTComponentType;

implementation

var
  ComponentType: TDynTFTComponentType;

function DynTFTGetRadioButtonComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


procedure DynTFTDrawRadioButton(ARadioButton: PDynTFTRadioButton; FullRedraw: Boolean);
var
  ACol: TColor;
  x1, y1, x2, y2: TSInt;
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(ARadioButton))) then
    Exit;

  x1 := ARadioButton^.BaseProps.Left;
  y1 := ARadioButton^.BaseProps.Top;
  x2 := x1 + ARadioButton^.BaseProps.Width;
  y2 := y1 + ARadioButton^.BaseProps.Height;

  ACol := ARadioButton^.Color;

  if FullRedraw then    
  begin
    DynTFT_Set_Pen(ACol, 1);
    DynTFT_Set_Brush(1, ACol, 0, 0, 0, 0);
    DynTFT_Rectangle(x1, y1, x2, y2);
  end;

  //Exterior circle
  DynTFT_Set_Pen(CL_DynTFTRadioButton_ExteriorCircle, 1);
  DynTFT_Set_Brush(0, ACol, 0, 0, 0, 0);
  DynTFT_Circle(x1 + 7, y1 + 8, 5);

  //Dot
  if ARadioButton^.Checked then
  begin
    DynTFT_Set_Pen(CL_DynTFTRadioButton_Dot, 1);
    DynTFT_Set_Brush(1, CL_DynTFTRadioButton_Dot, 0, 0, 0, 0);
  end
  else
  begin
    DynTFT_Set_Pen(ACol, 1);
    DynTFT_Set_Brush(1, ACol, 0, 0, 0, 0);
  end;

  DynTFT_Circle(x1 + 7, y1 + 8, 2);

  if Length(ARadioButton^.Caption) > 0 then
  begin
    if ARadioButton^.BaseProps.Enabled and CENABLED = CENABLED then
      ACol := ARadioButton^.Font_Color
    else  
      ACol := CL_DynTFTRadioButton_DisabledFont;
      
    DynTFT_Set_Font(@TFT_defaultFont, ACol, FO_HORIZONTAL);
    DynTFT_Write_Text(ARadioButton^.Caption, x1 + 14, y1);
  end;
end;


function DynTFTRadioButton_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTRadioButton;
begin
  Result := PDynTFTRadioButton(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTRadioButton was not registered. Please call RegisterRadioButtonEvents before creating a PDynTFTRadioButton. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := True;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  {$IFDEF IsDesktop}
    New(Result^.OnOwnerInternalMouseDown);
    New(Result^.OnOwnerInternalMouseMove);
    New(Result^.OnOwnerInternalMouseUp);
    New(Result^.OnOwnerInternalBeforeDestroy);

    Result^.OnOwnerInternalMouseDown^ := nil;
    Result^.OnOwnerInternalMouseMove^ := nil;
    Result^.OnOwnerInternalMouseUp^ := nil;
    Result^.OnOwnerInternalBeforeDestroy^ := nil;
  {$ELSE}
    Result^.OnOwnerInternalMouseDown := nil;
    Result^.OnOwnerInternalMouseMove := nil;
    Result^.OnOwnerInternalMouseUp := nil;
    Result^.OnOwnerInternalBeforeDestroy := nil;
  {$ENDIF}

  Result^.Checked := False;
  Result^.ButtonIndex := 0; //will be set accordingly by parent radio group
  Result^.Color := CL_DynTFTRadioButton_Background;
  Result^.Font_Color := CL_DynTFTRadioButton_EnabledFont;
  Result^.Caption := '';
end;


function DynTFTRadioButton_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTRadioButton_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTRadioButton_Destroy(var ARadioButton: PDynTFTRadioButton);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    if Assigned(ARadioButton^.OnOwnerInternalBeforeDestroy) then
      if Assigned(ARadioButton^.OnOwnerInternalBeforeDestroy^) then
  {$ELSE}
    if ARadioButton^.OnOwnerInternalBeforeDestroy <> nil then
  {$ENDIF}
      ARadioButton^.OnOwnerInternalBeforeDestroy^(PDynTFTBaseComponent(TPtrRec(ARadioButton)));  //tell the RadioGroup to do some cleanup (like defragmentation)

  {$IFDEF IsDesktop}
    Dispose(ARadioButton^.OnOwnerInternalMouseDown);
    Dispose(ARadioButton^.OnOwnerInternalMouseMove);
    Dispose(ARadioButton^.OnOwnerInternalMouseUp);
    Dispose(ARadioButton^.OnOwnerInternalBeforeDestroy);
  {$ENDIF}


  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(ARadioButton)), SizeOf(ARadioButton^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(ARadioButton));
    DynTFTComponent_Destroy(ATemp, SizeOf(ARadioButton^));
    ARadioButton := PDynTFTRadioButton(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTRadioButton_DestroyAndPaint(var ARadioButton: PDynTFTRadioButton);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(ARadioButton)));
  DynTFTRadioButton_Destroy(ARadioButton);
end;


procedure DynTFTRadioButton_BaseDestroyAndPaint(var ARadioButton: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTRadioButton;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTRadioButton_DestroyAndPaint(PDynTFTRadioButton(TPtrRec(ARadioButton)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTRadioButton(TPtrRec(ARadioButton));
    DynTFTRadioButton_DestroyAndPaint(ATemp);
    ARadioButton := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTRadioButton_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTRadioButton(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTRadioButton(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTRadioButton(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTRadioButton(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
end;


procedure TDynTFTRadioButton_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  (* implement these if RadioButton can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTRadioButton(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTRadioButton(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTRadioButton(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTRadioButton(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
  *)
end;


procedure TDynTFTRadioButton_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  (* implement these if RadioButton can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTRadioButton(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTRadioButton(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTRadioButton(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTRadioButton(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
  *)
end;


procedure TDynTFRadioButton_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  if Options = CREPAINTONMOUSEUP then
    Exit;

  if Options = CREPAINTONSTARTUP then
    Exit;  
    
  DynTFTDrawRadioButton(PDynTFTRadioButton(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterRadioButtonEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    ABaseEventReg.MouseDownEvent^ := TDynTFTRadioButton_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent^ := TDynTFTRadioButton_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent^ := TDynTFTRadioButton_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint^ := TDynTFRadioButton_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTRadioButton_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTRadioButton_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    ABaseEventReg.MouseDownEvent := @TDynTFTRadioButton_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent := @TDynTFTRadioButton_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent := @TDynTFTRadioButton_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint := @TDynTFRadioButton_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTRadioButton_Create;
      ABaseEventReg.CompDestroy := @DynTFTRadioButton_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTRadioButton); 
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
