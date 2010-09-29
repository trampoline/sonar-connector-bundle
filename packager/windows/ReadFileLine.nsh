Function ReadFileLine
Exch $0 ;file
Exch
Exch $1 ;line number
Push $2
Push $3
 
  FileOpen $2 $0 r
 StrCpy $3 0
 
Loop:
 IntOp $3 $3 + 1
  ClearErrors
  FileRead $2 $0
  IfErrors +2
 StrCmp $3 $1 0 loop
  FileClose $2
 
Pop $3
Pop $2
Pop $1
Exch $0
FunctionEnd