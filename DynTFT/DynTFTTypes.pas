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
    
unit DynTFTTypes;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}

  {$IFNDEF AppArch32}
    {$DEFINE AppArch32}
  {$ENDIF}

{$ELSE}
  {$IFDEF AppArch32}     //PIC32
    {$UNDEF AppArch32}
  {$ENDIF}
  
  {$IFDEF AppArch16}     //dsPIC / PIC24
    {$UNDEF AppArch16}
  {$ENDIF}

  {$IFDEF P30}
    {$DEFINE AppArch16}
  {$ENDIF}

  {$IFDEF P33}
    {$DEFINE AppArch16}
  {$ENDIF}

  {$IFDEF P24}
    {$DEFINE AppArch16}
  {$ENDIF}

  {$IFNDEF AppArch16}    //16-bit not defined,
    {$DEFINE AppArch32}  //then it must be 32-bit !
  {$ENDIF}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

{$IFDEF CustomUserDataTypes}
  {$I CustomUserDataTypes.inc}
{$ENDIF}

type
  {$IFDEF IsDesktop}
    TColor = -$7FFFFFFF-1..$7FFFFFFF;
    DWord = Cardinal;
  {$ELSE}
    TColor = LongInt;    //use 32-bit signed for mikroPascal. Do not change it to 16-bit word!!!
  {$ENDIF}

const

//array limits
  {$IFDEF UseExternalLimits}                 //see description on the $ELSE case
    CDynTFTMaxGenericStringLength: Word; external;

    CDynTFTMaxComponentsContainer: Byte; external;

    CDynTFTMaxRegisteredComponentTypes: Byte; external;
  {$ELSE}
    CDynTFTMaxGenericStringLength = 19;  //must be longer enough to hold captions. Components which need to store longer strings may define their own constants (see PDynTFTEdit.Text).

    CDynTFTMaxComponentsContainer = 21;   //maximum number of screens

    //component types (when all pointers are of PPtrRec type, there should be a way to keep the component type
    CDynTFTMaxRegisteredComponentTypes = 21; //Maximum numbers of components types, which are handled by the internal event handlers. Increase this number if you add many component types to your application.
  {$ENDIF}

type
  TDynTFTCompStr = string[CDynTFTMaxGenericStringLength];  //generic text
  PDynTFTCompStr = ^TDynTFTCompStr;

  {$IFDEF IsDesktop}
    TSInt = Smallint;
  {$ELSE}
    TSInt = Integer;  //This must be a 16-bit type on any microcontroller.
  {$ENDIF}


  {$IFDEF IsDesktop}
    TPtr = DWord;
    TIntPtr = LongInt;
  {$ELSE}
    {$IFDEF AppArch32}
      TPtr = DWord;
      TIntPtr = LongInt;
    {$ELSE}
      {$IFDEF AppArch16}
        TPtr = Word;
        TIntPtr = Integer;
      {$ELSE}
        TPtr = DWord; //defaults to DWord
        TIntPtr = LongInt;
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}

  PPtr = ^TPtr;

  TPtrRec = TPtr;     //TPtrRec used to be a record (that is where its name comes from). It is better to be a simple type.
  PPtrRec = ^TPtrRec;
  
  TDynTFTComponentType = TIntPtr; //Word or DWord for alignment

  TDynTFTOnMouseEvent = procedure(Sender: PPtrRec);
  PDynTFTOnMouseEvent = ^TDynTFTOnMouseEvent;

  TDynTFTGraphicUpdate = procedure(Sender: PPtrRec);
  PDynTFTGraphicUpdate = ^TDynTFTGraphicUpdate;


  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  //Make sure the size of the following structures is a multiple of pointer size!
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                          {
  TDynTFTBasePropertiesCompType = record    //like base class for Component Type
    ComponentType: TDynTFTComponentType;
  end;
                           }
  //  =============================

  
  //generic component: TDynTFTComponent
  TDynTFTComponent = record
    BaseComponent: PPtrRec;         //PPtrRec is the basic 4-byte pointer on a 32-bit architecture    BaseComponent points to a button, a panel, a checkbox etc
    NextSibling: PPtrRec;    //PDynTFTComponent
  end;
  PDynTFTComponent = ^TDynTFTComponent;

  //  =============================


  TDynTFTLimitedBaseProperties = record    //like base class
    ComponentType: TDynTFTComponentType; //this field should exist in every component (button, checkbox etc). It should have the same type and should be always the first field in the structure
    ScreenIndex: TPtr;
    
    Left, Top, Width, Height: TSInt;  //this should also be 16-bit on IsMCU
  end;
  PDynTFTLimitedBaseProperties = ^TDynTFTLimitedBaseProperties;

    
  //  =============================


  TDynTFTBaseProperties = record    //like base class  -  all visual components should contain this
    ComponentType: TDynTFTComponentType; //this field should exist in every component (button, checkbox etc). It should have the same type and should be always the first field in the structure
    ScreenIndex: TPtr;
    
    Left, Top, Width, Height: TSInt;  //this should also be 16-bit on PIC32
    Enabled, Visible, Focused, CompState: Byte;   //bit 0 of Focused is used as the actual "Focused" state, and bit 1 is used to mark an already painted operation
    Parent: PPtrRec;  //used for event handlers  /  graphical ownership
    CanHandleMessages: {$IFDEF IsDesktop} LongBool; {$ELSE} Boolean; {$ENDIF}

    OnMouseDownUser: PDynTFTOnMouseEvent;
    OnMouseMoveUser: PDynTFTOnMouseEvent;
    OnMouseUpUser: PDynTFTOnMouseEvent;
    //Please update InitBaseHandlersAndProperties and FreeBaseHandlersAndProperties from DynTFTBaseDrawing, if adding pointers (like events)

    {$IFDEF ComponentsHaveName}
      Name: PCompStr;
    {$ENDIF}
    
    {$IFDEF IncludeUserBaseProps}
      {$I UserBaseProps.inc}
    {$ENDIF}
  end;
  PDynTFTBaseProperties = ^TDynTFTBaseProperties;

  //  =============================


  TDynTFTBaseComponent = record    //like base class
    BaseProps: TDynTFTBaseProperties;
  end;
  PDynTFTBaseComponent = ^TDynTFTBaseComponent;


  TDynTFTGenericEventHandler = procedure(ABase: PDynTFTBaseComponent);
  PDynTFTGenericEventHandler = ^TDynTFTGenericEventHandler;

  TDynTFTRepaintHandler = procedure(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
  PDynTFTRepaintHandler = ^TDynTFTRepaintHandler;

  TDynTFTCreateHandler = function(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
  PDynTFTCreateHandler = ^TDynTFTCreateHandler;

  TDynTFTDestroyHandler = procedure(var ABaseComp: PDynTFTBaseComponent);
  PDynTFTDestroyHandler = ^TDynTFTDestroyHandler;

  //These events allow internal handlers to call dedicated registered handlers. 
  TDynTFTBaseEventReg = record
    MouseDownEvent: PDynTFTGenericEventHandler;
    MouseMoveEvent: PDynTFTGenericEventHandler;
    MouseUpEvent: PDynTFTGenericEventHandler;
    Repaint: PDynTFTRepaintHandler;
    BlinkCaretState: PDynTFTGenericEventHandler;

    {$IFDEF RTTIREG}
      CompSize: TPtr;
      CompCreate: PDynTFTCreateHandler;
      CompDestroy: PDynTFTDestroyHandler;
    {$ENDIF}

    //when adding events, please update SetComponentTypeInRegistry function and AllocateInternalHandlers, DisposeInternalHandlers, InitComponentTypeRegistration and RegisterComponentContainerEvents procedures.
    //also, make sure all components, which use these handlers, implement them properly
  end;
  PDynTFTBaseEventReg = ^TDynTFTBaseEventReg;


  TDynTFTScreenComponentInfo = record
    ScreenContainer: PDynTFTComponent;  //Points to the first item of a simple linked list
    //component fields
    PressedComponent: PDynTFTBaseComponent;       //Last pressed component (used to clear focus)
    ScreenColor: TColor;   //used when repainting under a destroyed or hidden component

    {$IFDEF IsDesktop}
      SomeButtonDownScr: LongBool;
      Active: LongBool;
    {$ELSE}
      SomeButtonDownScr: Boolean;
      Active: Boolean;
    {$ENDIF}
  end;
  //PDynTFTScreenComponentInfo = ^TDynTFTScreenComponentInfo;

  TDynTFTComponentsContainer = array[0..CDynTFTMaxComponentsContainer - 1] of TDynTFTScreenComponentInfo;  //this array keeps all components in simple linked lists (one list / screen)
  

implementation

end.
