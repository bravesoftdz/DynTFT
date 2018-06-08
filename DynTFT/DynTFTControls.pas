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

unit DynTFTControls;

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

procedure DynTFT_GUI_LoopIteration;

implementation

{  how to call a function by pointer
GetMem(MyPtr, SomeSize); //Delphi version
MyPtr^ := Func1;         //Delphi version
MyPtr := @Func1;         // mikro version

MyPtr^(params);
}


procedure OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
var
  ComponentTypeIndex: Integer;
begin
  ComponentTypeIndex := ABase^.BaseProps.ComponentType;

  //Internal handler
  {$IFDEF IsDesktop}
    if Assigned(DynTFTRegisteredComponents[ComponentTypeIndex].MouseDownEvent) then
      if Assigned(DynTFTRegisteredComponents[ComponentTypeIndex].MouseDownEvent^) then
  {$ELSE}
    if DynTFTRegisteredComponents[ComponentTypeIndex].MouseDownEvent <> nil then
  {$ENDIF}
      DynTFTRegisteredComponents[ComponentTypeIndex].MouseDownEvent^(ABase);

  //user handler
  {$IFDEF IsDesktop}
    if Assigned(ABase^.BaseProps.OnMouseDownUser) then
      if Assigned(ABase^.BaseProps.OnMouseDownUser^) then
  {$ELSE}
    if ABase^.BaseProps.OnMouseDownUser <> nil then
  {$ENDIF}
      ABase^.BaseProps.OnMouseDownUser^(PPtrRec(TPtrRec(ABase)));
end;


procedure OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
var
  ComponentTypeIndex: Integer;
begin
  ComponentTypeIndex := ABase^.BaseProps.ComponentType;

  //Internal handler
  {$IFDEF IsDesktop}
    if Assigned(DynTFTRegisteredComponents[ComponentTypeIndex].MouseMoveEvent) then
      if Assigned(DynTFTRegisteredComponents[ComponentTypeIndex].MouseMoveEvent^) then
  {$ELSE}
    if DynTFTRegisteredComponents[ComponentTypeIndex].MouseMoveEvent <> nil then
  {$ENDIF}
      DynTFTRegisteredComponents[ComponentTypeIndex].MouseMoveEvent^(ABase);
      
  //user handler
  {$IFDEF IsDesktop}
    if Assigned(ABase^.BaseProps.OnMouseMoveUser) then
      if Assigned(ABase^.BaseProps.OnMouseMoveUser^) then
  {$ELSE}
    if ABase^.BaseProps.OnMouseMoveUser <> nil then
  {$ENDIF}
      ABase^.BaseProps.OnMouseMoveUser^(PPtrRec(TPtrRec(ABase)));
end;


procedure OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
var
  ComponentTypeIndex: Integer;
begin
  ComponentTypeIndex := ABase^.BaseProps.ComponentType;

  //Internal handler
  {$IFDEF IsDesktop}
    if Assigned(DynTFTRegisteredComponents[ComponentTypeIndex].MouseUpEvent) then
      if Assigned(DynTFTRegisteredComponents[ComponentTypeIndex].MouseUpEvent^) then
  {$ELSE}
    if DynTFTRegisteredComponents[ComponentTypeIndex].MouseUpEvent <> nil then
  {$ENDIF}
      DynTFTRegisteredComponents[ComponentTypeIndex].MouseUpEvent^(ABase);

  //user handler
  {$IFDEF IsDesktop}
    if Assigned(ABase^.BaseProps.OnMouseUpUser) then
      if Assigned(ABase^.BaseProps.OnMouseUpUser^) then
  {$ELSE}
    if ABase^.BaseProps.OnMouseUpUser <> nil then
  {$ENDIF}
      ABase^.BaseProps.OnMouseUpUser^(PPtrRec(TPtrRec(ABase)));                  
end;


procedure ExecuteComponentHandlers_FirstAction(ScreenIndex: Byte; MouseIsDown: Boolean);
var
  ParentComponent: PDynTFTComponent;
  ABase: PDynTFTBaseComponent;
  ComponentPressed: Boolean;
  MouseMoved: Boolean;
begin
  ParentComponent := DynTFTAllComponentsContainer[ScreenIndex].ScreenContainer;
  ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));

  if ParentComponent = nil then
    Exit;

  MouseMoved := (DynTFTMCU_XMouse <> DynTFTMCU_OldXMouse) or (DynTFTMCU_YMouse <> DynTFTMCU_OldYMouse);

  repeat
    ABase := PDynTFTBaseComponent(TPtrRec(ParentComponent^.BaseComponent));
    if ABase = nil then
    begin
      {$IFDEF IsDesktop}
        DynTFT_DebugConsole('Can''t work with destroyed components in ExecuteComponentHandlers_FirstAction.');
      {$ENDIF}
      Break;
    end;

    if ABase^.BaseProps.CanHandleMessages then
      if ABase^.BaseProps.Visible and CVISIBLE = CVISIBLE then
        if ABase^.BaseProps.Enabled and CENABLED = CENABLED then
        begin
          ComponentPressed := ABase^.BaseProps.CompState and CPRESSED = CPRESSED;

          if DynTFTMouseOverComponent(ABase) then
          begin
            if MouseIsDown then
            begin
              if not DynTFTAllComponentsContainer[ScreenIndex].SomeButtonDownScr and not ComponentPressed then
              begin
                if ABase^.BaseProps.Focused and CREJECTFOCUS = 0 then
                  ABase^.BaseProps.Focused := ABase^.BaseProps.Focused or CFOCUSED;//True;  //set focus status before calling the event handler where the component is redrawn

                DynTFTAllComponentsContainer[ScreenIndex].PressedComponent := PDynTFTBaseComponent(TPtrRec(ParentComponent^.BaseComponent));

                DynTFTAllComponentsContainer[ScreenIndex].SomeButtonDownScr := True;
                ABase^.BaseProps.CompState := ABase^.BaseProps.CompState or CPRESSED; //MouseIsDown

                OnDynTFTBaseInternalMouseDown(ABase);
              end;

              if MouseMoved then
                if ABase^.BaseProps.CompState and CPRESSED = CPRESSED then //can't use ComponentPressed here
                  OnDynTFTBaseInternalMouseMove(ABase);
            end
            else  //mouse is up
            begin
              DynTFTAllComponentsContainer[ScreenIndex].SomeButtonDownScr := False;
              
              if ComponentPressed then
              begin
                ABase^.BaseProps.CompState := ABase^.BaseProps.CompState xor CPRESSED; //MouseIsDown
                OnDynTFTBaseInternalMouseUp(ABase);        //this can be used for OnClick, because it is over component
              end;
            end;
          end
          else //not  MouseOverComponent(ABase)
          begin
            if MouseIsDown then
              if MouseMoved then
                if ComponentPressed then
                  OnDynTFTBaseInternalMouseMove(ABase);  //keep calling this handler even after leaving the component
          end;
        end; //Enabled

    ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));
  until ParentComponent = nil;
end;


procedure ExecuteComponentHandlers_SecondAction(ScreenIndex: Byte; MouseIsDown: Boolean);
var
  ParentComponent: PDynTFTComponent;
  ABase: PDynTFTBaseComponent;
  PressedComponentWantsFocus: Boolean;
begin
  ParentComponent := DynTFTAllComponentsContainer[ScreenIndex].ScreenContainer;
  ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));

  if ParentComponent = nil then
    Exit;

  if not MouseIsDown then    //mouse up
  begin
    if DynTFTAllComponentsContainer[ScreenIndex].PressedComponent <> nil then
      PressedComponentWantsFocus := DynTFTAllComponentsContainer[ScreenIndex].PressedComponent^.BaseProps.Focused and CREJECTFOCUS = 0
    else
      PressedComponentWantsFocus := True;

    repeat
      ABase := PDynTFTBaseComponent(TPtrRec(ParentComponent^.BaseComponent));
      if ABase = nil then
      begin
        {$IFDEF IsDesktop}
          DynTFT_DebugConsole('Can''t work with destroyed components in ExecuteComponentHandlers_SecondAction.');
        {$ENDIF}
        Break;
      end;

      if ABase^.BaseProps.CanHandleMessages then
      begin
        if ABase^.BaseProps.CompState and CPRESSED = CPRESSED then
        begin
          ABase^.BaseProps.CompState := ABase^.BaseProps.CompState xor CPRESSED;
          OnDynTFTBaseInternalMouseUp(ABase);
        end
        else
        begin
          if DynTFTAllComponentsContainer[ScreenIndex].PressedComponent <> nil then
            if ABase <> DynTFTAllComponentsContainer[ScreenIndex].PressedComponent then
              if PressedComponentWantsFocus then
                if ABase^.BaseProps.Focused and CFOCUSED = CFOCUSED then
                begin
                  DynTFTAllComponentsContainer[ScreenIndex].PressedComponent := nil;
                  ABase^.BaseProps.Focused := ABase^.BaseProps.Focused and CREJECTFOCUS;  //clear all flags except CREJECTFOCUS

                  OnDynTFTBaseInternalRepaint(ABase, True, CREPAINTONMOUSEUP, nil);
                end;
        end;
        DynTFTAllComponentsContainer[ScreenIndex].SomeButtonDownScr := False;
      end;

      ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));
    until ParentComponent = nil;
  end
  else //mouse is down outside all buttons
    DynTFTAllComponentsContainer[ScreenIndex].SomeButtonDownScr := True; //do not allow components to be pressed when moving mouse over a component
end;


procedure ExecuteComponentHandlers(ScreenIndex: Byte; MouseIsDown: Boolean);
begin
  ExecuteComponentHandlers_FirstAction(ScreenIndex, MouseIsDown);
  ExecuteComponentHandlers_SecondAction(ScreenIndex, MouseIsDown);
end;


procedure DynTFT_GUI_LoopIteration;
var
  i: Integer;
begin
  {$IFDEF IsDesktop}
    if not DynTFTComponentsAreRegistered then
      DynTFT_DebugConsole('No registered component found. Please call DynTFTRegister<ComponentType>Events for at least one component.');
  {$ENDIF}

  if DynTFTReceivedMouseDown then
  begin
    DynTFTReceivedMouseDown := False;

    for i := 0 to CDynTFTMaxComponentsContainer - 1 do
      if DynTFTAllComponentsContainer[i].Active then
        ExecuteComponentHandlers(i, True);
  end;

  if DynTFTReceivedMouseUp then
  begin
    DynTFTReceivedMouseUp := False;
    for i := 0 to CDynTFTMaxComponentsContainer - 1 do
      if DynTFTAllComponentsContainer[i].Active then
        ExecuteComponentHandlers(i, False);
  end;

  if DynTFTGBlinkingCaretStatus <> DynTFTGOldBlinkingCaretStatus then
  begin
    DynTFTGOldBlinkingCaretStatus := DynTFTGBlinkingCaretStatus;

    for i := 0 to CDynTFTMaxComponentsContainer - 1 do
      if DynTFTAllComponentsContainer[i].Active then
        DynTFTBlinkCaretsForScreenComponents(i);
  end;

  if DynTFTReceivedComponentVisualStateChange then
  begin
    DynTFTReceivedComponentVisualStateChange := False;

    for i := 0 to CDynTFTMaxComponentsContainer - 1 do
      if DynTFTAllComponentsContainer[i].Active then
        DynTFTProcessComponentVisualState(i);
  end;
end;

  
end.
