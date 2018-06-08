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

unit DynTFTBaseDrawing;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes,
  {$IFDEF IsDesktop}
    SysUtils,
  {$ENDIF}

  {$IFDEF UseSmallMM}
    DynTFTSmallMM,
  {$ELSE}
    {$IFDEF IsDesktop}
      MemManager,
    {$ENDIF}  
  {$ENDIF}

  DynTFTUtils;

  
{$IFDEF IsDesktop}
  procedure DynTFTInitBaseHandlersAndProperties(ABase: PDynTFTBaseComponent);
  procedure DynTFTFreeBaseHandlersAndProperties(ABase: PDynTFTBaseComponent);
{$ENDIF}

procedure DynTFTInitBaseHandlersToNil(ABase: PDynTFTBaseComponent);
procedure DynTFTInitBasicStatePropertiesToDefault(AComp: PDynTFTBaseComponent);

function DynTFTComponent_Create(ScreenIndex: Byte; SizeOfComponent: TPtr): PDynTFTBaseComponent;
procedure DynTFTComponent_Destroy(var AComp: PDynTFTBaseComponent; SizeOfComponent: TPtr);
procedure DynTFTComponent_DestroyMultiple(var AFirstComp, ALastComp: PDynTFTBaseComponent; SizeOfComponent: TPtr); //pass nil to ALastComp to destroy only a single component, i.e. AFirstComp. This is what DynTFTComponent_Destroy does.


{$IFDEF RTTIREG}
  //Generic "constructor" and "destructor", which use the registered component type information to obtain component size.
  //Different component types can be created and destroyed using these.

  function DynTFTComponent_CreateFromReg(AComponentType: TDynTFTComponentType; ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
  procedure DynTFTComponent_DestroyFromReg(var AComp: PDynTFTBaseComponent);
{$ENDIF}


procedure DynTFTComponent_BringMultipleComponentsToFront(AFirstComp, ALastComp: PDynTFTBaseComponent);   //pass nil to ALastComp to move only a single component, i.e. AFirstComp

procedure DynTFTAllocateInternalHandlers(var ABaseEventReg: TDynTFTBaseEventReg);
{$IFDEF IsDesktop}
  procedure DynTFTDisposeInternalHandlers(var ABaseEventReg: TDynTFTBaseEventReg);
{$ENDIF}

procedure DynTFTInitComponentTypeRegistration; //must be called before initializing component base owners (screens)
procedure DynTFTFreeComponentTypeRegistration;


function DynTFTSetComponentTypeInRegistry(ABaseEventReg: PDynTFTBaseEventReg; Index: Integer): Integer; //use this only if you can reuse elements of the RegisteredComponents array (component type registry) and want to keep its size limited. All component of the reused type (index) must be destroyed before registering a new component (at the same index).
function DynTFTRegisterComponentType(ABaseEventReg: PDynTFTBaseEventReg): Integer;  //returns > -1 for success
function DynTFTComponentsAreRegistered: Boolean;

procedure DynTFTClearComponentArea(ComponentFromArea: PDynTFTBaseComponent; AColor: TColor);
procedure DynTFTClearComponentAreaWithScreenColor(ComponentFromArea: PDynTFTBaseComponent);
procedure DynTFTRepaintScreenComponentsFromArea(ComponentFromArea: PDynTFTBaseComponent);

procedure DynTFTInitComponentContainers;
procedure DynTFTInitInputDevStateFlags;

function DynTFTPointOverComponent(AComp: PDynTFTBaseComponent; X, Y: Integer): Boolean;
function DynTFTMouseOverComponent(AComp: PDynTFTBaseComponent): Boolean;
function DynTFTIsDrawableComponent(AComp: PDynTFTBaseComponent): Boolean;

procedure OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
procedure DynTFTBlinkCaretsForScreenComponents(ScreenIndex: Byte);
procedure DynTFTProcessComponentVisualState(ScreenIndex: Byte);

procedure DynTFTRepaintScreenComponents(ScreenIndex: Byte; PaintOptions: TPtr; ComponentAreaOnly: PDynTFTBaseComponent);
procedure DynTFTRepaintScreen(ScreenIndex: Byte; PaintOptions: TPtr; ComponentAreaOnly: PDynTFTBaseComponent);


procedure DynTFTShowComponent(AComp: PDynTFTBaseComponent);
procedure DynTFTHideComponent(AComp: PDynTFTBaseComponent);
procedure DynTFTShowComponentWithDelay(AComp: PDynTFTBaseComponent);
procedure DynTFTHideComponentWithDelay(AComp: PDynTFTBaseComponent);
procedure DynTFTEnableComponent(AComp: PDynTFTBaseComponent);
procedure DynTFTDisableComponent(AComp: PDynTFTBaseComponent);
procedure DynTFTFocusComponent(AComp: PDynTFTBaseComponent);
procedure DynTFTUnfocusComponent(AComp: PDynTFTBaseComponent);

function DynTFTGetComponentContainerComponentType: TDynTFTComponentType;

function DynTFTPositiveLimit(ANumber: LongInt): LongInt; //returns 0 for negative "ANumber", and returns "ANumber" for positive "ANumber"
function DynTFTOrdBoolWord(ABool: Boolean): Word;

procedure DynTFTChangeComponentPosition(AComp: PDynTFTBaseComponent; NewLeft, NewTop: TSInt);

const
  //Component state constants (defined here, not in DynTFTConsts.pas)

  CNORMALREPAINT = $0000; //this should simply repaint the component
  CREPAINTONSTARTUP = $0001; //some components cancel the repaint process if calling Repaint with this option
  CCLEARAREAREPAINT = $0002; //use this to make the component clear an area after hiding a subcomponent from that area
  CAFTERENABLEREPAINT = $0003; //use this to make the component set additional internal state on repaint
  CAFTERDISABLEREPAINT = $0004; //use this to make the component set additional internal state on repaint
  CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT = $0005; //subcomponents might be repainted on losing focus, so use this to set them to invisible
  CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT = $0006; //call repaint with this constant, to set subcomponents to visible before calling normal repaint
  CREPAINTONMOUSEUP = $FFFF; //some components cancel the repaint process if calling Repaint with this option


  //Visible property
  CHIDDEN = 0;
  CVISIBLE = 1;
  CWILLHIDE = 2;
  CWILLSHOW = 4;
  CWILLHIDELATER = 8;  //one full list traversal delay
  CWILLSHOWLATER = 16; //one full list traversal delay

  //Enabled property
  CDISABLED = 0;
  CENABLED = 1;
  CWILLDISABLE = 2;
  CWILLENABLE = 4;

  //CompState property
  CRELEASED = 0;
  CPRESSED = 1;
  CCHANGEDNOTIFY = 2;  //reserved

  //Focused property
  CUNFOCUSED = 0;
  CFOCUSED = 1;
  CWILLFOCUS = 2;
  CWILLUNFOCUS = 4;
  CPAINTAFTERFOCUS = 8;
  CWILLDESTROY = 64; //$40
  CREJECTFOCUS = 128; //$80

  COUTOFMEMORYMESSAGE = 'Out of dynamic memory. If possible, please increase memory size from HEAP_SIZE constant in MemManager.';

var
  DynTFTReceivedMouseDown: Boolean;
  DynTFTReceivedMouseUp: Boolean;
  DynTFTReceivedComponentVisualStateChange: Boolean;
  DynTFTAllComponentsContainer: TDynTFTComponentsContainer; //this is an array of screens

  DynTFTMCU_XMouse, DynTFTMCU_YMouse: Integer;      //Directly used by some components
  DynTFTMCU_OldXMouse, DynTFTMCU_OldYMouse: Integer;
  DynTFTDragOffsetX, DynTFTDragOffsetY: LongInt;
  DynTFTGBlinkingCaretStatus, DynTFTGOldBlinkingCaretStatus: Boolean;

  DynTFTRegisteredComponents: array[0..CDynTFTMaxRegisteredComponentTypes - 1] of TDynTFTBaseEventReg;
  DynTFTRegisteredComponentCount: Integer; //number of component types in an application

implementation

{$DEFINE CenterTextOnComponent}  //to draw centered text on a component

{$IFDEF IsDesktop}
uses
  TFT;


procedure DynTFTInitBaseHandlersAndProperties(ABase: PDynTFTBaseComponent); //Delphi only
begin
  New(ABase^.BaseProps.OnMouseDownUser);
  New(ABase^.BaseProps.OnMouseMoveUser);
  New(ABase^.BaseProps.OnMouseUpUser);
  {$IFDEF ComponentsHaveName}
    New(ABase^.BaseProps.Name);
  {$ENDIF}
end;


procedure DynTFTFreeBaseHandlersAndProperties(ABase: PDynTFTBaseComponent); //Delphi only
begin
  Dispose(ABase^.BaseProps.OnMouseDownUser);
  Dispose(ABase^.BaseProps.OnMouseMoveUser);
  Dispose(ABase^.BaseProps.OnMouseUpUser);
  {$IFDEF ComponentsHaveName}
    Dispose(ABase^.BaseProps.Name);
  {$ENDIF}
end;
        
{$ENDIF}

var
  ContainerComponentType: TDynTFTComponentType;

function DynTFTGetComponentContainerComponentType: TDynTFTComponentType;
begin
  Result := ContainerComponentType;
end;  


procedure DynTFTInitBaseHandlersToNil(ABase: PDynTFTBaseComponent);  //requires InitBaseHandlers to be called in advance
begin
  {$IFDEF IsDesktop}
    ABase^.BaseProps.OnMouseDownUser^ := nil;
    ABase^.BaseProps.OnMouseMoveUser^ := nil;
    ABase^.BaseProps.OnMouseUpUser^ := nil;
  {$ELSE}
    ABase^.BaseProps.OnMouseDownUser := nil;
    ABase^.BaseProps.OnMouseMoveUser := nil;
    ABase^.BaseProps.OnMouseUpUser := nil;
  {$ENDIF}
end;


procedure DynTFTInitBasicStatePropertiesToDefault(AComp: PDynTFTBaseComponent);
begin
  AComp^.BaseProps.Enabled := CENABLED;
  AComp^.BaseProps.Visible := CVISIBLE;
  AComp^.BaseProps.Focused := CUNFOCUSED; 
  AComp^.BaseProps.CompState := CRELEASED; //not pressed, no notification
end;


procedure DynTFTInitBasicStatePropertiesToEmpty(AComp: PDynTFTBaseComponent);
begin
  AComp^.BaseProps.Enabled := CDISABLED;
  AComp^.BaseProps.Visible := CHIDDEN;
  AComp^.BaseProps.Focused := CUNFOCUSED; 
  AComp^.BaseProps.CompState := CRELEASED; //not pressed, no notification
end;


{Adds a component (the Result variable) to the linked list without initializing component data (pointed to by Component field)}
function AddComponentPointer(ComponentInChain: PDynTFTComponent): PDynTFTComponent;
begin //chain means linked list
  if ComponentInChain = nil then
  begin
    {$IFDEF IsDesktop}
      if ComponentInChain = nil then
        raise Exception.Create('AddComponentPointer requires a valid pointer as argument.');
    {$ENDIF}
  end;

  while ComponentInChain^.NextSibling <> nil do   //added to the end of list
    ComponentInChain := PDynTFTComponent(TPtrRec(ComponentInChain^.NextSibling));
       
  {$IFDEF IsMCU}
    GetMem(Result, SizeOf(TDynTFTComponent));           //"component in chain"
  {$ELSE}
    GetMem(TPtrRec(Result), SizeOf(TDynTFTComponent));  //"component in chain"    //without TPtrRec, it doesn't work in mikroPascal:  340 341 Operator "@" not applicable to these operands "?T227"
    if Result = nil then
      raise Exception.Create(COUTOFMEMORYMESSAGE);
  {$ENDIF}
  
  ComponentInChain^.NextSibling := PPtrRec(TPtrRec(Result));

  Result^.NextSibling := nil;
  Result^.BaseComponent := nil;
end;


procedure InitComponentPointer(var AComp, Parent: PDynTFTComponent; ScreenIndex: Byte);
begin
  //assume Parent <> nil
  Parent := DynTFTAllComponentsContainer[ScreenIndex].ScreenContainer;
  AComp := AddComponentPointer(PDynTFTComponent(TPtrRec(Parent)));
end;


function DynTFTComponent_Create(ScreenIndex: Byte; SizeOfComponent: TPtr): PDynTFTBaseComponent;   //something like TObject.Create
var
  AComp: PDynTFTComponent;
  Parent: PDynTFTComponent;
begin
  InitComponentPointer(AComp, Parent, ScreenIndex);

  {$IFDEF IsMCU}
    GetMem(AComp^.BaseComponent, SizeOfComponent);   //allocate button, panel, edit, etc
  {$ELSE}
    GetMem(TPtrRec(AComp^.BaseComponent), SizeOfComponent);   //allocate button, panel, edit, etc

    if AComp^.BaseComponent = nil then
      raise Exception.Create(COUTOFMEMORYMESSAGE);
  {$ENDIF}

  Result := PDynTFTBaseComponent(TPtrRec(AComp^.BaseComponent));

  Result^.BaseProps.ScreenIndex := ScreenIndex;
  Result^.BaseProps.Parent := PPtrRec(TPtrRec(Parent));

  {$IFDEF IsDesktop}
    DynTFTInitBaseHandlersAndProperties(Result); //Delphi only
  {$ENDIF}
  DynTFTInitBaseHandlersToNil(Result);
end;


//This function assumes that ALastComp was allocated after AFirstComp and they belong to the same list (same ScreenContainer).
procedure DynTFTComponent_DestroyMultiple(var AFirstComp, ALastComp: PDynTFTBaseComponent; SizeOfComponent: TPtr);   //something like TObject.Destroy, but for more identical components, allocated one after the other
var
  CurrentComp, NextComp, NextNextComp: PDynTFTComponent;
  FirstFound, LastFound: Boolean;

  //x1, y1, x2, y2: Integer; //debug only
begin //chain means linked list
  if AFirstComp = nil then
    Exit;

  {$IFDEF IsDesktop}
    if ALastComp <> nil then
      if AFirstComp^.BaseProps.ScreenIndex <> ALastComp^.BaseProps.ScreenIndex then
        raise Exception.Create('First and Last components do not belong to the same screen.  (DynTFTComponent_DestroyMultiple)');
  {$ENDIF}

  CurrentComp := DynTFTAllComponentsContainer[AFirstComp^.BaseProps.ScreenIndex].ScreenContainer;  //start at first component (a.k.a Parent)

  if CurrentComp^.NextSibling = nil then
    Exit;
                                  
  FirstFound := False;
  LastFound := False;

  repeat
    NextComp := PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling));
      
    if PDynTFTBaseComponent(TPtrRec(NextComp^.BaseComponent)) = ALastComp then
      LastFound := True;

    if NextComp <> nil then
      if FirstFound or (PDynTFTBaseComponent(TPtrRec(NextComp^.BaseComponent)) = AFirstComp) then
      begin
        FirstFound := True; //force the execution to enter here again
        {$IFDEF IsDesktop}
          DynTFTFreeBaseHandlersAndProperties(PDynTFTBaseComponent(TPtrRec(PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling))^.BaseComponent)));
        {$ENDIF}

        //Prevent repaint from dangling pointers
        DynTFTInitBasicStatePropertiesToEmpty(PDynTFTBaseComponent(TPtrRec(PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling))^.BaseComponent)));

        //Debug code  -  draw a red rectange over the destroyed component
        {
        DynTFT_Set_Brush(1, 255, 0, 0, 0, 0);
        x1 := PDynTFTBaseComponent(TPtrRec(PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling))^.BaseComponent))^.BaseProps.Left;
        y1 := PDynTFTBaseComponent(TPtrRec(PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling))^.BaseComponent))^.BaseProps.Top;
        x2 := PDynTFTBaseComponent(TPtrRec(PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling))^.BaseComponent))^.BaseProps.Width + x1;
        y2 := PDynTFTBaseComponent(TPtrRec(PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling))^.BaseComponent))^.BaseProps.Height + y1;
        DynTFT_Rectangle(x1, y1, x2, y2);
        {}

        //Free user component (payload)
        {$IFDEF IsMCU}
          FreeMem(PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling))^.BaseComponent, SizeOfComponent);  //Free payload
        {$ELSE}
          FreeMem(TPtrRec(PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling))^.BaseComponent), SizeOfComponent);  //Free payload
        {$ENDIF}

        NextNextComp := PDynTFTComponent(TPtrRec(NextComp^.NextSibling));
        CurrentComp^.NextSibling := PPtrRec(TPtrRec(NextNextComp)); //either nil or a valid component

        //free container component (component in chain)
        {$IFDEF IsMCU}
          FreeMem(NextComp, SizeOf(TDynTFTComponent));  //Free "component in chain"
        {$ELSE}
          FreeMem(TPtrRec(NextComp), SizeOf(TDynTFTComponent));  //Free "component in chain"
        {$ENDIF}

        if ALastComp = nil then
          Break;
      end;

    if LastFound then
      Break;

    if not FirstFound then
      CurrentComp := PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling));
  until PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling)) = nil;  //do not use NextComp here, it is a dangling pointer

  AFirstComp := nil; //like FreeAndNil
  ALastComp := nil; //like FreeAndNil
end;


procedure DynTFTComponent_Destroy(var AComp: PDynTFTBaseComponent; SizeOfComponent: TPtr);   //something like TObject.Destroy
var
  ALastComp: PDynTFTBaseComponent;
begin
  ALastComp := nil;
  DynTFTComponent_DestroyMultiple(AComp, ALastComp, SizeOfComponent);
end;


{$IFDEF RTTIREG}
  {
    The purpose of DynTFTComponent_CreateFromReg and DynTFTComponent_DestroyFromReg is to create and destroy a component,
    without directly call its "constructor" and "destructor". They are called via function/procedure pointers.

    This is useful to automate creation and destruction of components, based on their ComponentType information,
    using commands stored externally (SD card, USB drive etc).

    If various components are registered in a predefined order, all their instances can be created using this "constructor".

    The initial values of the "properties" of these components, can be set by writing data to memory at an address,
    computed from component address and offset of the "property" (like what compiler does when accessing a structure field).

    "Property" addresses can be obtained by looking at the component's data structure (at design time).

    Event handlers can be assigned in the same way. Their addresses can be obtained from a .lst file after compilation.
    Just make sure they are linked (perhaps creating function pointers or using orgall, will link them).

    Creating components in this manner, allows storing the UI exernally, not in code.
  }
  function DynTFTComponent_CreateFromReg(AComponentType: TDynTFTComponentType; ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
  begin
    {$IFDEF IsDesktop}
      if (AComponentType >= DynTFTRegisteredComponentCount) or (AComponentType < 0) then
        raise Exception.Create('ComponentType is out of range in DynTFTComponent_CreateFromReg.');
    {$ENDIF}

    Result := nil;

    {$IFDEF IsDesktop}
      if Assigned(DynTFTRegisteredComponents[AComponentType].CompCreate) then
        if Assigned(DynTFTRegisteredComponents[AComponentType].CompCreate^) then
    {$ELSE}
      if DynTFTRegisteredComponents[AComponentType].CompCreate <> nil then
    {$ENDIF}
        Result := DynTFTRegisteredComponents[AComponentType].CompCreate^(ScreenIndex, Left, Top, Width, Height);
  end;

  
  procedure DynTFTComponent_DestroyFromReg(var AComp: PDynTFTBaseComponent);
  begin
    if AComp = nil then
      Exit;

    {$IFDEF IsDesktop}
      if (AComp^.BaseProps.ComponentType >= DynTFTRegisteredComponentCount) or (AComp^.BaseProps.ComponentType < 0) then
        raise Exception.Create('ComponentType is out of range in DynTFTComponent_DestroyFromReg.');
    {$ENDIF}

    {$IFDEF IsDesktop}
      if Assigned(DynTFTRegisteredComponents[AComp^.BaseProps.ComponentType].CompDestroy) then
        if Assigned(DynTFTRegisteredComponents[AComp^.BaseProps.ComponentType].CompDestroy^) then
    {$ELSE}
      if DynTFTRegisteredComponents[AComp^.BaseProps.ComponentType].CompDestroy <> nil then
    {$ENDIF}
        DynTFTRegisteredComponents[AComp^.BaseProps.ComponentType].CompDestroy^(AComp);
  end;
{$ENDIF}



procedure DynTFTAllocateInternalHandlers(var ABaseEventReg: TDynTFTBaseEventReg);
begin
 {$IFDEF IsDesktop}
    New(ABaseEventReg.MouseDownEvent);
    New(ABaseEventReg.MouseMoveEvent);
    New(ABaseEventReg.MouseUpEvent);
    New(ABaseEventReg.Repaint);
    New(ABaseEventReg.BlinkCaretState);

    {$IFDEF RTTIREG}
      New(ABaseEventReg.CompCreate);
      New(ABaseEventReg.CompDestroy);
    {$ENDIF}

    ABaseEventReg.MouseDownEvent^ := nil;
    ABaseEventReg.MouseMoveEvent^ := nil;
    ABaseEventReg.MouseUpEvent^ := nil;
    ABaseEventReg.Repaint^ := nil;
    ABaseEventReg.BlinkCaretState^ := nil;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := nil;
      ABaseEventReg.CompDestroy^ := nil;
      ABaseEventReg.CompSize := 0; //just in case
    {$ENDIF}
  {$ELSE}
    ABaseEventReg.MouseDownEvent := nil;
    ABaseEventReg.MouseMoveEvent := nil;
    ABaseEventReg.MouseUpEvent := nil;
    ABaseEventReg.Repaint := nil;
    ABaseEventReg.BlinkCaretState := nil;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := nil;
      ABaseEventReg.CompDestroy := nil;
      ABaseEventReg.CompSize := 0; //just in case
    {$ENDIF}
  {$ENDIF}
end;


{$IFDEF IsDesktop}
  procedure DynTFTDisposeInternalHandlers(var ABaseEventReg: TDynTFTBaseEventReg);
  begin
    Dispose(ABaseEventReg.MouseDownEvent);
    Dispose(ABaseEventReg.MouseMoveEvent);
    Dispose(ABaseEventReg.MouseUpEvent);
    Dispose(ABaseEventReg.Repaint);
    Dispose(ABaseEventReg.BlinkCaretState);

    {$IFDEF RTTIREG}
      Dispose(ABaseEventReg.CompCreate);
      Dispose(ABaseEventReg.CompDestroy);
    {$ENDIF}

    ABaseEventReg.MouseDownEvent := nil;
    ABaseEventReg.MouseMoveEvent := nil;
    ABaseEventReg.MouseUpEvent := nil;
    ABaseEventReg.Repaint := nil;
    ABaseEventReg.BlinkCaretState := nil;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := nil;
      ABaseEventReg.CompDestroy := nil;
    {$ENDIF}
  end;
{$ENDIF}

//This function assumes that ALastComp was allocated after AFirstComp and they belong to the same list (same ScreenContainer).
procedure DynTFTComponent_BringMultipleComponentsToFront(AFirstComp, ALastComp: PDynTFTBaseComponent);   //pass nil to ALastComp to move only a single component, i.e. AFirstComp
var
  CurrentComp, NextComp, TempComp: PDynTFTComponent;
  First, Last, BeforeFirst: PDynTFTComponent;
begin //chain means linked list
  if AFirstComp = nil then
    Exit;

  {$IFDEF IsDesktop}
    if ALastComp <> nil then
      if AFirstComp^.BaseProps.ScreenIndex <> ALastComp^.BaseProps.ScreenIndex then
        raise Exception.Create('First and Last components do not belong to the same screen.  (DynTFTComponent_BringMultipleComponentsToFront)');
  {$ENDIF}

  CurrentComp := DynTFTAllComponentsContainer[AFirstComp^.BaseProps.ScreenIndex].ScreenContainer;  //start at first component (a.k.a Parent)

  if CurrentComp^.NextSibling = nil then
    Exit;
                                  
  TempComp := PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling));  //this is where the last component will point to

  if PDynTFTBaseComponent(TPtrRec(TempComp^.BaseComponent)) = AFirstComp then
    Exit; //nothing to move

  First := nil;
  Last := nil;
  BeforeFirst := nil;

  repeat
    NextComp := PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling));

    if NextComp <> nil then
    begin
      if PDynTFTBaseComponent(TPtrRec(NextComp^.BaseComponent)) = AFirstComp then
      begin
        First := NextComp;
        BeforeFirst := CurrentComp;

        if ALastComp = nil then
        begin
          Last := NextComp;
          Break;
        end;
      end;

      if PDynTFTBaseComponent(TPtrRec(NextComp^.BaseComponent)) = ALastComp then
      begin
        Last := NextComp;
        Break;
      end;
    end;

    CurrentComp := PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling));
  until PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling)) = nil;  //do not use NextComp here, it is a dangling pointer

  {$IFDEF IsDesktop}
    if Last = nil then
      raise Exception.Create('The last component, provided to DynTFTComponent_BringMultipleComponentsToFront, can''t be found.');
  {$ENDIF}

  if (First <> nil) and (Last <> nil) then
  begin
    DynTFTAllComponentsContainer[AFirstComp^.BaseProps.ScreenIndex].ScreenContainer^.NextSibling := PPtrRec(TPtrRec(First));   //step1
    BeforeFirst^.NextSibling := PPtrRec(TPtrRec(Last^.NextSibling)); //step2
    Last^.NextSibling := PPtrRec(TPtrRec(TempComp)); //step3
  end;
end;


procedure DynTFTInitComponentTypeRegistration;
var
  i: Integer;
begin
  DynTFTRegisteredComponentCount := 0;

  for i := 0 to CDynTFTMaxRegisteredComponentTypes - 1 do
    DynTFTAllocateInternalHandlers(DynTFTRegisteredComponents[i]);
end;


procedure DynTFTFreeComponentTypeRegistration;
{$IFDEF IsDesktop}
  var
    i: Integer;
{$ENDIF}
begin
  DynTFTRegisteredComponentCount := 0;

  {$IFDEF IsDesktop}
    for i := 0 to CDynTFTMaxRegisteredComponentTypes - 1 do
      DynTFTDisposeInternalHandlers(DynTFTRegisteredComponents[i]);
  {$ENDIF}
end;


//When reusing a component type, i.e. index, make sure there are no instances of the old component type using that index. Memory corruption will occur if not used properly.
function DynTFTSetComponentTypeInRegistry(ABaseEventReg: PDynTFTBaseEventReg; Index: Integer): Integer;  //returns > -1 for success
begin
  if (Index < 0) or (Index >= CDynTFTMaxRegisteredComponentTypes - 1) then
  begin
    Result := -1; //
    {$IFDEF IsDesktop}
      DynTFT_DebugConsole('Entering DynTFTSetComponentTypeInRegistry with invalid registry index: ' + IntToStr(Index) + '. Skipping registration.');
    {$ENDIF}  
    Exit;
  end;

  {$IFDEF IsDesktop}
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].MouseDownEvent^ := ABaseEventReg^.MouseDownEvent^;
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].MouseMoveEvent^ := ABaseEventReg^.MouseMoveEvent^;
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].MouseUpEvent^ := ABaseEventReg^.MouseUpEvent^;
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].Repaint^ := ABaseEventReg^.Repaint^;
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].BlinkCaretState^ := ABaseEventReg^.BlinkCaretState^;

    {$IFDEF RTTIREG}
      DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].CompCreate^ := ABaseEventReg^.CompCreate^;
      DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].CompDestroy^ := ABaseEventReg^.CompDestroy^;
    {$ENDIF}  
  {$ELSE}
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].MouseDownEvent := ABaseEventReg^.MouseDownEvent;
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].MouseMoveEvent := ABaseEventReg^.MouseMoveEvent;
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].MouseUpEvent := ABaseEventReg^.MouseUpEvent;
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].Repaint := ABaseEventReg^.Repaint;
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].BlinkCaretState := ABaseEventReg^.BlinkCaretState;

    {$IFDEF RTTIREG}
      DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].CompCreate := ABaseEventReg^.CompCreate;
      DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].CompDestroy := ABaseEventReg^.CompDestroy;
    {$ENDIF} 
  {$ENDIF}

  {$IFDEF RTTIREG}
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].CompSize := ABaseEventReg^.CompSize;
  {$ENDIF}

  Result := Index;
end;


function DynTFTRegisterComponentType(ABaseEventReg: PDynTFTBaseEventReg): Integer;  //returns > -1 for success
begin
  if DynTFTRegisteredComponentCount >= CDynTFTMaxRegisteredComponentTypes - 1 then
  begin
    Result := -1; //
    {$IFDEF IsDesktop}
      DynTFT_DebugConsole('No room left for registering more component types. Please increase CDynTFTMaxRegisteredComponentTypes constant.');
    {$ENDIF}
    Exit;
  end;

  Result := DynTFTSetComponentTypeInRegistry(ABaseEventReg, DynTFTRegisteredComponentCount);
  if Result > -1 then
    Inc(DynTFTRegisteredComponentCount);
end;


function DynTFTComponentsAreRegistered: Boolean;
begin
  Result := DynTFTRegisteredComponentCount > 0;
end;


procedure DynTFTClearComponentArea(ComponentFromArea: PDynTFTBaseComponent; AColor: TColor);
var
  x1, y1, x2, y2: Integer;
begin
  if ComponentFromArea = nil then
  begin
    {$IFDEF IsDesktop}
      raise Exception.Create('ComponentFromArea is nil in DynTFTClearComponentArea.');
    {$ENDIF}
    Exit;
  end;
  
  DynTFT_Set_Pen(AColor, 1);
  DynTFT_Set_Brush(1, AColor, 0, 0, 0, 0);

  x1 := ComponentFromArea^.BaseProps.Left;
  y1 := ComponentFromArea^.BaseProps.Top;

  x2 := x1 + ComponentFromArea^.BaseProps.Width;
  y2 := y1 + ComponentFromArea^.BaseProps.Height;
  DynTFT_Rectangle(x1, y1, x2, y2);
end;


procedure DynTFTClearComponentAreaWithScreenColor(ComponentFromArea: PDynTFTBaseComponent);
begin
  if ComponentFromArea = nil then
  begin
    {$IFDEF IsDesktop}
      raise Exception.Create('ComponentFromArea is nil in ClearComponentAreaWithScreenColor. Are you destroying an already destroyed component?');
    {$ENDIF}
    Exit;
  end;
  DynTFTClearComponentArea(ComponentFromArea, DynTFTAllComponentsContainer[ComponentFromArea^.BaseProps.ScreenIndex].ScreenColor);
end;


procedure TDynTFTComponentContainer_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  if ComponentFromArea = nil then
    Exit;

  //AComp := PDynTFTComponent(TPtrRec(ABase));
  if Options = CCLEARAREAREPAINT then
    DynTFTClearComponentAreaWithScreenColor(ComponentFromArea);
end;


procedure RegisterComponentContainerEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    //The following assignments, which are commented, are not used, because these fields are initialized in InitComponentTypeRegistration.

    //ABaseEventReg.MouseDownEvent^ := nil;
    //ABaseEventReg.MouseMoveEvent^ := nil;
    //ABaseEventReg.MouseUpEvent^ := nil;
    ABaseEventReg.Repaint^ := TDynTFTComponentContainer_OnDynTFTBaseInternalRepaint;
    //ABaseEventReg.BlinkCaretState^ := nil;

    {$IFDEF RTTIREG}
      //ABaseEventReg.CompCreate^ := nil;
      //ABaseEventReg.CompDestroy^ := nil;
    {$ENDIF}
  {$ELSE}
    //ABaseEventReg.MouseDownEvent := nil;
    //ABaseEventReg.MouseMoveEvent := nil;
    //ABaseEventReg.MouseUpEvent := nil;
    ABaseEventReg.Repaint := @TDynTFTComponentContainer_OnDynTFTBaseInternalRepaint;
    //ABaseEventReg.BlinkCaretState := nil;
    {$IFDEF RTTIREG}
      //ABaseEventReg.CompCreate := nil;
      //ABaseEventReg.CompDestroy := nil;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    //ABaseEventReg.CompSize := 0; //change this when allocating extra component on a screen container
  {$ENDIF}

  ContainerComponentType := DynTFTRegisterComponentType(@ABaseEventReg);

  {$IFDEF IsDesktop}
    DynTFTDisposeInternalHandlers(ABaseEventReg);
  {$ENDIF}
end;


procedure DynTFTInitComponentContainers;
var
  i: Integer;
begin
  RegisterComponentContainerEvents;  {$IFDEF IsDesktop}DynTFT_DebugConsole('ComponentContainer type: ' + IntToStr(DynTFTGetComponentContainerComponentType));{$ENDIF}

  for i := 0 to CDynTFTMaxComponentsContainer - 1 do
  begin
    DynTFTAllComponentsContainer[i].PressedComponent := nil;
    DynTFTAllComponentsContainer[i].SomeButtonDownScr := False;
    DynTFTAllComponentsContainer[i].Active := True;

    {$IFDEF IsMCU}
      GetMem(DynTFTAllComponentsContainer[i].ScreenContainer, SizeOf(TDynTFTComponent));
    {$ELSE}
      GetMem(TPtr(DynTFTAllComponentsContainer[i].ScreenContainer), SizeOf(TDynTFTComponent));

      if DynTFTAllComponentsContainer[i].ScreenContainer = nil then
        raise Exception.Create(COUTOFMEMORYMESSAGE);
    {$ENDIF}

    DynTFTAllComponentsContainer[i].ScreenContainer^.BaseComponent := nil;
    DynTFTAllComponentsContainer[i].ScreenContainer^.NextSibling := nil;

    DynTFTAllComponentsContainer[i].ScreenColor := 0;
  end;
end;  


procedure DynTFTInitInputDevStateFlags;
begin
  DynTFTReceivedMouseDown := False;
  DynTFTReceivedMouseUp := False;
  DynTFTReceivedComponentVisualStateChange := False;
  
  DynTFTGBlinkingCaretStatus := False;
  DynTFTGOldBlinkingCaretStatus := False;
end;

///=======================

function DynTFTPointOverComponent(AComp: PDynTFTBaseComponent; X, Y: Integer): Boolean;
begin
  Result := True;
                   //mikroPascal PRO for IsMCU v3.3.3 does not have a "complete boolean eval" option to be turned off, so make individual evaluations
  if X < AComp^.BaseProps.Left then
  begin
    Result := False;
    Exit;
  end;

  if Y < AComp^.BaseProps.Top then
  begin
    Result := False;
    Exit;
  end;

  if X > AComp^.BaseProps.Left + AComp^.BaseProps.Width then
  begin
    Result := False;
    Exit;
  end;

  if Y > AComp^.BaseProps.Top + AComp^.BaseProps.Height then
  begin
    Result := False;
    Exit;
  end;
end;


function DynTFTMouseOverComponent(AComp: PDynTFTBaseComponent): Boolean;
begin
  Result := DynTFTPointOverComponent(AComp, DynTFTMCU_XMouse, DynTFTMCU_YMouse);
end;


//verifies for partial overlapping
function ComponentOverlapsComponent(OverlappingComp, OverlappedComp: PDynTFTBaseComponent): Boolean;
var
  x1, y1, x2, y2: Integer;
begin
  Result := False;
  //A component overlaps another if at least one of its corners is above the area defined by the overlapped.

  x1 := OverlappingComp^.BaseProps.Left;
  y1 := OverlappingComp^.BaseProps.Top;
  x2 := x1 + OverlappingComp^.BaseProps.Width;
  y2 := y1 + OverlappingComp^.BaseProps.Height;
  
  if DynTFTPointOverComponent(OverlappedComp, x1, y1) then
  begin
    Result := True;
    Exit;
  end;

  if DynTFTPointOverComponent(OverlappedComp, x2, y1) then
  begin
    Result := True;
    Exit;
  end;

  if DynTFTPointOverComponent(OverlappedComp, x1, y2) then
  begin
    Result := True;
    Exit;
  end;

  if DynTFTPointOverComponent(OverlappedComp, x2, y2) then
  begin
    Result := True;
    Exit;
  end;
end;


function DynTFTIsDrawableComponent(AComp: PDynTFTBaseComponent): Boolean;
begin
  Result := True;

  if not DynTFTAllComponentsContainer[AComp^.BaseProps.ScreenIndex].Active then
  begin
    Result := False;
    Exit;
  end;

  if AComp^.BaseProps.Visible = CHIDDEN then
  begin
    Result := False;
    Exit;
  end;

  if (AComp^.BaseProps.Width = 0) or (AComp^.BaseProps.Height = 0) then
  begin
    Result := False;
    Exit;
  end;
end;



procedure OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
var
  ComponentTypeIndex: Integer;
begin
  ComponentTypeIndex := ABase^.BaseProps.ComponentType;

  //Internal handler
  {$IFDEF IsDesktop}
    if Assigned(DynTFTRegisteredComponents[ComponentTypeIndex].Repaint) then
      if Assigned(DynTFTRegisteredComponents[ComponentTypeIndex].Repaint^) then
  {$ELSE}
    if DynTFTRegisteredComponents[ComponentTypeIndex].Repaint <> nil then
  {$ENDIF}
      DynTFTRegisteredComponents[ComponentTypeIndex].Repaint^(ABase, FullRepaint, Options, ComponentFromArea);       
  //debug code for Delphi on else case ... because the repaint handler must be assigned /////////////////////////////////////////////////////////
end;


procedure OnDynTFTBaseInternalBlinkCaretState(ABase: PDynTFTBaseComponent);
var
  ComponentTypeIndex: Integer;
begin
  ComponentTypeIndex := ABase^.BaseProps.ComponentType;

  //Internal handler
  {$IFDEF IsDesktop}
    if Assigned(DynTFTRegisteredComponents[ComponentTypeIndex].BlinkCaretState) then
      if Assigned(DynTFTRegisteredComponents[ComponentTypeIndex].BlinkCaretState^) then
  {$ELSE}
    if DynTFTRegisteredComponents[ComponentTypeIndex].BlinkCaretState <> nil then
  {$ENDIF}
      DynTFTRegisteredComponents[ComponentTypeIndex].BlinkCaretState^(ABase);
end;


procedure DynTFTShowComponent(AComp: PDynTFTBaseComponent);
begin
  if AComp = nil then
    Exit;
    
  AComp^.BaseProps.Visible := AComp^.BaseProps.Visible or CWILLSHOW;
  DynTFTReceivedComponentVisualStateChange := True;
end;


procedure DynTFTHideComponent(AComp: PDynTFTBaseComponent);
begin
  if AComp = nil then
    Exit;
    
  AComp^.BaseProps.Visible := AComp^.BaseProps.Visible or CWILLHIDE;
  DynTFTReceivedComponentVisualStateChange := True;
end;


procedure DynTFTShowComponentWithDelay(AComp: PDynTFTBaseComponent);
begin
  if AComp = nil then
    Exit;
    
  AComp^.BaseProps.Visible := AComp^.BaseProps.Visible or CWILLSHOWLATER;
  DynTFTReceivedComponentVisualStateChange := True;
end;


procedure DynTFTHideComponentWithDelay(AComp: PDynTFTBaseComponent);
begin
  if AComp = nil then
    Exit;
    
  AComp^.BaseProps.Visible := AComp^.BaseProps.Visible or CWILLHIDELATER;
  DynTFTReceivedComponentVisualStateChange := True;
end;


procedure DynTFTEnableComponent(AComp: PDynTFTBaseComponent);
begin
  if AComp = nil then
    Exit;
    
  AComp^.BaseProps.Enabled := AComp^.BaseProps.Enabled or CWILLENABLE;
  DynTFTReceivedComponentVisualStateChange := True;
end;


procedure DynTFTDisableComponent(AComp: PDynTFTBaseComponent);
begin
  if AComp = nil then
    Exit;
    
  AComp^.BaseProps.Enabled := AComp^.BaseProps.Enabled or CWILLDISABLE;
  DynTFTReceivedComponentVisualStateChange := True;
end;


procedure DynTFTFocusComponent(AComp: PDynTFTBaseComponent);
begin
  if AComp = nil then
    Exit;
    
  AComp^.BaseProps.Focused := AComp^.BaseProps.Focused or CWILLFOCUS;
  DynTFTReceivedComponentVisualStateChange := True;
end;


procedure DynTFTUnfocusComponent(AComp: PDynTFTBaseComponent);
begin
  if AComp = nil then
    Exit;
    
  AComp^.BaseProps.Focused := AComp^.BaseProps.Focused or CWILLUNFOCUS;
  DynTFTReceivedComponentVisualStateChange := True;
end;


procedure SetComponentVisualState(ABase: PDynTFTBaseComponent);
begin
  if ABase = nil then
    Exit;

  if ABase^.BaseProps.Visible and CWILLHIDE = CWILLHIDE then
  begin
    ABase^.BaseProps.Visible := CHIDDEN;
    OnDynTFTBaseInternalRepaint(ABase, True, CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT, nil);
    OnDynTFTBaseInternalRepaint(PDynTFTBaseComponent(TPtrRec(ABase^.BaseProps.Parent)), True, CCLEARAREAREPAINT, ABase);
  end;

  if ABase^.BaseProps.Visible and CWILLSHOW = CWILLSHOW then
  begin
    ABase^.BaseProps.Visible := CVISIBLE;
    OnDynTFTBaseInternalRepaint(ABase, True, CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT, nil);
    OnDynTFTBaseInternalRepaint(ABase, True, CNORMALREPAINT, nil);
  end;

  if ABase^.BaseProps.Visible and CWILLHIDELATER = CWILLHIDELATER then
  begin
    ABase^.BaseProps.Visible := ABase^.BaseProps.Visible xor CWILLHIDELATER;
    DynTFTHideComponent(ABase);
  end;

  if ABase^.BaseProps.Visible and CWILLSHOWLATER = CWILLSHOWLATER then
  begin
    ABase^.BaseProps.Visible := ABase^.BaseProps.Visible xor CWILLSHOWLATER;
    DynTFTShowComponent(ABase);
  end;
  

  if ABase^.BaseProps.Enabled and CWILLDISABLE = CWILLDISABLE then
  begin
    ABase^.BaseProps.Enabled := CDISABLED;
    OnDynTFTBaseInternalRepaint(ABase, True, CAFTERDISABLEREPAINT, nil);
  end;

  if ABase^.BaseProps.Enabled and CWILLENABLE = CWILLENABLE then
  begin
    ABase^.BaseProps.Enabled := CENABLED;
    OnDynTFTBaseInternalRepaint(ABase, True, CAFTERENABLEREPAINT, nil);
  end;

  if ABase^.BaseProps.Focused and CWILLFOCUS = CWILLFOCUS then
  begin
    ABase^.BaseProps.Focused := CFOCUSED;
    OnDynTFTBaseInternalRepaint(ABase, True, CREPAINTONSTARTUP, nil);   /////////// use CREPAINTONSTARTUP until proper implementation 
  end;

  if ABase^.BaseProps.Focused and CWILLUNFOCUS = CWILLUNFOCUS then
  begin
    ABase^.BaseProps.Focused := CUNFOCUSED;
    OnDynTFTBaseInternalRepaint(ABase, True, CREPAINTONSTARTUP, nil);   /////////// use CREPAINTONSTARTUP until proper implementation
  end;

  {$IFDEF RTTIREG}
    if ABase^.BaseProps.Focused and CWILLDESTROY = CWILLDESTROY then
      DynTFTComponent_DestroyFromReg(ABase);
  {$ENDIF}  
end;


procedure DynTFTProcessComponentVisualState(ScreenIndex: Byte);
var
  ParentComponent: PDynTFTComponent;
begin
  ParentComponent := DynTFTAllComponentsContainer[ScreenIndex].ScreenContainer;
  ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));

  if ParentComponent = nil then
    Exit;

  repeat
    SetComponentVisualState(PDynTFTBaseComponent(TPtrRec(ParentComponent^.BaseComponent)));
          
    ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));
  until ParentComponent = nil;
end;


procedure DynTFTBlinkCaretsForScreenComponents(ScreenIndex: Byte);
var
  ParentComponent: PDynTFTComponent;
  ABase: PDynTFTBaseComponent;
begin
  ParentComponent := DynTFTAllComponentsContainer[ScreenIndex].ScreenContainer;
  ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));

  if ParentComponent = nil then
    Exit;

  repeat
    ABase := PDynTFTBaseComponent(TPtrRec(ParentComponent^.BaseComponent));
    if ABase^.BaseProps.Visible = CVISIBLE then
      if ABase^.BaseProps.Focused and CFOCUSED = CFOCUSED then
        OnDynTFTBaseInternalBlinkCaretState(ABase);
          
    ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));
  until ParentComponent = nil;
end;


procedure DynTFTRepaintScreenComponents(ScreenIndex: Byte; PaintOptions: TPtr; ComponentAreaOnly: PDynTFTBaseComponent);
var
  ParentComponent: PDynTFTComponent;
  ABase: PDynTFTBaseComponent;
begin
  {$IFDEF IsDesktop}
    if DynTFTAllComponentsContainer[ScreenIndex].ScreenContainer = nil then
    begin
      DynTFT_DebugConsole('DynTFT is not initialized. Make sure the simulation is running. It should have called DynTFT_GUI_Start on start.');
      Exit;
    end;
  {$ENDIF}

  ParentComponent := DynTFTAllComponentsContainer[ScreenIndex].ScreenContainer;
  ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));

  if ParentComponent = nil then
    Exit;

  repeat
    ABase := PDynTFTBaseComponent(TPtrRec(ParentComponent^.BaseComponent));
    if ABase^.BaseProps.Visible = CVISIBLE then
    begin
      if ComponentAreaOnly = nil then
        OnDynTFTBaseInternalRepaint(ABase, True, PaintOptions, nil)
      else
        if ComponentOverlapsComponent(ABase, ComponentAreaOnly) then
          if ABase <> ComponentAreaOnly then
            OnDynTFTBaseInternalRepaint(ABase, True, PaintOptions, nil);
    end;

    SetComponentVisualState(ABase);  
    ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));
  until ParentComponent = nil;                                                         
end;


procedure DynTFTRepaintScreen(ScreenIndex: Byte; PaintOptions: TPtr; ComponentAreaOnly: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if DynTFTAllComponentsContainer[ScreenIndex].ScreenContainer = nil then
    begin
      DynTFT_DebugConsole('DynTFT is not initialized. Make sure the simulation is running. It should have called DynTFT_GUI_Start on start.');
      Exit;
    end;
  {$ENDIF}

  DynTFT_Set_Pen(DynTFTAllComponentsContainer[ScreenIndex].ScreenColor, 1);
  DynTFT_Set_Brush(1, DynTFTAllComponentsContainer[ScreenIndex].ScreenColor, 0, 0, 0, 0);

  DynTFT_Rectangle(0, 0, TFT_DISP_WIDTH, TFT_DISP_HEIGHT);
  DynTFTRepaintScreenComponents(ScreenIndex, PaintOptions, ComponentAreaOnly);
end;


procedure DynTFTRepaintScreenComponentsFromArea(ComponentFromArea: PDynTFTBaseComponent);
begin
  DynTFTClearComponentAreaWithScreenColor(ComponentFromArea);
  DynTFTRepaintScreenComponents(ComponentFromArea^.BaseProps.ScreenIndex, CNORMALREPAINT, ComponentFromArea);
end;


function DynTFTPositiveLimit(ANumber: LongInt): LongInt;
begin
  if ANumber < 0 then
    Result := 0
  else
    Result := ANumber;
end;


function DynTFTOrdBoolWord(ABool: Boolean): Word;
begin
  if ABool then
    Result := 1
  else
    Result := 0;
end;


procedure DynTFTChangeComponentPosition(AComp: PDynTFTBaseComponent; NewLeft, NewTop: TSInt);
begin
  DynTFTClearComponentAreaWithScreenColor(AComp);
  AComp^.BaseProps.Left := NewLeft;
  AComp^.BaseProps.Top := NewTop;
  //DynTFTRepaintScreenComponentsFromArea(AComp);
  OnDynTFTBaseInternalRepaint(AComp, True, CNORMALREPAINT, nil);
end;


{$IFDEF IsDesktop}
var
  iii: Integer;
begin
  for iii := 0 to CDynTFTMaxComponentsContainer - 1 do
    DynTFTAllComponentsContainer[iii].ScreenContainer := nil;
{$ENDIF}

end.
