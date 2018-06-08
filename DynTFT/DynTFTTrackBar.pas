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

unit DynTFTTrackBar;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTBaseDrawing, DynTFTConsts, DynTFTUtils,
  DynTFTPanel

  {$IFDEF IsDesktop}
    ,SysUtils, Forms
  {$ENDIF}
  ;

const
  CTrackBarHorizDir = 0;
  CTrackBarVertDir = 1;
  CTrackBarPnlWidthHeight = 20; //px
  CTrackBarPnlWidthHeightDiv2 = 10; //px

  CTrackBarPanelFromMargin = 5; //px
  CTrackBarPanelFromMarginDbl = CTrackBarPanelFromMargin * 2; //px
  CTrackBarNotchFromMargin = 10; //px

  CTrackBarComputeEveryTick = 1;   //used for TickMode (see below)
  CTrackBarDrawRectTick = 2;   //other values, like 0 or greater than 2, will draw no ticks

type
  TOnTrackBarChangeEvent = procedure(AComp: PPtrRec);
  POnTrackBarChangeEvent = ^TOnTrackBarChangeEvent;

  TOnOwnerInternalAdjustTrackBar = procedure(ATrackBar: PDynTFTBaseComponent);
  POnOwnerInternalAdjustTrackBar = ^TOnOwnerInternalAdjustTrackBar;

  TDynTFTTrackBar = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //TrackBar properties
    PnlTrack: PDynTFTPanel;
    Min, Max, Position, OldPosition: LongInt;
    Orientation: Byte; //0 = horizontal, 1 = vertical
    PnlDragging: Byte; //0 = not dragging, 1 = dragging
    
    TickMode: Word; //word, to keep alignment to 4 bytes   This value decides if the ticks should be converted to a rectangle when they are too many.

    //these events are set by an owner component, and called by Trackbar
    OnOwnerInternalMouseDown: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseMove: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseUp: PDynTFTGenericEventHandler;
    OnOwnerInternalAdjustTrackBar: POnOwnerInternalAdjustTrackBar;
    OnOwnerInternalAfterAdjustTrackBar: POnOwnerInternalAdjustTrackBar;
    
    OnTrackBarChange: POnTrackBarChangeEvent;
  end;
  PDynTFTTrackBar = ^TDynTFTTrackBar;

procedure DynTFTDrawTrackBar(ATrackBar: PDynTFTTrackBar; FullRedraw: Boolean);
function DynTFTTrackBar_CreateWithDir(ScreenIndex: Byte; Left, Top, Width, Height: TSInt; TrbDir: Byte): PDynTFTTrackBar;
function DynTFTTrackBar_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTTrackBar;
procedure DynTFTTrackBar_Destroy(var ATrackBar: PDynTFTTrackBar);
procedure DynTFTTrackBar_DestroyAndPaint(var ATrackBar: PDynTFTTrackBar);

procedure DynTFTSetTrackBarTickMode(ATrackBar: PDynTFTTrackBar);   //Call this after setting Min or Max, or set TickMode manually if you want.                                                                         
procedure DynTFTUpdateTrackbarEventHandlers(ATrbBar: PDynTFTTrackBar);
procedure DynTFTEnableTrackBar(ATrackBar: PDynTFTTrackBar);
procedure DynTFTDisableTrackBar(ATrackBar: PDynTFTTrackBar);

procedure DynTFTRegisterTrackBarEvents;
function DynTFTGetTrackBarComponentType: TDynTFTComponentType;

implementation

var
  ComponentType: TDynTFTComponentType;


function DynTFTGetTrackBarComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


function TrbBarPosToPnlPos(TrbBar: PDynTFTTrackBar): Word;
var
  TotalPanelSpace: TSInt;
  TotalPositionSpace: LongInt;
begin
  if TrbBar^.Orientation = CTrackBarHorizDir then
    TotalPanelSpace := TrbBar^.BaseProps.Width
  else
    TotalPanelSpace := TrbBar^.BaseProps.Height;

  TotalPanelSpace := TotalPanelSpace - CTrackBarPnlWidthHeight - 2;
  TotalPositionSpace := TrbBar^.Max - TrbBar^.Min;

  {$IFDEF IsDesktop}
    Result := Round(LongInt(TotalPanelSpace) * (TrbBar^.Position - TrbBar^.Min) / TotalPositionSpace);
  {$ELSE}
    Result := Word(Real(Real(LongInt(TotalPanelSpace)) * Real(TrbBar^.Position - TrbBar^.Min) / Real(TotalPositionSpace)));
  {$ENDIF}

  Result := Result + 1;  
end;


function PnlPosToTrbBarPos(TrbBar: PDynTFTTrackBar; PnlPos: LongInt): LongInt;
var
  TotalPanelSpace: TSInt;
  TotalPositionSpace: LongInt;
begin
  if TrbBar^.Orientation = CTrackBarHorizDir then
  begin
    TotalPanelSpace := TrbBar^.BaseProps.Width;
    PnlPos := PnlPos - TrbBar^.BaseProps.Left;
  end
  else
  begin
    TotalPanelSpace := TrbBar^.BaseProps.Height;
    PnlPos := PnlPos - TrbBar^.BaseProps.Top;
  end;

  TotalPanelSpace := TotalPanelSpace - CTrackBarPnlWidthHeight - 2;
  TotalPositionSpace := TrbBar^.Max - TrbBar^.Min;

  PnlPos := PnlPos - 1;

  {$IFDEF IsDesktop}
    Result := Round(LongInt(PnlPos) * TotalPositionSpace / LongInt(TotalPanelSpace));
  {$ELSE}
    Result := Word(Real(Real(LongInt(PnlPos)) * Real(TotalPositionSpace) / Real(LongInt(TotalPanelSpace))));
  {$ENDIF}

  Result := Result + TrbBar^.Min;
end;


procedure ComputeMinMaxTickPos(ATrackBar: PDynTFTTrackBar; var MinValue, MaxValue: LongInt);
begin
  ATrackBar^.Position := ATrackBar^.Min;
  MinValue := TrbBarPosToPnlPos(ATrackBar);

  ATrackBar^.Position := ATrackBar^.Max;
  MaxValue := TrbBarPosToPnlPos(ATrackBar);
end;


procedure DrawTicks(ATrackBar: PDynTFTTrackBar; x1, y1, x2, y2: TSInt);
var
  i: LongInt;
  MinValue, MaxValue: LongInt;
  pxy: TSInt;
begin
  case ATrackBar^.TickMode of
    CTrackBarComputeEveryTick :
    begin
      if ATrackBar^.Orientation = CTrackBarHorizDir then
      begin
        for i := ATrackBar^.Min to ATrackBar^.Max do
        begin
          ATrackBar^.Position := i;
          pxy := x1 + CTrackBarPnlWidthHeightDiv2 + TrbBarPosToPnlPos(ATrackBar);

          DynTFT_Line(pxy, y1 + 1, pxy, y1 + CTrackBarPanelFromMargin - 1);
          DynTFT_Line(pxy, y2 - CTrackBarPanelFromMargin + 1, pxy, y2 - 1);
        end;
      end
      else
      begin
        for i := ATrackBar^.Min to ATrackBar^.Max do
        begin
          ATrackBar^.Position := i;
          pxy := y1 + CTrackBarPnlWidthHeightDiv2 + TrbBarPosToPnlPos(ATrackBar);

          DynTFT_Line(x1 + 1, pxy, x1 + CTrackBarPanelFromMargin - 1, pxy);
          DynTFT_Line(x2 - CTrackBarPanelFromMargin + 1, pxy, x2 - 1, pxy);
        end;
      end;
    end; //CTrackBarComputeEveryTick

    CTrackBarDrawRectTick :
    begin
      ComputeMinMaxTickPos(ATrackBar, MinValue, MaxValue);

      if ATrackBar^.Orientation = CTrackBarHorizDir then
      begin
        pxy := x1 + CTrackBarPnlWidthHeightDiv2;

        MinValue := MinValue + pxy;
        MaxValue := MaxValue + pxy;

        DynTFT_Rectangle(MinValue, y1 + 1, MaxValue, y1 + CTrackBarPanelFromMargin - 1);
        DynTFT_Rectangle(MinValue, y2 - CTrackBarPanelFromMargin + 1, MaxValue, y2 - 1);
      end
      else
      begin
        pxy := y1 + CTrackBarPnlWidthHeightDiv2;

        MinValue := MinValue + pxy;
        MaxValue := MaxValue + pxy;

        DynTFT_Rectangle(x1 + 1, MinValue, x1 + CTrackBarPanelFromMargin - 1, MaxValue);
        DynTFT_Rectangle(x2 - CTrackBarPanelFromMargin + 1, MinValue, x2 - 1, MaxValue);
      end;
    end;
  end; //case
end;


procedure DrawNotch(ATrackBar: PDynTFTTrackBar; x1, y1, x2, y2: TSInt);
begin
  if ATrackBar^.Orientation = CTrackBarHorizDir then
  begin
    DynTFT_Rectangle(x1 + CTrackBarPanelFromMargin, y1 + CTrackBarNotchFromMargin, ATrackBar^.PnlTrack^.BaseProps.Left {- 1}, y2 - CTrackBarNotchFromMargin);
    DynTFT_Rectangle(ATrackBar^.PnlTrack^.BaseProps.Left + ATrackBar^.PnlTrack^.BaseProps.Width {+ 1}, y1 + CTrackBarNotchFromMargin, x2 - CTrackBarPanelFromMargin, y2 - CTrackBarNotchFromMargin);

    DynTFT_Set_Pen(CL_DynTFTTrackBar_LightEdge, 1);
    DynTFT_Line(x1 + CTrackBarPanelFromMargin, y2 - CTrackBarNotchFromMargin, x2 - CTrackBarPanelFromMargin, y2 - CTrackBarNotchFromMargin);
  end
  else
  begin
    DynTFT_Rectangle(x1 + CTrackBarNotchFromMargin, y1 + CTrackBarPanelFromMargin, x2 - CTrackBarNotchFromMargin, ATrackBar^.PnlTrack^.BaseProps.Top {- 1});
    DynTFT_Rectangle(x1 + CTrackBarNotchFromMargin, ATrackBar^.PnlTrack^.BaseProps.Top + ATrackBar^.PnlTrack^.BaseProps.Height {+ 1}, x2 - CTrackBarNotchFromMargin, y2 - CTrackBarPanelFromMargin);

    DynTFT_Set_Pen(CL_DynTFTTrackBar_LightEdge, 1);
    DynTFT_Line(x2 - CTrackBarNotchFromMargin, y1 + CTrackBarPanelFromMargin, x2 - CTrackBarNotchFromMargin, y2 - CTrackBarPanelFromMargin);
  end;
end;


//The purpose of this procedure is to draw the slider pad around the dragging panel, to avoid flickering.
procedure DrawSliderPad(ATrackBar: PDynTFTTrackBar; x1, y1, x2, y2: TSInt);
var
  pxy3, pxy4: TSInt;
begin
  if ATrackBar^.Orientation = CTrackBarHorizDir then
  begin
    pxy3 := x1 + CTrackBarPanelFromMargin;
    DynTFT_Rectangle(x1, y1, pxy3 - 1, y2);
    DynTFT_Rectangle(x2 - CTrackBarPanelFromMargin + 1, y1, x2, y2);

    pxy4 := ATrackBar^.PnlTrack^.BaseProps.Left {- 1};
    DynTFT_Rectangle(pxy3, y1 + CTrackBarPanelFromMargin, pxy4, y1 + CTrackBarNotchFromMargin - 1);
    DynTFT_Rectangle(pxy3, y2 - CTrackBarNotchFromMargin, pxy4, y2 - CTrackBarPanelFromMargin);

    pxy3 := ATrackBar^.PnlTrack^.BaseProps.Left + ATrackBar^.PnlTrack^.BaseProps.Width {+ 1};
    pxy4 := x2 - CTrackBarPanelFromMargin;
    DynTFT_Rectangle(pxy3, y1 + CTrackBarPanelFromMargin, pxy4, y1 + CTrackBarNotchFromMargin - 1);
    DynTFT_Rectangle(pxy3, y2 - CTrackBarNotchFromMargin, pxy4, y2 - CTrackBarPanelFromMargin);
  end
  else
  begin
    pxy4 := y1 + CTrackBarPanelFromMargin;
    DynTFT_Rectangle(x1, y1, x2, pxy4 - 1);
    DynTFT_Rectangle(x1, y2 - CTrackBarPanelFromMargin + 1, x2, y2);

    pxy3 := ATrackBar^.PnlTrack^.BaseProps.Top {- 1};
    DynTFT_Rectangle(x1 + CTrackBarPanelFromMargin, pxy4, x1 + CTrackBarNotchFromMargin - 1, pxy3);
    DynTFT_Rectangle(x2 - CTrackBarNotchFromMargin, pxy4, x2 - CTrackBarPanelFromMargin, pxy3);

    pxy4 := ATrackBar^.PnlTrack^.BaseProps.Top + ATrackBar^.PnlTrack^.BaseProps.Height {+ 1};
    pxy3 := y2 - CTrackBarPanelFromMargin;
    DynTFT_Rectangle(x1 + CTrackBarPanelFromMargin, pxy4, x1 + CTrackBarNotchFromMargin - 1, pxy3);
    DynTFT_Rectangle(x2 - CTrackBarNotchFromMargin, pxy4, x2 - CTrackBarPanelFromMargin, pxy3);
  end;
end;


procedure DynTFTDrawTrackBar(ATrackBar: PDynTFTTrackBar; FullRedraw: Boolean);
var
  BkCol, NotchCol, TickCol: TColor;
  x1, y1, x2, y2: TSInt;
  APosBackup: LongInt;
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(ATrackBar))) then
    Exit;

  if ATrackBar^.Max = ATrackBar^.Min then
  begin
    {$IFDEF IsDesktop}
      raise Exception.Create('ATrackBar^.Max = ATrackBar^.Min  in DynTFTDrawTrackBar.  ' + IntToStr(ATrackBar^.Max) + ' = ' + IntToStr(ATrackBar^.Min));
    {$ENDIF}
    Exit;
  end;

  x1 := ATrackBar^.BaseProps.Left;
  y1 := ATrackBar^.BaseProps.Top;
  x2 := x1 + ATrackBar^.BaseProps.Width;
  y2 := y1 + ATrackBar^.BaseProps.Height;

  if ATrackBar^.Position < ATrackBar^.Min then
    ATrackBar^.Position := ATrackBar^.Min;

  if ATrackBar^.Position > ATrackBar^.Max then
    ATrackBar^.Position := ATrackBar^.Max;

  {$IFDEF IsDesktop}
    if ATrackBar^.Max < ATrackBar^.Min then
      DynTFT_DebugConsole('ATrackBar^.Max < ATrackBar^.Min  in DynTFTDrawTrackBar.  ' + IntToStr(ATrackBar^.Max) + ' < ' + IntToStr(ATrackBar^.Min));
  {$ENDIF}

  if ATrackBar^.BaseProps.Enabled and CENABLED = CDISABLED then
  begin
    BkCol := CL_DynTFTTrackBar_DisabledBackground;
    NotchCol := CL_DynTFTTrackBar_DisabledNotch;
    TickCol := CL_DynTFTTrackBar_DisabledTick;
  end
  else
  begin
    BkCol := CL_DynTFTTrackBar_EnabledBackground;
    NotchCol := CL_DynTFTTrackBar_EnabledNotch;
    TickCol := CL_DynTFTTrackBar_EnabledTick;
  end;

  if ATrackBar^.Orientation = CTrackBarHorizDir then
  begin
    ATrackBar^.PnlTrack^.BaseProps.Left := ATrackBar^.BaseProps.Left + TrbBarPosToPnlPos(ATrackBar);  //panel
    ATrackBar^.PnlTrack^.BaseProps.Top := ATrackBar^.BaseProps.Top + CTrackBarPanelFromMargin;
    ATrackBar^.PnlTrack^.BaseProps.Width := CTrackBarPnlWidthHeight;
    ATrackBar^.PnlTrack^.BaseProps.Height := ATrackBar^.BaseProps.Height - CTrackBarPanelFromMarginDbl;
  end
  else
  begin  
    ATrackBar^.PnlTrack^.BaseProps.Left := ATrackBar^.BaseProps.Left + CTrackBarPanelFromMargin;  //panel
    ATrackBar^.PnlTrack^.BaseProps.Top := ATrackBar^.BaseProps.Top + TrbBarPosToPnlPos(ATrackBar);
    ATrackBar^.PnlTrack^.BaseProps.Width := ATrackBar^.BaseProps.Width - CTrackBarPanelFromMarginDbl;
    ATrackBar^.PnlTrack^.BaseProps.Height := CTrackBarPnlWidthHeight;
  end;

  if FullRedraw then    
  begin
    DynTFT_Set_Pen(BkCol, 1);
    DynTFT_Set_Brush(1, BkCol, 0, 0, 0, 0);

    if ATrackBar^.Orientation = CTrackBarHorizDir then
      DynTFT_Rectangle(x1, y1, x2, y2)
    else
      DynTFT_Rectangle(x1, y1, x2, y2);

    DynTFT_Set_Pen(TickCol, 1);
    DynTFT_Set_Brush(1, TickCol, 0, 0, 0, 0);

    APosBackup := ATrackBar^.Position;
    DrawTicks(ATrackBar, x1, y1, x2, y2); //not a nice way to use TrbBarPosToPnlPos, by modifying ATrackBar^.Position, but this is a simple way to keep the code small.
    ATrackBar^.Position := APosBackup;
  end
  else
  begin
    DynTFT_Set_Pen(BkCol, 1);
    DynTFT_Set_Brush(1, BkCol, 0, 0, 0, 0);

    DrawSliderPad(ATrackBar, x1, y1, x2, y2);
  end;

  DynTFT_Set_Pen(NotchCol, 1);
  DynTFT_Set_Brush(1, NotchCol, 0, 0, 0, 0);
  DrawNotch(ATrackBar, x1, y1, x2, y2);

  if ATrackBar^.PnlTrack^.BaseProps.Visible > CHIDDEN then
    DynTFTDrawPanel(ATrackBar^.PnlTrack, True); //always full redraw
end;


procedure DynTFTSetTrackBarTickMode(ATrackBar: PDynTFTTrackBar);
var
  APosBackup: LongInt;
  MinValue, MaxValue: LongInt;
begin
  if ATrackBar^.Max = ATrackBar^.Min then
  begin
    {$IFDEF IsDesktop}
      raise Exception.Create('ATrackBar^.Max = ATrackBar^.Min  in DynTFTSetTrackBarTickMode.  ' + IntToStr(ATrackBar^.Max) + ' = ' + IntToStr(ATrackBar^.Min));
    {$ENDIF}
    Exit;
  end;

  APosBackup := ATrackBar^.Position;
  ComputeMinMaxTickPos(ATrackBar, MinValue, MaxValue);
  ATrackBar^.Position := APosBackup;

  if MaxValue - MinValue > ATrackBar^.Max - ATrackBar^.Min then
    ATrackBar^.TickMode := CTrackBarComputeEveryTick
  else
    ATrackBar^.TickMode := CTrackBarDrawRectTick;
end;


procedure DynTFTEnableTrackBar(ATrackBar: PDynTFTTrackBar);
begin
  ATrackBar^.BaseProps.Enabled := CENABLED;
  ATrackBar^.PnlTrack^.BaseProps.Enabled := CENABLED;
  ATrackBar^.PnlTrack^.Color := CL_DynTFTTrackBar_PanelBackground;
  DynTFTDrawTrackBar(ATrackBar, True);
end;


procedure DynTFTDisableTrackBar(ATrackBar: PDynTFTTrackBar);
begin
  ATrackBar^.BaseProps.Enabled := CDISABLED;
  ATrackBar^.PnlTrack^.BaseProps.Enabled := CDISABLED;
  ATrackBar^.PnlTrack^.Color := CL_DynTFTTrackBar_DisabledBackground;
  DynTFTDrawTrackBar(ATrackBar, True);
end;


procedure DynTFTUpdateTrackbarEventHandlers(ATrbBar: PDynTFTTrackBar);
begin
  ATrbBar^.PnlTrack^.BaseProps.OnMouseDownUser := ATrbBar^.BaseProps.OnMouseDownUser;
  ATrbBar^.PnlTrack^.BaseProps.OnMouseMoveUser := ATrbBar^.BaseProps.OnMouseMoveUser;
  ATrbBar^.PnlTrack^.BaseProps.OnMouseUpUser := ATrbBar^.BaseProps.OnMouseUpUser;
end;


procedure TDynTFTTrackBar_OnDynTFTChildPanelInternalMouseDown(ABase: PDynTFTBaseComponent);
var
  ATrbBar: PDynTFTTrackBar;
begin
  if PDynTFTBaseComponent(TPtrRec(PDynTFTPanel(TPtrRec(ABase))^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    ATrbBar := PDynTFTTrackBar(TPtrRec(PDynTFTPanel(TPtrRec(ABase))^.BaseProps.Parent));
    ATrbBar^.PnlDragging := 1;
    DynTFTDragOffsetX := DynTFTMCU_XMouse - PDynTFTPanel(TPtrRec(ABase))^.BaseProps.Left;
    DynTFTDragOffsetY := DynTFTMCU_YMouse - PDynTFTPanel(TPtrRec(ABase))^.BaseProps.Top;
  end
  else
    DynTFTDrawPanel(PDynTFTPanel(TPtrRec(ABase)), False);  //line added 2017.11.30  (to repaint the panel on focus change)
end;


procedure TDynTFTTrackBar_OnDynTFTChildPanelInternalMouseMove(ABase: PDynTFTBaseComponent);
var
  ATrbBar: PDynTFTTrackBar;
begin
  if PDynTFTBaseComponent(TPtrRec(PDynTFTPanel(TPtrRec(ABase))^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    ATrbBar := PDynTFTTrackBar(TPtrRec(PDynTFTPanel(TPtrRec(ABase))^.BaseProps.Parent));

    ///
    ///  DragOffsetX := IsMCU_XMouse - PDynTFTPanel(TPtrRec(ABase))^.Left;
    ///  DragOffsetY := IsMCU_YMouse - PDynTFTPanel(TPtrRec(ABase))^.Top;

    //PDynTFTPanel(TPtrRec(ABase))^.Left := PIC_XMouse - DragOffsetX;
    //PDynTFTPanel(TPtrRec(ABase))^.Top := PIC_YMouse - DragOffsetY;

    if ATrbBar^.PnlDragging = 1 then
    begin
      if ATrbBar^.Orientation = CTrackBarHorizDir then
        ATrbBar^.Position := PnlPosToTrbBarPos(ATrbBar, DynTFTMCU_XMouse - DynTFTDragOffsetX)
      else
        ATrbBar^.Position := PnlPosToTrbBarPos(ATrbBar, DynTFTMCU_YMouse - DynTFTDragOffsetY);

      {$IFDEF IsDesktop}
        //DebugText(IntToStr(IsMCU_XMouse) + ' : ' + IntToStr(IsMCU_YMouse) + '   Position = ' + IntToStr(ATrbBar^.Position) + '   diff = ' + IntToStr(IsMCU_XMouse - DragOffsetX));
      {$ENDIF}

      if ATrbBar^.Position > ATrbBar^.Max then
        ATrbBar^.Position := ATrbBar^.Max;

      if ATrbBar^.Position < ATrbBar^.Min then
        ATrbBar^.Position := ATrbBar^.Min;

      if ATrbBar^.Position <> ATrbBar^.OldPosition then
      begin
        ATrbBar^.OldPosition := ATrbBar^.Position;

        DynTFTDrawTrackBar(ATrbBar, False); ///draw only if changed
        {$IFDEF IsDesktop}
          if Assigned(ATrbBar^.OnTrackBarChange) then
            if Assigned(ATrbBar^.OnTrackBarChange^) then
        {$ELSE}
          if ATrbBar^.OnTrackBarChange <> nil then
        {$ENDIF}
            ATrbBar^.OnTrackBarChange^(PPtrRec(TPtrRec(ATrbBar)));


        {$IFDEF IsDesktop}
          if Assigned(ATrbBar^.OnOwnerInternalMouseMove) then
            if Assigned(ATrbBar^.OnOwnerInternalMouseMove^) then
        {$ELSE}
          if ATrbBar^.OnOwnerInternalMouseMove <> nil then
        {$ENDIF}
            ATrbBar^.OnOwnerInternalMouseMove^(PDynTFTBaseComponent(TPtrRec(ATrbBar)));
      end;
    end; //dragging      

    //DrawPanel(PDynTFTPanel(TPtrRec(ABase)), True);  //for debug only
  end;
end;


procedure TDynTFTTrackBar_OnDynTFTChildPanelInternalMouseUp(ABase: PDynTFTBaseComponent);
var
  ATrbBar: PDynTFTTrackBar;
begin
  if PDynTFTBaseComponent(TPtrRec(PDynTFTPanel(TPtrRec(ABase))^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    ATrbBar := PDynTFTTrackBar(TPtrRec(PDynTFTPanel(TPtrRec(ABase))^.BaseProps.Parent));
    ATrbBar^.PnlDragging := 0;
  end;
end;


function DynTFTTrackBar_CreateWithDir(ScreenIndex: Byte; Left, Top, Width, Height: TSInt; TrbDir: Byte): PDynTFTTrackBar;
begin
  Result := PDynTFTTrackBar(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTTrackBar was not registered. Please call RegisterTrackBarEvents before creating a PDynTFTTrackBar. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := False;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  Result^.Orientation := TrbDir;
  Result^.PnlDragging := 0; //not dragging

  Result^.PnlTrack := DynTFTPanel_Create(ScreenIndex, 500, 280, 0, 0);
  Result^.PnlTrack^.Color := CL_DynTFTTrackBar_PanelBackground;

  {$IFDEF IsDesktop}
    New(Result^.OnOwnerInternalMouseDown);
    New(Result^.OnOwnerInternalMouseMove);
    New(Result^.OnOwnerInternalMouseUp);
    New(Result^.OnTrackBarChange);
    New(Result^.OnOwnerInternalAdjustTrackBar);
    New(Result^.OnOwnerInternalAfterAdjustTrackBar);
  {$ENDIF}

  Result^.PnlTrack^.BaseProps.Parent := PPtrRec(TPtrRec(Result));

  {$IFDEF IsDesktop}
    Result^.PnlTrack^.OnOwnerInternalMouseDown^ := TDynTFTTrackBar_OnDynTFTChildPanelInternalMouseDown;
    Result^.PnlTrack^.OnOwnerInternalMouseMove^ := TDynTFTTrackBar_OnDynTFTChildPanelInternalMouseMove;
    Result^.PnlTrack^.OnOwnerInternalMouseUp^ := TDynTFTTrackBar_OnDynTFTChildPanelInternalMouseUp;
  {$ELSE}
    Result^.PnlTrack^.OnOwnerInternalMouseDown := @TDynTFTTrackBar_OnDynTFTChildPanelInternalMouseDown;
    Result^.PnlTrack^.OnOwnerInternalMouseMove := @TDynTFTTrackBar_OnDynTFTChildPanelInternalMouseMove;
    Result^.PnlTrack^.OnOwnerInternalMouseUp := @TDynTFTTrackBar_OnDynTFTChildPanelInternalMouseUp;
  {$ENDIF}

  Result^.Min := 0;
  Result^.Max := 10;
  Result^.Position := 0;
  Result^.OldPosition := 0;
  Result^.TickMode := CTrackBarComputeEveryTick;
                                              
  //these event handlers will be set by a listbox if the Trackbar belongs to that listbox:
  {$IFDEF IsDesktop}
    Result^.OnOwnerInternalMouseDown^ := nil;
    Result^.OnOwnerInternalMouseMove^ := nil;
    Result^.OnOwnerInternalMouseUp^ := nil;
    Result^.OnTrackBarChange^ := nil;
    Result^.OnOwnerInternalAdjustTrackBar^ := nil;
    Result^.OnOwnerInternalAfterAdjustTrackBar^ := nil;
  {$ELSE}
    Result^.OnOwnerInternalMouseDown := nil;
    Result^.OnOwnerInternalMouseMove := nil;
    Result^.OnOwnerInternalMouseUp := nil;
    Result^.OnTrackBarChange := nil;
    Result^.OnOwnerInternalAdjustTrackBar := nil;
    Result^.OnOwnerInternalAfterAdjustTrackBar := nil;
  {$ENDIF}

  DynTFTUpdateTrackbarEventHandlers(Result);
end;


function DynTFTTrackBar_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTTrackBar;
begin
  Result := DynTFTTrackBar_CreateWithDir(ScreenIndex, Left, Top, Width, Height, CTrackBarHorizDir);
end;


function DynTFTTrackBar_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTTrackBar_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTTrackBar_Destroy(var ATrackBar: PDynTFTTrackBar);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    Dispose(ATrackBar^.OnOwnerInternalMouseDown);
    Dispose(ATrackBar^.OnOwnerInternalMouseMove);
    Dispose(ATrackBar^.OnOwnerInternalMouseUp);
    Dispose(ATrackBar^.OnTrackBarChange);
    Dispose(ATrackBar^.OnOwnerInternalAdjustTrackBar);
    Dispose(ATrackBar^.OnOwnerInternalAfterAdjustTrackBar);
  {$ENDIF}

  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(ATrackBar^.PnlTrack)), SizeOf(ATrackBar^.PnlTrack^));

    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(ATrackBar)), SizeOf(ATrackBar^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(ATrackBar^.PnlTrack));
    DynTFTComponent_Destroy(ATemp, SizeOf(ATrackBar^.PnlTrack^));
    ATrackBar^.PnlTrack := PDynTFTPanel(TPtrRec(ATemp));

    ATemp := PDynTFTBaseComponent(TPtrRec(ATrackBar));
    DynTFTComponent_Destroy(ATemp, SizeOf(ATrackBar^));
    ATrackBar := PDynTFTTrackBar(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTTrackBar_DestroyAndPaint(var ATrackBar: PDynTFTTrackBar);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(ATrackBar)));
  DynTFTTrackBar_Destroy(ATrackBar);
end;


procedure DynTFTTrackBar_BaseDestroyAndPaint(var ATrackBar: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTTrackBar;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTTrackBar_DestroyAndPaint(PDynTFTTrackBar(TPtrRec(ATrackBar)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTTrackBar(TPtrRec(ATrackBar));
    DynTFTTrackBar_DestroyAndPaint(ATemp);
    ATrackBar:= PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTTrackBar_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTTrackBar(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTTrackBar(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTTrackBar(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTTrackBar(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
end;


procedure TDynTFTTrackBar_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTTrackBar(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTTrackBar(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTTrackBar(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTTrackBar(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
end;


procedure TDynTFTTrackBar_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTTrackBar(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTTrackBar(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTTrackBar(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTTrackBar(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
end;


procedure TDynTFTTrackBar_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  if Options = CREPAINTONMOUSEUP then
    Exit;

  if Options = CAFTERENABLEREPAINT then
  begin
    DynTFTEnableTrackBar(PDynTFTTrackBar(TPtrRec(ABase)));
    Exit;
  end;

  if Options = CAFTERDISABLEREPAINT then
  begin
    DynTFTDisableTrackBar(PDynTFTTrackBar(TPtrRec(ABase)));
    Exit;
  end;

  if Options = CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT then
  begin
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTTrackBar(TPtrRec(ABase))^.PnlTrack)));
    Exit;
  end;

  if Options = CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT then
  begin
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTTrackBar(TPtrRec(ABase))^.PnlTrack)));
    Exit;
  end;

  DynTFTDrawTrackBar(PDynTFTTrackBar(TPtrRec(ABase)), FullRepaint);
end;
                               

procedure DynTFTRegisterTrackBarEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    ABaseEventReg.MouseDownEvent^ := TDynTFTTrackBar_OnDynTFTBaseInternalMouseDown;
    ABaseEventReg.MouseMoveEvent^ := TDynTFTTrackBar_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent^ := TDynTFTTrackBar_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint^ := TDynTFTTrackBar_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTTrackBar_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTTrackBar_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    ABaseEventReg.MouseDownEvent := @TDynTFTTrackBar_OnDynTFTBaseInternalMouseDown;
    ABaseEventReg.MouseMoveEvent := @TDynTFTTrackBar_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent := @TDynTFTTrackBar_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint := @TDynTFTTrackBar_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTTrackBar_Create;
      ABaseEventReg.CompDestroy := @DynTFTTrackBar_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTTrackBar); 
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
