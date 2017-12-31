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

unit DynTFTScrollBar;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTBaseDrawing, DynTFTConsts, DynTFTUtils,
  DynTFTArrowButton, DynTFTPanel

  {$IFDEF IsDesktop}
    ,SysUtils, Forms
  {$ENDIF}
  ;

const
  CScrollBarHorizDir = 0;
  CScrollBarVertDir = 1;
  CScrollBarArrBtnWidthHeight = 20; //pixels
  CScrollBarArrBtnWidthHeightDbl = CScrollBarArrBtnWidthHeight * 2;
  CScrollBarArrBtnWidthHeightTrpl = CScrollBarArrBtnWidthHeight * 3;

type
  TOnScrollBarChangeEvent = procedure(AComp: PPtrRec);
  POnScrollBarChangeEvent = ^TOnScrollBarChangeEvent;

  TOnOwnerInternalAdjustScrollBar = procedure(AScrollBar: PDynTFTBaseComponent);
  POnOwnerInternalAdjustScrollBar = ^TOnOwnerInternalAdjustScrollBar;

  TDynTFTScrollBar = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //ScrollBar properties
    BtnInc, BtnDec: PDynTFTArrowButton;
    PnlScroll: PDynTFTPanel;
    Min, Max, Position, OldPosition: LongInt;
    Direction: Byte; //0 = horizontal, 1 = vertical
    PnlDragging: Byte; //0 = not dragging, 1 = dragging
    
    {$IFNDEF AppArch16}
      Dummy: Word; //keep alignment to 4 bytes
    {$ENDIF}

    //these events are set by an owner component, e.g. a list box, and called by scrollbar
    OnOwnerInternalMouseDown: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseMove: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseUp: PDynTFTGenericEventHandler;
    OnOwnerInternalAdjustScrollBar: POnOwnerInternalAdjustScrollBar;
    OnOwnerInternalAfterAdjustScrollBar: POnOwnerInternalAdjustScrollBar;
    
    OnScrollBarChange: POnScrollBarChangeEvent;
  end;
  PDynTFTScrollBar = ^TDynTFTScrollBar;

procedure DynTFTDrawScrollBar(AScrollBar: PDynTFTScrollBar; FullRedraw, RedrawButtons: Boolean);
function DynTFTScrollBar_CreateWithDir(ScreenIndex: Byte; Left, Top, Width, Height: TSInt; ScrDir: Byte): PDynTFTScrollBar;
function DynTFTScrollBar_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTScrollBar;
procedure DynTFTScrollBar_Destroy(var AScrollBar: PDynTFTScrollBar);
procedure DynTFTScrollBar_DestroyAndPaint(var AScrollBar: PDynTFTScrollBar);
                                                                            
procedure DynTFTUpdateScrollbarEventHandlers(AScrBar: PDynTFTScrollBar);
procedure DynTFTEnableScrollBar(AScrollBar: PDynTFTScrollBar);
procedure DynTFTDisableScrollBar(AScrollBar: PDynTFTScrollBar);

procedure DynTFTRegisterScrollBarEvents;
function DynTFTGetScrollBarComponentType: TDynTFTComponentType;

implementation

var
  ComponentType: TDynTFTComponentType;


function DynTFTGetScrollBarComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


function ScrBarPosToPnlPos(ScrBar: PDynTFTScrollBar): Word;
var
  TotalPanelSpace: Word;
  TotalPositionSpace: LongInt;
begin
  if ScrBar^.Direction = CScrollBarHorizDir then
    TotalPanelSpace := ScrBar^.BaseProps.Width
  else
    TotalPanelSpace := ScrBar^.BaseProps.Height;

  TotalPanelSpace := TotalPanelSpace - CScrollBarArrBtnWidthHeightTrpl - 2;
  TotalPositionSpace := ScrBar^.Max - ScrBar^.Min;

  {$IFDEF IsDesktop}
    Result := Round(LongInt(TotalPanelSpace) * ScrBar^.Position / TotalPositionSpace);
  {$ELSE}
    Result := Word(Real(Real(LongInt(TotalPanelSpace)) * Real(ScrBar^.Position) / Real(TotalPositionSpace)));
  {$ENDIF}

  Result := Result + 1;  
end;


function PnlPosToScrBarPos(ScrBar: PDynTFTScrollBar; PnlPos: LongInt): LongInt;
var
  TotalPanelSpace: Word;
  TotalPositionSpace: LongInt;
begin
  if ScrBar^.Direction = CScrollBarHorizDir then
  begin
    TotalPanelSpace := ScrBar^.BaseProps.Width;
    PnlPos := PnlPos - ScrBar^.BaseProps.Left - CScrollBarArrBtnWidthHeight;
  end
  else
  begin
    TotalPanelSpace := ScrBar^.BaseProps.Height;
    PnlPos := PnlPos - ScrBar^.BaseProps.Top - CScrollBarArrBtnWidthHeight;
  end;

  TotalPanelSpace := TotalPanelSpace - CScrollBarArrBtnWidthHeightTrpl - 2;
  TotalPositionSpace := ScrBar^.Max - ScrBar^.Min;

  PnlPos := PnlPos - 1;

  {$IFDEF IsDesktop}
    Result := Round(LongInt(PnlPos) * TotalPositionSpace / LongInt(TotalPanelSpace));
  {$ELSE}
    Result := Word(Real(Real(LongInt(PnlPos)) * Real(TotalPositionSpace) / Real(LongInt(TotalPanelSpace))));
  {$ENDIF}   
end;


procedure DynTFTDrawScrollBar(AScrollBar: PDynTFTScrollBar; FullRedraw, RedrawButtons: Boolean);
var
  BkCol: TColor;
  x1, y1, x2, y2: TSInt;
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(AScrollBar))) then
    Exit;

  x1 := AScrollBar^.BaseProps.Left;
  y1 := AScrollBar^.BaseProps.Top;
  x2 := x1 + AScrollBar^.BaseProps.Width;
  y2 := y1 + AScrollBar^.BaseProps.Height;

  if FullRedraw then        //commented for debug 2014.01.27
  begin
    if AScrollBar^.BaseProps.Enabled and CENABLED = CDISABLED then
      BkCol := CL_DynTFTScrollBar_DisabledBackground
    else
      BkCol := CL_DynTFTScrollBar_EnabledBackground;

    if AScrollBar^.Direction = CScrollBarHorizDir then
    begin
      AScrollBar^.BtnInc^.BaseProps.Left := AScrollBar^.BaseProps.Left + AScrollBar^.BaseProps.Width - CScrollBarArrBtnWidthHeight;       //right button
      AScrollBar^.BtnInc^.BaseProps.Top := AScrollBar^.BaseProps.Top;
      AScrollBar^.BtnInc^.BaseProps.Width := CScrollBarArrBtnWidthHeight;
      AScrollBar^.BtnInc^.BaseProps.Height := AScrollBar^.BaseProps.Height;
      AScrollBar^.BtnInc^.ArrowDir := CRightArrow;

      AScrollBar^.BtnDec^.BaseProps.Left := AScrollBar^.BaseProps.Left;                                //left button
      AScrollBar^.BtnDec^.BaseProps.Top := AScrollBar^.BaseProps.Top;
      AScrollBar^.BtnDec^.BaseProps.Width := CScrollBarArrBtnWidthHeight;
      AScrollBar^.BtnDec^.BaseProps.Height := AScrollBar^.BaseProps.Height;
      AScrollBar^.BtnDec^.ArrowDir := CLeftArrow;

      AScrollBar^.PnlScroll^.BaseProps.Left := AScrollBar^.BaseProps.Left + CScrollBarArrBtnWidthHeight + ScrBarPosToPnlPos(AScrollBar);  //panel
      AScrollBar^.PnlScroll^.BaseProps.Top := AScrollBar^.BaseProps.Top;
      AScrollBar^.PnlScroll^.BaseProps.Width := CScrollBarArrBtnWidthHeight;
      AScrollBar^.PnlScroll^.BaseProps.Height := AScrollBar^.BaseProps.Height;

      DynTFT_Set_Pen(BkCol, 1);
      DynTFT_Set_Brush(1, BkCol, 0, 0, 0, 0);
      DynTFT_Rectangle(x1 + CScrollBarArrBtnWidthHeight + 1, y1, x2 - CScrollBarArrBtnWidthHeight - 1, y2);
    end
    else
    begin         
      AScrollBar^.BtnInc^.BaseProps.Left := AScrollBar^.BaseProps.Left;                                //down button
      AScrollBar^.BtnInc^.BaseProps.Top := AScrollBar^.BaseProps.Top + AScrollBar^.BaseProps.Height - CScrollBarArrBtnWidthHeight;
      AScrollBar^.BtnInc^.BaseProps.Width := AScrollBar^.BaseProps.Width;
      AScrollBar^.BtnInc^.BaseProps.Height := CScrollBarArrBtnWidthHeight;
      AScrollBar^.BtnInc^.ArrowDir := CDownArrow;

      AScrollBar^.BtnDec^.BaseProps.Left := AScrollBar^.BaseProps.Left;       //up button
      AScrollBar^.BtnDec^.BaseProps.Top := AScrollBar^.BaseProps.Top;
      AScrollBar^.BtnDec^.BaseProps.Width := AScrollBar^.BaseProps.Width;
      AScrollBar^.BtnDec^.BaseProps.Height := CScrollBarArrBtnWidthHeight;
      AScrollBar^.BtnDec^.ArrowDir := CUpArrow;

      AScrollBar^.PnlScroll^.BaseProps.Left := AScrollBar^.BaseProps.Left;  //panel
      AScrollBar^.PnlScroll^.BaseProps.Top := AScrollBar^.BaseProps.Top + CScrollBarArrBtnWidthHeight + ScrBarPosToPnlPos(AScrollBar);
      AScrollBar^.PnlScroll^.BaseProps.Width := AScrollBar^.BaseProps.Width;
      AScrollBar^.PnlScroll^.BaseProps.Height := CScrollBarArrBtnWidthHeight;

      DynTFT_Set_Pen(BkCol, 1);
      DynTFT_Set_Brush(1, BkCol, 0, 0, 0, 0);
      DynTFT_Rectangle(x1, y1 + CScrollBarArrBtnWidthHeight + 1, x2, y2 - CScrollBarArrBtnWidthHeight - 1);
    end;
  end;

  if RedrawButtons then
  begin
    DynTFTDrawArrowButton(AScrollBar^.BtnInc, FullRedraw);
    DynTFTDrawArrowButton(AScrollBar^.BtnDec, FullRedraw);
  end;

  if AScrollBar^.PnlScroll^.BaseProps.Visible > CHIDDEN then
    DynTFTDrawPanel(AScrollBar^.PnlScroll, True); //always full redraw
end;


procedure DynTFTEnableScrollBar(AScrollBar: PDynTFTScrollBar);
begin
  AScrollBar^.BaseProps.Enabled := CENABLED;
  AScrollBar^.PnlScroll^.BaseProps.Enabled := CENABLED;
  AScrollBar^.PnlScroll^.Color := CL_SILVER;
  AScrollBar^.BtnInc^.BaseProps.Enabled := CENABLED;
  AScrollBar^.BtnDec^.BaseProps.Enabled := CENABLED;
  DynTFTDrawScrollBar(AScrollBar, False, True);
end;


procedure DynTFTDisableScrollBar(AScrollBar: PDynTFTScrollBar);
begin
  AScrollBar^.BaseProps.Enabled := CDISABLED;
  AScrollBar^.PnlScroll^.BaseProps.Enabled := CDISABLED;
  AScrollBar^.PnlScroll^.Color := CL_LIGHTBLUE;
  AScrollBar^.BtnInc^.BaseProps.Enabled := CDISABLED;
  AScrollBar^.BtnDec^.BaseProps.Enabled := CDISABLED;
  DynTFTDrawScrollBar(AScrollBar, False, True);
end;


procedure DynTFTUpdateScrollbarEventHandlers(AScrBar: PDynTFTScrollBar);
begin
  AScrBar^.BtnInc^.BaseProps.OnMouseDownUser := AScrBar^.BaseProps.OnMouseDownUser;      // pointer := pointer, not content !!!
  AScrBar^.BtnInc^.BaseProps.OnMouseMoveUser := AScrBar^.BaseProps.OnMouseMoveUser;
  AScrBar^.BtnInc^.BaseProps.OnMouseUpUser := AScrBar^.BaseProps.OnMouseUpUser;

  AScrBar^.BtnDec^.BaseProps.OnMouseDownUser := AScrBar^.BaseProps.OnMouseDownUser;
  AScrBar^.BtnDec^.BaseProps.OnMouseMoveUser := AScrBar^.BaseProps.OnMouseMoveUser;
  AScrBar^.BtnDec^.BaseProps.OnMouseUpUser := AScrBar^.BaseProps.OnMouseUpUser;

  AScrBar^.PnlScroll^.BaseProps.OnMouseDownUser := AScrBar^.BaseProps.OnMouseDownUser;
  AScrBar^.PnlScroll^.BaseProps.OnMouseMoveUser := AScrBar^.BaseProps.OnMouseMoveUser;
  AScrBar^.PnlScroll^.BaseProps.OnMouseUpUser := AScrBar^.BaseProps.OnMouseUpUser;
end;


procedure TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseDown(ABase: PDynTFTBaseComponent);
var
  AScrBar: PDynTFTScrollBar;
begin
  if PDynTFTBaseComponent(TPtrRec(PDynTFTPanel(TPtrRec(ABase))^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    AScrBar := PDynTFTScrollBar(TPtrRec(PDynTFTPanel(TPtrRec(ABase))^.BaseProps.Parent));
    AScrBar^.PnlDragging := 1;
    DynTFTDragOffsetX := DynTFTMCU_XMouse - PDynTFTPanel(TPtrRec(ABase))^.BaseProps.Left;
    DynTFTDragOffsetY := DynTFTMCU_YMouse - PDynTFTPanel(TPtrRec(ABase))^.BaseProps.Top;
  end
  else
    DynTFTDrawPanel(PDynTFTPanel(TPtrRec(ABase)), False);  //line added 2017.11.30  (to repaint the panel on focus change)
end;


procedure TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseMove(ABase: PDynTFTBaseComponent);
var
  AScrBar: PDynTFTScrollBar;
begin
  if PDynTFTBaseComponent(TPtrRec(PDynTFTPanel(TPtrRec(ABase))^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    AScrBar := PDynTFTScrollBar(TPtrRec(PDynTFTPanel(TPtrRec(ABase))^.BaseProps.Parent));

    ///
    ///  DragOffsetX := IsMCU_XMouse - PDynTFTPanel(TPtrRec(ABase))^.Left;
    ///  DragOffsetY := IsMCU_YMouse - PDynTFTPanel(TPtrRec(ABase))^.Top;

    //PDynTFTPanel(TPtrRec(ABase))^.Left := PIC_XMouse - DragOffsetX;
    //PDynTFTPanel(TPtrRec(ABase))^.Top := PIC_YMouse - DragOffsetY;

    if AScrBar^.PnlDragging = 1 then
    begin
      if AScrBar^.Direction = CScrollBarHorizDir then
        AScrBar^.Position := PnlPosToScrBarPos(AScrBar, DynTFTMCU_XMouse - DynTFTDragOffsetX)
      else
        AScrBar^.Position := PnlPosToScrBarPos(AScrBar, DynTFTMCU_YMouse - DynTFTDragOffsetY);

      {$IFDEF IsDesktop}
        //DebugText(IntToStr(IsMCU_XMouse) + ' : ' + IntToStr(IsMCU_YMouse) + '   Position = ' + IntToStr(AScrBar^.Position) + '   diff = ' + IntToStr(IsMCU_XMouse - DragOffsetX));
      {$ENDIF}

      if AScrBar^.Position > AScrBar^.Max then
        AScrBar^.Position := AScrBar^.Max;

      if AScrBar^.Position < AScrBar^.Min then
        AScrBar^.Position := AScrBar^.Min;

      if AScrBar^.Position <> AScrBar^.OldPosition then
      begin
        AScrBar^.OldPosition := AScrBar^.Position;

        DynTFTDrawScrollBar(AScrBar, True, False); ///draw only if changed
        {$IFDEF IsDesktop}
          if Assigned(AScrBar^.OnScrollBarChange) then
            if Assigned(AScrBar^.OnScrollBarChange^) then
        {$ELSE}
          if AScrBar^.OnScrollBarChange <> nil then
        {$ENDIF}
            AScrBar^.OnScrollBarChange^(PPtrRec(TPtrRec(AScrBar)));


        {$IFDEF IsDesktop}
          if Assigned(AScrBar^.OnOwnerInternalMouseMove) then
            if Assigned(AScrBar^.OnOwnerInternalMouseMove^) then
        {$ELSE}
          if AScrBar^.OnOwnerInternalMouseMove <> nil then
        {$ENDIF}
            AScrBar^.OnOwnerInternalMouseMove^(PDynTFTBaseComponent(TPtrRec(AScrBar)));
      end;
    end; //dragging      

    //DrawPanel(PDynTFTPanel(TPtrRec(ABase)), True);  //for debug only
  end;
end;


procedure TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseUp(ABase: PDynTFTBaseComponent);
var
  AScrBar: PDynTFTScrollBar;
begin
  if PDynTFTBaseComponent(TPtrRec(PDynTFTPanel(TPtrRec(ABase))^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    AScrBar := PDynTFTScrollBar(TPtrRec(PDynTFTPanel(TPtrRec(ABase))^.BaseProps.Parent));
    AScrBar^.PnlDragging := 0;
  end;
end;


procedure TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseDown(ABase: PDynTFTBaseComponent);
var
  AScrBar: PDynTFTScrollBar;
begin
  if PDynTFTBaseComponent(TPtrRec(PDynTFTArrowButton(TPtrRec(ABase))^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    AScrBar := PDynTFTScrollBar(TPtrRec(PDynTFTArrowButton(TPtrRec(ABase))^.BaseProps.Parent));

    {$IFDEF IsDesktop}
      if Assigned(AScrBar^.OnOwnerInternalAdjustScrollBar) then
        if Assigned(AScrBar^.OnOwnerInternalAdjustScrollBar^) then
    {$ELSE}
      if AScrBar^.OnOwnerInternalAdjustScrollBar <> nil then
    {$ENDIF}
        AScrBar^.OnOwnerInternalAdjustScrollBar^(PDynTFTBaseComponent(TPtrRec(AScrBar)));

    //These two "if"-s are identical for the two types of scrollbars H / V.
    if PDynTFTArrowButton(TPtrRec(ABase)) = AScrBar^.BtnInc then
    begin
      Inc(AScrBar^.Position);
      if AScrBar^.Position > AScrBar^.Max then
        AScrBar^.Position := AScrBar^.Max
      else
      begin
        DynTFTDrawScrollBar(AScrBar, True, False); //draw only if changed
        {$IFDEF IsDesktop}
          if Assigned(AScrBar^.OnScrollBarChange) then
            if Assigned(AScrBar^.OnScrollBarChange^) then
        {$ELSE}
          if AScrBar^.OnScrollBarChange <> nil then
        {$ENDIF}  
            AScrBar^.OnScrollBarChange^(PPtrRec(TPtrRec(AScrBar)));
      end;
    end;

    if PDynTFTArrowButton(TPtrRec(ABase)) = AScrBar^.BtnDec then
    begin
      Dec(AScrBar^.Position);
      if AScrBar^.Position < AScrBar^.Min then
        AScrBar^.Position := AScrBar^.Min
      else
      begin
        DynTFTDrawScrollBar(AScrBar, True, False); //draw only if changed
        {$IFDEF IsDesktop}
          if Assigned(AScrBar^.OnScrollBarChange) then
            if Assigned(AScrBar^.OnScrollBarChange^) then
        {$ELSE}
          if AScrBar^.OnScrollBarChange <> nil then
        {$ENDIF} 
          AScrBar^.OnScrollBarChange^(PPtrRec(TPtrRec(AScrBar)));        
      end;
    end;

    {$IFDEF IsDesktop}
      if Assigned(AScrBar^.OnOwnerInternalAfterAdjustScrollBar) then
        if Assigned(AScrBar^.OnOwnerInternalAfterAdjustScrollBar^) then
    {$ELSE}
      if AScrBar^.OnOwnerInternalAfterAdjustScrollBar <> nil then
    {$ENDIF}
        AScrBar^.OnOwnerInternalAfterAdjustScrollBar^(PDynTFTBaseComponent(TPtrRec(AScrBar)));
  end; //if is scroll bar
end;


procedure TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
                                                                                 
end;


procedure TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseUp(ABase: PDynTFTBaseComponent);
begin

end;


function DynTFTScrollBar_CreateWithDir(ScreenIndex: Byte; Left, Top, Width, Height: TSInt; ScrDir: Byte): PDynTFTScrollBar;
begin
  Result := PDynTFTScrollBar(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTScrollBar was not registered. Please call RegisterScrollBarEvents before creating a PDynTFTScrollBar. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := False;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  Result^.Direction := ScrDir;
  Result^.PnlDragging := 0; //not dragging

  Result^.BtnInc := DynTFTArrowButton_Create(ScreenIndex, 500, 280, 0, 0);   //Button dimensions are set to 0, to avoid drawing until properly positioned.
  Result^.BtnDec := DynTFTArrowButton_Create(ScreenIndex, 500, 280, 0, 0);
  Result^.PnlScroll := DynTFTPanel_Create(ScreenIndex, 500, 280, 0, 0);
  Result^.PnlScroll^.Color := CL_SILVER;

  {$IFDEF IsDesktop}
    New(Result^.OnOwnerInternalMouseDown);
    New(Result^.OnOwnerInternalMouseMove);
    New(Result^.OnOwnerInternalMouseUp);
    New(Result^.OnScrollBarChange);
    New(Result^.OnOwnerInternalAdjustScrollBar);
    New(Result^.OnOwnerInternalAfterAdjustScrollBar);
  {$ENDIF}

  Result^.BtnInc^.BaseProps.Parent := PPtrRec(TPtrRec(Result));
  Result^.BtnDec^.BaseProps.Parent := PPtrRec(TPtrRec(Result));
  Result^.PnlScroll^.BaseProps.Parent := PPtrRec(TPtrRec(Result));

  {$IFDEF IsDesktop}
    Result^.BtnInc^.OnOwnerInternalMouseDown^ := TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseDown;
    Result^.BtnInc^.OnOwnerInternalMouseMove^ := nil; //TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseMove;
    Result^.BtnInc^.OnOwnerInternalMouseUp^ := nil; //TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseUp;
  {$ELSE}
    Result^.BtnInc^.OnOwnerInternalMouseDown := @TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseDown;
    Result^.BtnInc^.OnOwnerInternalMouseMove := nil; //@TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseMove;
    Result^.BtnInc^.OnOwnerInternalMouseUp := nil; //@TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseUp;
  {$ENDIF}

  {$IFDEF IsDesktop}
    Result^.BtnDec^.OnOwnerInternalMouseDown^ := TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseDown;
    Result^.BtnDec^.OnOwnerInternalMouseMove^ := nil; //TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseMove;
    Result^.BtnDec^.OnOwnerInternalMouseUp^ := nil; //TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseUp;
  {$ELSE}
    Result^.BtnDec^.OnOwnerInternalMouseDown := @TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseDown;
    Result^.BtnDec^.OnOwnerInternalMouseMove := nil; //@TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseMove;
    Result^.BtnDec^.OnOwnerInternalMouseUp := nil; //@TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseUp;
  {$ENDIF}

  {$IFDEF IsDesktop}
    Result^.PnlScroll^.OnOwnerInternalMouseDown^ := TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseDown;
    Result^.PnlScroll^.OnOwnerInternalMouseMove^ := TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseMove;
    Result^.PnlScroll^.OnOwnerInternalMouseUp^ := TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseUp;
  {$ELSE}
    Result^.PnlScroll^.OnOwnerInternalMouseDown := @TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseDown;
    Result^.PnlScroll^.OnOwnerInternalMouseMove := @TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseMove;
    Result^.PnlScroll^.OnOwnerInternalMouseUp := @TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseUp;
  {$ENDIF}

  Result^.Min := 0;
  Result^.Max := 10;
  Result^.Position := 0;
  Result^.OldPosition := 0;
                                              
  //these event handlers will be set by a listbox if the scrollbar belongs to that listbox:
  {$IFDEF IsDesktop}
    Result^.OnOwnerInternalMouseDown^ := nil;
    Result^.OnOwnerInternalMouseMove^ := nil;
    Result^.OnOwnerInternalMouseUp^ := nil;
    Result^.OnScrollBarChange^ := nil;
    Result^.OnOwnerInternalAdjustScrollBar^ := nil;
    Result^.OnOwnerInternalAfterAdjustScrollBar^ := nil;
  {$ELSE}
    Result^.OnOwnerInternalMouseDown := nil;
    Result^.OnOwnerInternalMouseMove := nil;
    Result^.OnOwnerInternalMouseUp := nil;
    Result^.OnScrollBarChange := nil;
    Result^.OnOwnerInternalAdjustScrollBar := nil;
    Result^.OnOwnerInternalAfterAdjustScrollBar := nil;
  {$ENDIF}

  DynTFTUpdateScrollbarEventHandlers(Result);

  //DrawScrollBar(Result, True, True);  //this will set the dimensions of arrow buttons and panel
end;


function DynTFTScrollBar_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTScrollBar;
begin
  Result := DynTFTScrollBar_CreateWithDir(ScreenIndex, Left, Top, Width, Height, CScrollBarHorizDir);
end;


function DynTFTScrollBar_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTScrollBar_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTScrollBar_Destroy(var AScrollBar: PDynTFTScrollBar);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    Dispose(AScrollBar^.OnOwnerInternalMouseDown);
    Dispose(AScrollBar^.OnOwnerInternalMouseMove);
    Dispose(AScrollBar^.OnOwnerInternalMouseUp);
    Dispose(AScrollBar^.OnScrollBarChange);
    Dispose(AScrollBar^.OnOwnerInternalAdjustScrollBar);
    Dispose(AScrollBar^.OnOwnerInternalAfterAdjustScrollBar);
  {$ENDIF}

  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AScrollBar^.BtnInc)), SizeOf(AScrollBar^.BtnInc^));
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AScrollBar^.BtnDec)), SizeOf(AScrollBar^.BtnDec^));
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AScrollBar^.PnlScroll)), SizeOf(AScrollBar^.PnlScroll^));

    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AScrollBar)), SizeOf(AScrollBar^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(AScrollBar^.BtnInc));
    DynTFTComponent_Destroy(ATemp, SizeOf(AScrollBar^.BtnInc^));
    AScrollBar^.BtnInc := PDynTFTArrowButton(TPtrRec(ATemp));

    ATemp := PDynTFTBaseComponent(TPtrRec(AScrollBar^.BtnDec));
    DynTFTComponent_Destroy(ATemp, SizeOf(AScrollBar^.BtnDec^));
    AScrollBar^.BtnDec := PDynTFTArrowButton(TPtrRec(ATemp));

    ATemp := PDynTFTBaseComponent(TPtrRec(AScrollBar^.PnlScroll));
    DynTFTComponent_Destroy(ATemp, SizeOf(AScrollBar^.PnlScroll^));
    AScrollBar^.PnlScroll := PDynTFTPanel(TPtrRec(ATemp));

    ATemp := PDynTFTBaseComponent(TPtrRec(AScrollBar));
    DynTFTComponent_Destroy(ATemp, SizeOf(AScrollBar^));
    AScrollBar := PDynTFTScrollBar(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTScrollBar_DestroyAndPaint(var AScrollBar: PDynTFTScrollBar);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(AScrollBar)));
  DynTFTScrollBar_Destroy(AScrollBar);
end;


procedure DynTFTScrollBar_BaseDestroyAndPaint(var AScrollBar: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTScrollBar;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTScrollBar_DestroyAndPaint(PDynTFTScrollBar(TPtrRec(AScrollBar)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTScrollBar(TPtrRec(AScrollBar));
    DynTFTScrollBar_DestroyAndPaint(ATemp);
    AScrollBar:= PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTScrollBar_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
end;


procedure TDynTFTScrollBar_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
end;


procedure TDynTFTScrollBar_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
end;


procedure TDynTFTScrollBar_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  if Options = CREPAINTONMOUSEUP then
    Exit;

  if Options = CAFTERENABLEREPAINT then
  begin
    DynTFTEnableScrollBar(PDynTFTScrollBar(TPtrRec(ABase)));
    Exit;
  end;

  if Options = CAFTERDISABLEREPAINT then
  begin
    DynTFTDisableScrollBar(PDynTFTScrollBar(TPtrRec(ABase)));
    Exit;
  end;

  if Options = CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT then
  begin
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTScrollBar(TPtrRec(ABase))^.BtnInc)));
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTScrollBar(TPtrRec(ABase))^.BtnDec)));
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTScrollBar(TPtrRec(ABase))^.PnlScroll)));
    Exit;
  end;

  if Options = CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT then
  begin
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTScrollBar(TPtrRec(ABase))^.BtnInc)));
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTScrollBar(TPtrRec(ABase))^.BtnDec)));
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTScrollBar(TPtrRec(ABase))^.PnlScroll)));
    Exit;
  end;

  DynTFTDrawScrollBar(PDynTFTScrollBar(TPtrRec(ABase)), FullRepaint, FullRepaint);
end;
                               

procedure DynTFTRegisterScrollBarEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    ABaseEventReg.MouseDownEvent^ := TDynTFTScrollBar_OnDynTFTBaseInternalMouseDown;
    ABaseEventReg.MouseMoveEvent^ := TDynTFTScrollBar_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent^ := TDynTFTScrollBar_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint^ := TDynTFTScrollBar_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTScrollBar_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTScrollBar_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    ABaseEventReg.MouseDownEvent := @TDynTFTScrollBar_OnDynTFTBaseInternalMouseDown;
    ABaseEventReg.MouseMoveEvent := @TDynTFTScrollBar_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent := @TDynTFTScrollBar_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint := @TDynTFTScrollBar_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTScrollBar_Create;
      ABaseEventReg.CompDestroy := @DynTFTScrollBar_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTScrollBar); 
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