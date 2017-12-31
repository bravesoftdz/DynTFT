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

unit DynTFTSmallMM;

//This is a simple memory manager, which does not free memory. It is used only for allocation (where only static structures are needed).

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}

  {$IFNDEF AppArch32}
    {$DEFINE AppArch32}
  {$ENDIF}

{$ELSE}
  {$IFDEF AppArch32}     //IsMCU
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

uses
  DynTFTTypes;

{$IFDEF IsDesktop}  
  type
    DWord = Cardinal;
{$ENDIF}

const
  //MaxMM = 12000;
  //MaxMM = 16384;
  //MaxMM = 16450;
  //MaxMM = 17000;
  MaxMM = 20000;
  //MaxMM = 500000;

procedure MM_Init;
procedure GetMem(var APointer: TPtrRec; Size: DWord);
function MM_TotalFreeMemSize: DWord;

implementation

var
  mm: array[0..MaxMM - 1] of Byte;   {$IFDEF IsMCU} volatile; absolute {$IFDEF AppArch16} $00001600; {$ELSE} $A0000FDC; {$ENDIF}{$ENDIF} //must be aligned to a 4-byte boundary on 32-bit and 2-byte boundary on 16-bit
  MemLevelPointer: DWord; {$IFDEF IsMCU} volatile; {$ENDIF} //total allocated memory size


procedure MM_Init;
var
  i: DWord;
begin
  MemLevelPointer := 0;
  for i := 0 to MaxMM - 1 do
    mm[i] := 0; //initialize memory
end;


procedure GetMem(var APointer: TPtrRec; Size: DWord);
begin
  APointer := TPtrRec(@mm[MemLevelPointer]);
  MemLevelPointer := MemLevelPointer + Size;
end;


function MM_TotalFreeMemSize: DWord;
begin
  Result := MaxMM - MemLevelPointer;
end;

end.