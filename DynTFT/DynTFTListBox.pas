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

unit DynTFTListBox;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTBaseDrawing, DynTFTConsts, DynTFTUtils,
  DynTFTScrollBar, DynTFTItems

  {$IFDEF IsDesktop}
    ,SysUtils, Forms
  {$ENDIF}
  ;

type
  TDynTFTListBox = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //ListBox properties
    Items: PDynTFTItems;
    VertScrollBar: PDynTFTScrollBar;

    //these events are set by an owner component, e.g. a combo box, and called by ListBox
    OnOwnerInternalMouseDown: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseMove: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseUp: PDynTFTGenericEventHandler;
  end;
  PDynTFTListBox = ^TDynTFTListBox;

procedure DynTFTDrawListBox(AListBox: PDynTFTListBox; FullRedraw: Boolean);
function DynTFTListBox_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTListBox;
procedure DynTFTListBox_Destroy(var AListBox: PDynTFTListBox);
procedure DynTFTListBox_DestroyAndPaint(var AListBox: PDynTFTListBox);

procedure DynTFTRegisterListBoxEvents;
function DynTFTGetListBoxComponentType: TDynTFTComponentType;

implementation

var
  ComponentType: TDynTFTComponentType;


function DynTFTGetListBoxComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


procedure DynTFTDrawListBox(AListBox: PDynTFTListBox; FullRedraw: Boolean);
var
  x1, y1, x2, y2: TSInt;
  NumberOfItemsToDraw: LongInt;
  AItems: PDynTFTItems;
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(AListBox))) then
    Exit;

  AItems := AListBox^.Items;
  NumberOfItemsToDraw := DynTFTGetNumberOfItemsToDraw(AItems);

  if NumberOfItemsToDraw < AItems^.Count then
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AListBox^.VertScrollBar^.PnlScroll)))
  else
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(AListBox^.VertScrollBar^.PnlScroll)));

  if AListBox^.BaseProps.Enabled and CENABLED = CENABLED then
  begin
    DynTFTEnableComponent(PDynTFTBaseComponent(TPtrRec(AItems)));
    DynTFTEnableComponent(PDynTFTBaseComponent(TPtrRec(AListBox^.VertScrollBar)));
  end
  else
  begin
    DynTFTDisableComponent(PDynTFTBaseComponent(TPtrRec(AItems)));
    DynTFTDisableComponent(PDynTFTBaseComponent(TPtrRec(AListBox^.VertScrollBar)));
  end;
    
  if FullRedraw then
  begin
    x1 := AListBox^.BaseProps.Left;
    y1 := AListBox^.BaseProps.Top;
    x2 := x1 + AListBox^.BaseProps.Width;
    y2 := y1 + AListBox^.BaseProps.Height;

    DynTFT_Set_Pen(CL_DynTFTListBox_Border, 1);
    DynTFT_Line(x1, y1, x2, y1);
    DynTFT_Line(x1, y2, x2, y2);
    DynTFT_Line(x1, y1, x1, y2);
    DynTFT_Line(x2, y1, x2, y2);

    //DrawScrollBar(AListBox^.VertScrollBar, FullRedraw, True);
    //DrawItems(AListBox^.Items, FullRedraw);
  end;
end;


procedure TDynTFTListBox_OnDynTFTChildScrollBarInternalAdjust(AScrollBar: PDynTFTBaseComponent);
var
  AListBox: PDynTFTListBox;
begin
  if PDynTFTBaseComponent(TPtrRec(AScrollBar^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then //scroll bar belongs to a listbox
  begin
    AListBox := PDynTFTListBox(TPtrRec(AScrollBar^.BaseProps.Parent));
    PDynTFTScrollBar(TPtrRec(AScrollBar))^.Max := AListBox^.Items^.Count - DynTFTGetNumberOfItemsToDraw(AListBox^.Items);
  end;
end;


procedure TDynTFTListBox_OnDynTFTChildScrollBarInternalAfterAdjust(AScrollBar: PDynTFTBaseComponent);
var
  AScrBar: PDynTFTScrollBar;
  AListBox: PDynTFTListBox;
  NewFirstVisibleIndex: Integer;
begin
  if PDynTFTBaseComponent(TPtrRec(AScrollBar^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then //scroll bar belongs to a listbox
  begin
    AScrBar := PDynTFTScrollBar(TPtrRec(AScrollBar));
    AListBox := PDynTFTListBox(TPtrRec(AScrollBar^.BaseProps.Parent));

    if AScrBar^.Position < 0 then
      AScrBar^.Position := 0;

    NewFirstVisibleIndex := AListBox^.Items^.FirstVisibleIndex;
    if NewFirstVisibleIndex <> AScrBar^.Position then
    begin
      NewFirstVisibleIndex := AScrBar^.Position;
      if NewFirstVisibleIndex > AScrBar^.Max then
        NewFirstVisibleIndex := AScrBar^.Max;
      if NewFirstVisibleIndex < 0 then
        NewFirstVisibleIndex := 0;

      AListBox^.Items^.FirstVisibleIndex := NewFirstVisibleIndex;
      DynTFTDrawItems(AListBox^.Items, True);
    end;
  end;
end;


procedure TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  //nothing here
end;


procedure TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseMove(ABase: PDynTFTBaseComponent);
var
  AScrBar: PDynTFTScrollBar;
  AListBox: PDynTFTListBox;
  MaxFirstVisibleItemIndex, NewFirstVisibleIndex: Integer;
begin
  AScrBar := PDynTFTScrollBar(TPtrRec(ABase));
  if PDynTFTBaseComponent(TPtrRec(AScrBar^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then //scroll bar belongs to a listbox
  begin
    AListBox := PDynTFTListBox(TPtrRec(AScrBar^.BaseProps.Parent));
    MaxFirstVisibleItemIndex := AListBox^.Items^.Count - DynTFTGetNumberOfItemsToDraw(AListBox^.Items);
    AScrBar^.Max := MaxFirstVisibleItemIndex;

    NewFirstVisibleIndex := AListBox^.Items^.FirstVisibleIndex;
    if NewFirstVisibleIndex <> AScrBar^.Position then
    begin
      NewFirstVisibleIndex := AScrBar^.Position;
      if NewFirstVisibleIndex > MaxFirstVisibleItemIndex then
        NewFirstVisibleIndex := MaxFirstVisibleItemIndex;
      if NewFirstVisibleIndex < 0 then
        NewFirstVisibleIndex := 0;

      AListBox^.Items^.FirstVisibleIndex := NewFirstVisibleIndex;

      DynTFTDrawItems(AListBox^.Items, True);
    end;
  end;
end;


procedure TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  //nothing here
end;


procedure TDynTFTListBox_OnDynTFTChildItemsInternalMouseDown(ABase: PDynTFTBaseComponent);
var
  AListBox: PDynTFTListBox;
  NewItemIndex: Integer;
begin
  if PDynTFTBaseComponent(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    AListBox := PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent));
    NewItemIndex := AListBox^.Items^.FirstVisibleIndex + (DynTFTMCU_YMouse - AListBox^.Items^.BaseProps.Top) div AListBox^.Items^.ItemHeight;
    if NewItemIndex > AListBox^.Items^.Count - 1 then
      NewItemIndex := -1;

    if AListBox^.Items^.ItemIndex <> NewItemIndex then
    begin
      AListBox^.Items^.ItemIndex := NewItemIndex;
      DynTFTDrawItems(AListBox^.Items, True);
    end
    else
      if AListBox^.Items^.BaseProps.Focused and CPAINTAFTERFOCUS <> CPAINTAFTERFOCUS then
      begin
        AListBox^.Items^.BaseProps.Focused := AListBox^.Items^.BaseProps.Focused or CPAINTAFTERFOCUS;
        DynTFTDrawItems(AListBox^.Items, True);
      end;
  end;
end;


procedure TDynTFTListBox_OnDynTFTChildItemsInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  //nothing here
end;


procedure TDynTFTListBox_OnDynTFTChildItemsInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.OnOwnerInternalMouseUp^(PDynTFTBaseComponent(TPtrRec(ABase^.BaseProps.Parent)));
end;


function DynTFTListBox_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTListBox;
begin                         
  Result := PDynTFTListBox(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTListBox was not registered. Please call RegisterListBoxEvents before creating a PDynTFTListBox. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := False;   //Allow events to be processed by subcomponents.
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  Result^.Items := DynTFTItems_Create(ScreenIndex, Left + 1, Top + 1, Width - CScrollBarArrBtnWidthHeight - 1, Height - 2);

  {$IFDEF IsDesktop}
    Result^.Items^.OnOwnerInternalMouseDown^ := TDynTFTListBox_OnDynTFTChildItemsInternalMouseDown;
    Result^.Items^.OnOwnerInternalMouseMove^ := TDynTFTListBox_OnDynTFTChildItemsInternalMouseMove;
    Result^.Items^.OnOwnerInternalMouseUp^ := TDynTFTListBox_OnDynTFTChildItemsInternalMouseUp;
  {$ELSE}
    Result^.Items^.OnOwnerInternalMouseDown := @TDynTFTListBox_OnDynTFTChildItemsInternalMouseDown;
    Result^.Items^.OnOwnerInternalMouseMove := @TDynTFTListBox_OnDynTFTChildItemsInternalMouseMove;
    Result^.Items^.OnOwnerInternalMouseUp := @TDynTFTListBox_OnDynTFTChildItemsInternalMouseUp;
  {$ENDIF}

  Result^.VertScrollBar := DynTFTScrollBar_Create(ScreenIndex, Left + Width - CScrollBarArrBtnWidthHeight + 1, Top + 1, CScrollBarArrBtnWidthHeight - 2, Height - 2);  // Screen: DynTFTDev - Inactive at startup
  Result^.VertScrollBar^.Max := 10;  //this will be automatically set later
  Result^.VertScrollBar^.Min := 0;
  Result^.VertScrollBar^.Position := Result^.VertScrollBar^.Min;
  Result^.VertScrollBar^.Direction := CScrollBarVertDir;

  {$IFDEF IsDesktop}
    Result^.VertScrollBar^.OnOwnerInternalMouseDown^ := TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseDown;
    Result^.VertScrollBar^.OnOwnerInternalMouseMove^ := TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseMove;
    Result^.VertScrollBar^.OnOwnerInternalMouseUp^ := TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseUp;
    Result^.VertScrollBar^.OnOwnerInternalAdjustScrollBar^ := TDynTFTListBox_OnDynTFTChildScrollBarInternalAdjust;
    Result^.VertScrollBar^.OnOwnerInternalAfterAdjustScrollBar^ := TDynTFTListBox_OnDynTFTChildScrollBarInternalAfterAdjust;
  {$ELSE}
    Result^.VertScrollBar^.OnOwnerInternalMouseDown := @TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseDown;
    Result^.VertScrollBar^.OnOwnerInternalMouseMove := @TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseMove;
    Result^.VertScrollBar^.OnOwnerInternalMouseUp := @TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseUp;
    Result^.VertScrollBar^.OnOwnerInternalAdjustScrollBar := @TDynTFTListBox_OnDynTFTChildScrollBarInternalAdjust;
    Result^.VertScrollBar^.OnOwnerInternalAfterAdjustScrollBar := @TDynTFTListBox_OnDynTFTChildScrollBarInternalAfterAdjust;
  {$ENDIF}

  Result^.VertScrollBar^.BaseProps.Parent := PPtrRec(TPtrRec(Result));
  Result^.Items^.BaseProps.Parent := PPtrRec(TPtrRec(Result));

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

  Result^.Items^.FirstVisibleIndex := 0;
  Result^.Items^.ItemIndex := -1;
  Result^.Items^.Count := 0;
end;


function DynTFTListBox_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTListBox_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTListBox_Destroy(var AListBox: PDynTFTListBox);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    Dispose(AListBox^.OnOwnerInternalMouseDown);
    Dispose(AListBox^.OnOwnerInternalMouseMove);
    Dispose(AListBox^.OnOwnerInternalMouseUp);
  {$ENDIF}

  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AListBox^.Items)), SizeOf(AListBox^.Items^));
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AListBox^.VertScrollBar)), SizeOf(AListBox^.VertScrollBar^));
  
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AListBox)), SizeOf(AListBox^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(AListBox^.Items));
    DynTFTComponent_Destroy(ATemp, SizeOf(AListBox^.Items^));
    AListBox^.Items := PDynTFTItems(TPtrRec(ATemp));

    ATemp := PDynTFTBaseComponent(TPtrRec(AListBox^.VertScrollBar));
    DynTFTComponent_Destroy(ATemp, SizeOf(AListBox^.VertScrollBar^));
    AListBox^.VertScrollBar := PDynTFTScrollBar(TPtrRec(ATemp));

    ATemp := PDynTFTBaseComponent(TPtrRec(AListBox));
    DynTFTComponent_Destroy(ATemp, SizeOf(AListBox^));
    AListBox := PDynTFTListBox(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTListBox_DestroyAndPaint(var AListBox: PDynTFTListBox);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(AListBox)));
  DynTFTListBox_Destroy(AListBox);
end;


procedure DynTFTListBox_BaseDestroyAndPaint(var AListBox: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTListBox;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTListBox_DestroyAndPaint(PDynTFTListBox(TPtrRec(AListBox)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTListBox(TPtrRec(AListBox));
    DynTFTListBox_DestroyAndPaint(ATemp);
    AListBox := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTListBox_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  (* implement these if ListBox can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
  *)
end;


procedure TDynTFTListBox_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  (* implement these if ListBox can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
  *)
end;


procedure TDynTFTListBox_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  (* implement these if ListBox can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
  *)   
end;


procedure TDynTFTListBox_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  if Options = CREPAINTONMOUSEUP then
    Exit;

  if Options = CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT then
  begin
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTListBox(TPtrRec(ABase))^.Items)));
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTListBox(TPtrRec(ABase))^.VertScrollBar)));
    Exit;
  end;

  if Options = CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT then
  begin
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTListBox(TPtrRec(ABase))^.Items)));
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTListBox(TPtrRec(ABase))^.VertScrollBar)));
    Exit;
  end;  
    
  DynTFTDrawListBox(PDynTFTListBox(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterListBoxEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    //ABaseEventReg.MouseDownEvent^ := TDynTFTListBox_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent^ := TDynTFTListBox_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent^ := TDynTFTListBox_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint^ := TDynTFTListBox_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTListBox_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTListBox_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    //ABaseEventReg.MouseDownEvent := @TDynTFTListBox_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent := @TDynTFTListBox_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent := @TDynTFTListBox_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint := @TDynTFTListBox_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTListBox_Create;
      ABaseEventReg.CompDestroy := @DynTFTListBox_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTListBox); 
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
