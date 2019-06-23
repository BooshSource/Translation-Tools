#include <FileConstants.au3>
#include <Array.au3>
#include <File.au3>

Local $aFileList = _FileListToArray(@WorkingDir, "*.psd", $FLTA_FILES, True)
If @error = 1 Then
  MsgBox($MB_SYSTEMMODAL, "", "Path was invalid.")
  Exit
EndIf
If @error = 4 Then
  MsgBox($MB_SYSTEMMODAL, "", "No file(s) were found.")
  Exit
EndIf

For $i=1 to $aFileList[0]
   $psdName=$aFileList[$i]
   $fileName=StringReplace($psdName,".psd","",-1, $STR_NOCASESENSE)
   ConsoleWrite("filename"&$fileName)
   Export($fileName)
Next

Func Export($fileName)
   $app = ObjCreate("Photoshop.Application")
   $doc=$app.open($fileName&".psd")
   Local $hFileOpen = FileOpen($fileName&".txt", $FO_OVERWRITE)
   If $hFileOpen = -1 Then
	  MsgBox($MB_SYSTEMMODAL, "", "An error occurred when reading the file.")
	  Return False
   EndIf

   $Layers=$doc.Layers

   For $i=1 to $Layers.Count
	   $Layer=$Layers.Item($i)
	   if $Layer.Kind=2 Then
		  ConsoleWrite($Layer.textItem.Contents)
		  ConsoleWrite($Layer.name)
		  FileWrite($hFileOpen, $Layer.name & @TAB & $Layer.textItem.Contents & @CRLF)
	   EndIf
	Next

   FileClose($hFileOpen)
   $doc.close()
EndFunc



