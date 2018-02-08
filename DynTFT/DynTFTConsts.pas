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

unit DynTFTConsts;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface

uses
  Graphics;
{$ENDIF}

const
  {$IFDEF IsDesktop}
    CL_WHITE = clWhite;
    CL_BLACK = clBlack;
    CL_AQUA = clAqua;
    CL_GREEN = clGreen;
    CL_NAVY = clNavy;
    CL_LIME = clLime;
    CL_MAROON = clMaroon;
    CL_BLUE = clBlue;
    CL_SILVER = clSilver;
    CL_GRAY = clGray;
    CL_MEDGRAY = clMedGray;
    CL_RED = clRed;
    CL_YELLOW = clYellow;
    CL_FUCHSIA = clFuchsia;
    CL_PURPLE = clPurple;
    CL_OLIVE = clOlive;
    CL_TEAL = clTeal;

    CL_LIGHTGRAY = $00F0F0F0;
    CL_LIGHTBLUE = $00FFEFEF;
    CL_DARKGRAY = $00404040;

    CL_HIGHLIGHT = $00FF9933;

    FO_HORIZONTAL = 0;
    FO_VERTICAL = 1;
  {$ELSE}
    {CL_WHITE = $FFFF;
    CL_BLACK = $0000;
    CL_AQUA = $07FF;
    CL_GREEN = $0400;
    CL_LIME = $07E0;
    CL_MAROON = $8000;
    CL_BLUE = $001F;
    CL_SILVER = $C618;
    CL_GRAY = $8410;
    CL_RED = $F800;
    CL_YELLOW = $FFE0;
    CL_FUCHSIA = $F81F; }

    CL_LIGHTGRAY = $F79E;
    CL_LIGHTBLUE = $EF7F;
    CL_DARKGRAY = $0841;
    CL_MEDGRAY = $A514;

    CL_HIGHLIGHT = $34DF;
  {$ENDIF}


  //{$IFDEF IncludeUserColors}
    {$I UserColors.inc}
  //{$ENDIF}

  {$IFNDEF ExcludeDynTFTSysColors}
    //Replace the content of DynTFTColorTheme.inc file with your color theme.
    {$I DynTFTColorTheme.inc}
  {$ENDIF}

const                                             
  //constants from Windows unit (Delphi)
  VK_BACK = 8;     //backspace
  VK_TAB = 9;
  VK_RETURN = 13;
  VK_SHIFT = $10;
  VK_CONTROL = 17;
  VK_MENU = 18;    //alt
  VK_CAPITAL = 20; //caps
  VK_ESCAPE = 27;
  VK_SPACE = $20;

  VK_PRIOR = 33;   //page up
  VK_NEXT = 34;    //page down
  VK_END = 35;
  VK_HOME = 36;

  VK_LEFT = 37;
  VK_UP = 38;
  VK_RIGHT = 39;
  VK_DOWN = 40;

  VK_INSERT = 45;
  VK_DELETE = 46;

  VK_APPS = 93; //pop-up menu

implementation

end.
