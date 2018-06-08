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
   
unit DynTFTItems;

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
  CMaxItemItemCount = 16;
  {$IFDEF UseExternalItemsStringLength}
    {$I ExternalItemsStringLength.inc}
  {$ELSE}
    CMaxItemsStringLength = 19; //n * 4 - 1
  {$ENDIF}
  //CItemHeight = 15; //13 pixels for text and 2 pixels for box

type
  TItemsString = string[CMaxItemsStringLength];

  TOnGetItemEvent = procedure(AComp: PPtrRec; Index: LongInt; var ItemText: string);
  POnGetItemEvent = ^TOnGetItemEvent;

  TDynTFTItems = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    FirstVisibleIndex, Count, ItemIndex: LongInt;

    //Items properties
    FontColor, BackgroundColor: TColor;

    ItemHeight: Word; //no TSInt allowed :(
    {$IFNDEF AppArch16}
      Dummy: Word; //keep alignment to 4 bytes   (<ArrowDir> + <DummyByte> + <Dummy>)
    {$ENDIF}

    //these events are set by an owner component, e.g. a list box, and called by Items
    OnOwnerInternalMouseDown: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseMove: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseUp: PDynTFTGenericEventHandler;

    {$IFDEF UseExternalItems}
      OnGetItem: POnGetItemEvent;
    {$ELSE}
      Strings: array[0..CMaxItemItemCount - 1] of string[CMaxItemsStringLength];
    {$ENDIF}  
  end;
  PDynTFTItems = ^TDynTFTItems;  

procedure DynTFTDrawItems(AItems: PDynTFTItems; FullRedraw: Boolean);
function DynTFTItems_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTItems;
procedure DynTFTItems_Destroy(var AItems: PDynTFTItems);
procedure DynTFTItems_DestroyAndPaint(var AItems: PDynTFTItems);

function DynTFTGetNumberOfItemsToDraw(AItems: PDynTFTItems): Word;
procedure DynTFTItemsGetItemText(AItems: PDynTFTItems; Index: LongInt; var ItemText: string);

procedure DynTFTRegisterItemsEvents;
function DynTFTGetItemsComponentType: TDynTFTComponentType;

implementation

var
  ComponentType: TDynTFTComponentType;

function DynTFTGetItemsComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


function DynTFTGetNumberOfItemsToDraw(AItems: PDynTFTItems): Word;   // Do not calculate based on Items.Count !!!
begin                     //bug for height < 3                 // Do not calculate based on Items.Count !!!
  Result := (AItems^.BaseProps.Height - 3) div AItems^.ItemHeight;  //Add one more pixel between rows.
end;


procedure DynTFTItemsGetItemText(AItems: PDynTFTItems; Index: LongInt; var ItemText: string);
begin
  {$IFDEF UseExternalItems}
    {$IFDEF IsDesktop}
      if Assigned(AItems^.OnGetItem) then
        if Assigned(AItems^.OnGetItem^) then
    {$ELSE}
      if AItems^.OnGetItem <> nil then
    {$ENDIF}
        AItems^.OnGetItem^(PPtrRec(TPtrRec(AItems)), Index, ItemText);
  {$ELSE}
    ItemText := AItems^.Strings[Index];
  {$ENDIF}
end;


procedure DynTFTDrawItems(AItems: PDynTFTItems; FullRedraw: Boolean);
var
  x1, y1, x2, y2: TSInt;
  i: Integer;
  NumberOfItemsToDraw: LongInt;
  IndexOfDrawingItem: LongInt;
  FocusRectangleY: LongInt;
  FontCol: TColor;
  {$IFDEF UseExternalItems}
    {$IFDEF IsDesktop}
      ATempString: string;
    {$ELSE}
      ATempString: string[CMaxItemsStringLength];
    {$ENDIF}
  {$ENDIF}
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(AItems))) then
    Exit;

  x1 := AItems^.BaseProps.Left;
  y1 := AItems^.BaseProps.Top;
  x2 := x1 + AItems^.BaseProps.Width;
  y2 := y1 + AItems^.BaseProps.Height;

  if FullRedraw then
  begin
    DynTFT_Set_Pen(CL_DynTFTItems_Border, 1);
    DynTFT_Set_Brush(1, AItems^.BackgroundColor, 0, 0, 0, 0);
    DynTFT_Rectangle(x1, y1, x2, y2);
  end;
          
  //lines
  DynTFT_Set_Pen(CL_DynTFTItems_DarkEdge, 1);
  DynTFT_V_Line(y1, y2, x1); //vert
  DynTFT_H_Line(x1, x2, y1); //horiz

  NumberOfItemsToDraw := DynTFTGetNumberOfItemsToDraw(AItems);
  if NumberOfItemsToDraw > AItems^.Count then
  begin
    NumberOfItemsToDraw := AItems^.Count;
    AItems^.FirstVisibleIndex := 0;
  end;
  FocusRectangleY := -1;

  if AItems^.BaseProps.Enabled and CENABLED = CENABLED then
    FontCol := AItems^.FontColor
  else
    FontCol := CL_DynTFTItems_DisabledFont;

  Dec(NumberOfItemsToDraw);  //to avoid using NumberOfItemsToDraw in the next for, because it is computed at every iteration :(
  for i := 0 to NumberOfItemsToDraw do
  begin
    IndexOfDrawingItem := i + AItems^.FirstVisibleIndex;
    if IndexOfDrawingItem = AItems^.ItemIndex then
    begin
      DynTFT_Set_Font(@TFT_defaultFont, AItems^.BackgroundColor, FO_HORIZONTAL);
      DynTFT_Set_Brush(1, CL_DynTFTItems_SelectedItem, 0, 0, 0, 0);                    //selected
      FocusRectangleY := y1 + i * AItems^.ItemHeight;

      DynTFT_Set_Pen(CL_DynTFTItems_SelectedItem, 1);
      DynTFT_Rectangle(x1 + 1, FocusRectangleY, x2 - 2, FocusRectangleY + AItems^.ItemHeight);
    end
    else
    begin
      DynTFT_Set_Font(@TFT_defaultFont, FontCol, FO_HORIZONTAL);
      DynTFT_Set_Brush(1, AItems^.BackgroundColor, 0, 0, 0, 0);
    end;

    {$IFDEF UseExternalItems}
      ATempString := 'OnGetItem is nil';
      {$IFDEF IsDesktop}
        ATempString := ATempString + ' ' + IntToStr(IndexOfDrawingItem); //only on desktop, to provide more debug info 

        if Assigned(AItems^.OnGetItem) then
          if Assigned(AItems^.OnGetItem^) then
      {$ELSE}
        if AItems^.OnGetItem <> nil then
      {$ENDIF}
          AItems^.OnGetItem^(PPtrRec(TPtrRec(AItems)), IndexOfDrawingItem, ATempString);
          
      DynTFT_Write_Text(ATempString, x1 + 3, y1 - 1 + i * AItems^.ItemHeight);
    {$ELSE}
      DynTFT_Write_Text(AItems^.Strings[IndexOfDrawingItem], x1 + 3, y1 - 1 + i * AItems^.ItemHeight);
    {$ENDIF}
  end;

  //Draw focus rectangle from lines
  if AItems^.BaseProps.Focused and CFOCUSED = CFOCUSED then
    DynTFT_Set_Pen(CL_DynTFTItems_FocusRectangle, 1)
  else 
    DynTFT_Set_Pen(CL_DynTFTItems_UnFocusRectangle, 1);

  if FocusRectangleY <> -1 then
  begin
    Inc(x1);
    y2 := FocusRectangleY + AItems^.ItemHeight;
    DynTFT_V_Line(FocusRectangleY, y2, x1); //vert
    DynTFT_H_Line(x1, x2 - 1, FocusRectangleY); //horiz
    DynTFT_V_Line(FocusRectangleY, y2, x2 - 1); //vert
    DynTFT_H_Line(x1, x2 - 1, y2); //horiz
  end;
end;
          

function DynTFTItems_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTItems;
var
  DummyTextWidth: Word;
  {$IFNDEF UseExternalItems}
    i: Word;
  {$ENDIF}
begin
  Result := PDynTFTItems(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTItems was not registered. Please call RegisterItemsEvents before creating a PDynTFTItems. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := True;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  GetTextWidthAndHeight('fp', DummyTextWidth, Result^.ItemHeight);    //fp is a text with great height

  {$IFDEF IsDesktop}
    New(Result^.OnOwnerInternalMouseDown);
    New(Result^.OnOwnerInternalMouseMove);
    New(Result^.OnOwnerInternalMouseUp);
    {$IFDEF UseExternalItems}
      New(Result^.OnGetItem);
    {$ENDIF}

    Result^.OnOwnerInternalMouseDown^ := nil;
    Result^.OnOwnerInternalMouseMove^ := nil;
    Result^.OnOwnerInternalMouseUp^ := nil;
  {$ELSE}
    Result^.OnOwnerInternalMouseDown := nil;
    Result^.OnOwnerInternalMouseMove := nil;
    Result^.OnOwnerInternalMouseUp := nil;
  {$ENDIF}

  Result^.ItemIndex := -1;
  Result^.Count := 0;
  Result^.FirstVisibleIndex := 0;
  Result^.BackgroundColor := CL_DynTFTItems_Background;
  Result^.FontColor := CL_DynTFTItems_EnabledFont;

  {$IFNDEF UseExternalItems}
    for i := 0 to CMaxItemItemCount - 1 do
      Result^.Strings[i] := '';
  {$ENDIF}

  {$IFDEF UseExternalItemsStringLength}
    {$IFDEF IsDesktop}
      //DynTFT_DebugConsole('Using ExternalItemsStringLength. CMaxItemsStringLength = ' + IntToStr(CMaxItemsStringLength));
    {$ENDIF}
  {$ENDIF}
end;


function DynTFTItems_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTItems_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTItems_Destroy(var AItems: PDynTFTItems);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    Dispose(AItems^.OnOwnerInternalMouseDown);
    Dispose(AItems^.OnOwnerInternalMouseMove);
    Dispose(AItems^.OnOwnerInternalMouseUp);
  {$ENDIF}

  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AItems)), SizeOf(AItems^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(AItems));
    DynTFTComponent_Destroy(ATemp, SizeOf(AItems^));
    AItems := PDynTFTItems(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTItems_DestroyAndPaint(var AItems: PDynTFTItems);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(AItems)));
  DynTFTItems_Destroy(AItems);
end;


procedure DynTFTItems_BaseDestroyAndPaint(var AItems: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTItems;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTItems_DestroyAndPaint(PDynTFTItems(TPtrRec(AItems)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTItems(TPtrRec(AItems));
    DynTFTItems_DestroyAndPaint(ATemp);
    AItems := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTItems_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
end;


procedure TDynTFTItems_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
end;


procedure TDynTFTItems_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
end;


procedure TDynTFTItems_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin                                     
  if Options = CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT then
    Exit;

  if Options = CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT then
    Exit;

  if Options = CREPAINTONMOUSEUP then
    Exit;

  DynTFTDrawItems(PDynTFTItems(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterItemsEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    ABaseEventReg.MouseDownEvent^ := TDynTFTItems_OnDynTFTBaseInternalMouseDown;
    ABaseEventReg.MouseMoveEvent^ := TDynTFTItems_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent^ := TDynTFTItems_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint^ := TDynTFTItems_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTItems_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTItems_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    ABaseEventReg.MouseDownEvent := @TDynTFTItems_OnDynTFTBaseInternalMouseDown;
    ABaseEventReg.MouseMoveEvent := @TDynTFTItems_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent := @TDynTFTItems_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint := @TDynTFTItems_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTItems_Create;
      ABaseEventReg.CompDestroy := @DynTFTItems_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTItems); 
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
