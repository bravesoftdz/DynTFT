{*
 * File         : __Lib_MemManager.mpas
 * Project      : Memory manager library
 * Revision History:
     20110317:
       - initial release;
 * Author       : D. Rosseel, modified by mikroElektronika
 * Description  :
 *      Memory manager Library  provides routines for manipulating dynamic
 *      memory allocation.
 *}

unit MemManager;

interface

uses
  DynTFTTypes;

type
  dword = Cardinal;

//const HEAP_START  : dword; external;   //defined later as variable
const HEAP_SIZE = 20000;

procedure MM_Init();
// Initializes the memory manager.
// TotalMemSize = the total ram size (bytes) of the PIC in use, see its datasheet.
// HeapSize = the amount of Ram (bytes) that can be used by the memory manager (= the "heap"),
//   should be always less than "Free RAM(bytes)" value after compilation !!!

procedure GetMem(var P: TPtrRec; Size: dword);
procedure GetMemAlign(var P: TPtrRec; Size: dword; alignment: byte);
function  Malloc(Size: dword): TPtrRec;  // C-like version
// Fetches memory from the memory heap.
// Returns a pointer (> 0) to the fetched memory (of "Size" bytes) in P if success,
//   otherwise 0 (no free blocks of memory are large enough...). This is not a fatal error,
//   there is only not enough memory at the moment. The memmanager stays operational.
// P is a variable of any pointer type.
// "Size" is an expression specifying the size in bytes of the dynamic variable to allocate.
// Access the newly allocated memory by dereferencing the pointer; that is, use P^.

procedure FreeMem(var P: TPtrRec; Size: dword);
procedure Free(var P: TPtrRec; Size: dword); // C-like version
// FreeMem destroys the variable referenced by P and returns its memory to the heap.
// P is a variable of any pointer type previously assigned by the GetMem procedure.
// "Size" specifies the size in bytes of the dynamic variable to dispose of,
//   and should be the same as the one used to "GetMem".
// After calling FreeMem, the value of P is nil (0) (not assigned pointer).

function MM_LargestFreeMemBlock(): dword;
// Returns, after defragmentation of the freelist,
// the size (in bytes) of the largest free block of contiguous memory on the heap.

function MM_TotalFreeMemSize(): dword;
// Returns the size (in bytes) of the total free memory on the heap.

//sfunction MM_error: boolean;
// Returns true if the memory manager can not cope with the free list fragmentation (too many fragments).
// Either make constant "NR_FREE_BLOCKS" larger or pay attention to the memory release policy in your program.
// This is a fatal error, the memmanager is not operational anymore. To leave the error state call "MM_Init".

implementation

const NR_FREE_BLOCKS = 20;

Type TBytePtr = ^byte;

Type  TFreeMemBlock = record
        Pointer: TPtrRec;
        Size   : dword;
      end;

var   MM_FreeMemTable: array[0..NR_FREE_BLOCKS - 1] of TFreeMemBlock;
      MM_NrFreeBlocksUsed: byte;
      MM_PossiblyFragmented: boolean;
      MM_Error_: boolean;

      HEAP_START  : dword;
      mm: array[0..HEAP_SIZE - 1] of Byte;

procedure MM_Init();
var i: byte;
begin
  HEAP_START := TPtrRec(@mm);

  // 1 free block with the whole heap;
  MM_FreeMemTable[0].Size    := HEAP_SIZE;
  MM_FreeMemTable[0].Pointer := TPtrRec(TBytePtr(HEAP_START));

  // clear other blocks
  for i:=1 to NR_FREE_BLOCKS-1 do
    begin
      MM_FreeMemTable[i].Pointer := TPtrRec(TBytePtr(0));  // clear other table entries
      MM_FreeMemTable[i].Size    := 0;
    end;

  MM_NrFreeBlocksUsed := 1;
  MM_Error_ := FALSE;
  MM_PossiblyFragmented := FALSE;
end;

function MM_error: boolean;
begin
  Result := MM_Error_;
end;

function MM_CheckBlocks(P1: TPtrRec; S1: dword; P2: TPtrRec; S2: dword): dword;
begin
  Result := 0;      // default: no adjacent blocks
  if P1 = 0 then
    Exit;
  if P2 = 0 then
    Exit;
  if P1 = P2 then 
    Exit;

  if P1 + S1 = P2 then 
    Result := 1  // block P1 is adjacent beneath block P2
  else if P2 + S2 = P1 then
    Result := 2; // block P2 is adjacent beneath block P1
end;

procedure MM_Defragment;
var MergeHappened: boolean;
    i, j, tmp: byte;
begin
  Repeat
    MergeHappened := FALSE;
    i := 0;
    while (i < NR_FREE_BLOCKS-1) and (not MergeHappened) do
      begin
        j := i + 1;
        while (j < NR_FREE_BLOCKS) and (not MergeHappened) do
          begin
            tmp := MM_CheckBlocks(MM_FreeMemTable[i].Pointer, MM_FreeMemTable[i].Size, MM_FreeMemTable[j].Pointer, MM_FreeMemTable[j].Size);
            if tmp = 1 then
              begin // block MM_FreeMemTable[I].Pointer is adjacent beneath block MM_FreeMemTable[J].Pointer
                MM_FreeMemTable[i].Size    := MM_FreeMemTable[i].Size + MM_FreeMemTable[j].Size;
                MM_FreeMemTable[j].Pointer := TPtrRec(TBytePtr(0));
                MM_FreeMemTable[j].Size    := 0;
                MergeHappened := TRUE;
              end
            else if tmp = 2 then
              begin // block MM_FreeMemTable[I].Pointer is adjacent above block MM_FreeMemTable[J].Pointer
                MM_FreeMemTable[j].Size    := MM_FreeMemTable[j].Size + MM_FreeMemTable[i].Size;
                MM_FreeMemTable[i].Pointer := TPtrRec(TBytePtr(0));
                MM_FreeMemTable[i].Size    := 0;
                MergeHappened := TRUE;
              end;
            Inc(j);
          end;
        Inc(i);
      end;
  until not MergeHappened;

  // calculate current number of free blocks
  MM_NrFreeBlocksUsed := 0;

  for i:=0 to NR_FREE_BLOCKS-1 do
    if MM_FreeMemTable[i].Pointer > 0 then
      Inc(MM_NrFreeBlocksUsed);

  MM_PossiblyFragmented := FALSE;
end;

procedure GetMemAlign(var P: TPtrRec; Size: dword; alignment: byte);
var i: byte;
    j: Shortint;
    addr, lsize: dword;
    tryIt: boolean;
begin
  P := TPtrRec(TBytePtr(0)); // nil in case no large enough memory is available

  if MM_Error_ then 
    Exit;
    
  // first try to find suitable sized free block with coresponding alignment to reduce fragmentation
  for i:=0 to NR_FREE_BLOCKS-1 do
    begin
      tryIt := TRUE;
      if alignment > 1 then
        if dword(MM_FreeMemTable[i].Pointer) mod alignment <> 0 then
	  tryIt := FALSE;
	  
      if tryIt then
        if (MM_FreeMemTable[i].Pointer > 0) and (MM_FreeMemTable[i].Size >= Size) then
          begin // there is some free memory
            P := MM_FreeMemTable[i].Pointer; // pointer to memory block that will be given

            // adjust the FreeList
            if MM_FreeMemTable[i].Size > Size then
              begin
                MM_FreeMemTable[i].Pointer := MM_FreeMemTable[i].Pointer + Size;
                MM_FreeMemTable[i].Size    := MM_FreeMemTable[i].Size    - Size;
              end
            else
              begin // nothing remains of the free block, discard it
                MM_FreeMemTable[i].Pointer := TPtrRec(TBytePtr(0));
                MM_FreeMemTable[i].Size    := 0;
                Dec(MM_NrFreeBlocksUsed);
              end;

            Exit;
          end;
    end;
    
  // (0, 1) = practically no alignment, any address is valid,
  // -> we tried all blocks, space was not found
  if (alignment <= 1) then
    Exit;
    
  // now because of alignment
  // we'll have to split one block in two, so we'll need one empty slot
  // no empty slots -> exit
  if MM_NrFreeBlocksUsed = (NR_FREE_BLOCKS - 1) then
    Exit;

  j := -1;
  for i:=0 to NR_FREE_BLOCKS-1 do
    begin
      if (MM_FreeMemTable[i].Pointer > 0) then
	begin
          addr := MM_FreeMemTable[i].Pointer;
          lsize := Size;
          if alignment > 1 then
            while addr mod alignment <> 0 do
	      begin
    	        Inc(addr);
                Inc(lsize);
    	      end;
          if (MM_FreeMemTable[i].Size >= lsize) then
            begin // there is some free memory
              // find an emtpy slot if not already found
              if j = -1 then
		for j:=i+1 to NR_FREE_BLOCKS-1 do
                  if MM_FreeMemTable[j].Pointer = 0 then
		    break;
            
              // place the gap in empty slot
              MM_FreeMemTable[j].Pointer := MM_FreeMemTable[i].Pointer;
              MM_FreeMemTable[j].Size    := lsize - Size;
              Inc(MM_NrFreeBlocksUsed);
              
              P := addr; // pointer to memory block that will be given
              // adjust the FreeList
              if MM_FreeMemTable[i].Size > lsize then
                begin
                  MM_FreeMemTable[i].Pointer := MM_FreeMemTable[i].Pointer + lsize;
                  MM_FreeMemTable[i].Size    := MM_FreeMemTable[i].Size    - lsize;
                end
              else
                begin // nothing remains of the free block, discard it
                  MM_FreeMemTable[i].Pointer := TPtrRec(TBytePtr(0));
                  MM_FreeMemTable[i].Size    := 0;
                  Dec(MM_NrFreeBlocksUsed);
                end;

              Exit;
            end;
        end
      else
	begin
	  if j = -1 then
            j := i; // mark first empty slot
	end;
    end;
end;

procedure GetMem(var P: TPtrRec; Size: dword);
var alignment: byte;
begin
  alignment  := 1;
  if size >= 4 then
    alignment := 4
  else if size = 2 then
    alignment  := 2;

  GetMemAlign(P, Size, alignment);
  if (P = 0) and MM_PossiblyFragmented then // try again after defragmentation
    begin
      MM_Defragment();
      GetMemAlign(P, Size, alignment);
    end;
end;

function Malloc(Size: dword): TPtrRec;
var P: TPtrRec;
begin
  GetMem(P, Size);
  Result := P;
end;

procedure FreeMem(var P: TPtrRec; Size: dword);
var i, tmp: byte;
    MergeHappened: boolean;
begin
  if MM_Error_ then
    Exit;
    
  if P = 0 then
    Exit;

  // try to merge the block to free with an existing free block
  MergeHappened := FALSE;
  for i:=0 to NR_FREE_BLOCKS-1 do
    begin
      tmp := MM_CheckBlocks(P, Size, MM_FreeMemTable[i].Pointer, MM_FreeMemTable[i].Size);
      if tmp = 1 then
        begin // block P is adjacent beneath block MM_FreeMemTable[I].Pointer
          MM_FreeMemTable[i].Pointer := MM_FreeMemTable[i].Pointer - Size;
          MM_FreeMemTable[i].Size    := MM_FreeMemTable[i].Size    + Size;
          MergeHappened := TRUE;
          MM_PossiblyFragmented := TRUE;
          break;
        end
      else if tmp = 2 then
        begin // block P is adjacent above block MM_FreeMemTable[I].Pointer
          MM_FreeMemTable[i].Size := MM_FreeMemTable[i].Size + Size;
          MergeHappened := TRUE;
          MM_PossiblyFragmented := TRUE;
          break;
      end;
    end;

  if not MergeHappened then
    begin // entry could not be merged into the existing freelist, add entry to the freelist
      // find an empty FreeMemBlock
      for i:=0 to NR_FREE_BLOCKS-1 do
        if MM_FreeMemTable[i].Pointer = 0 then  // free entry in the MM_FreeMemTable found
          begin
            MM_FreeMemTable[i].Pointer := P;
            MM_FreeMemTable[i].Size    := Size;
            Inc(MM_NrFreeBlocksUsed);
            break;
          end;
          
      if i = NR_FREE_BLOCKS then
        begin
          // FreeTableOverflow
          MM_Error_ := TRUE;
          Exit;
        end;
    end;

  if MM_NrFreeBlocksUsed = (NR_FREE_BLOCKS - 1) then // free list is full, defragment the list (merge entries)
    MM_Defragment();

  P := TPtrRec(TBytePtr(0)); // P is nil now
end;

procedure Free(var P: TPtrRec; Size: dword);
begin
  FreeMem(P, Size);
end;

function MM_LargestFreeMemBlock(): dword;
var i: byte;
begin
  Result := 0;
  if MM_Error_ then
    Exit;

  // Defragment the freelist first if necessary
  if MM_PossiblyFragmented then 
    MM_Defragment();

  for i:=0 to NR_FREE_BLOCKS-1 do
    if MM_FreeMemTable[i].Size > Result then
      Result := MM_FreeMemTable[i].Size;
end;

function MM_TotalFreeMemSize(): dword;
var i: byte;
begin
  Result := 0;

  if MM_Error_ then
    Exit;

  // Calculate the total;
  for i:=0 to NR_FREE_BLOCKS-1 do
    Result := Result + MM_FreeMemTable[i].Size;
end;

end.