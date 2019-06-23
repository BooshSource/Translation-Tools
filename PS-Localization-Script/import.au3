#include <FileConstants.au3>
#include <Array.au3>
#include <File.au3>

Local $fsFileOpen = FileOpen("font.txt", $FO_READ)
Local $font = ""
If $fsFileOpen <> -1 Then
   $font=FileRead($fsFileOpen)
EndIf

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
   $txtName=$fileName&".txt"
   if FileExists($txtName) Then
       ConsoleWrite($txtName)
	   Import($fileName)
   EndIf
Next

Func Import($fileName)
   $app = ObjCreate("Photoshop.Application")
   $doc = $app.open($fileName&".psd")
   Local $hFileOpen = FileOpen($fileName&".txt", $FO_READ)
   If $hFileOpen = -1 Then
	  MsgBox($MB_SYSTEMMODAL, "", "An error occurred when reading the file.")
	  Return False
   EndIf

   $line=FileReadLine($hFileOpen)
   $name=StringLeft($line, StringInStr($line,@TAB)-1)
   $text=StringRight($line, StringLen($line) - StringInStr($line,@TAB))
   ConsoleWrite($name)
   ConsoleWrite($text)

   $Layers=$doc.Layers

   For $i=1 to $Layers.Count
	  $Layer=$Layers.Item($i)
	  if $Layer.Kind=2 and $Layer.Name=$name Then
		 $Layer.textItem.Contents= $text
		 if $font<>"" Then
			$Layer.textItem.Font= $font
		 EndIf
		 FileWrite($hFileOpen, $Layer.name & @TAB & $Layer.textItem.Contents & @CRLF)
	  EndIf
   Next

   FileClose($hFileOpen)
   $doc.Save()
   SaveAs($doc,$filename)
   $doc.close()
EndFunc

Func SaveAs($doc,$filename)
   Dim $ObjSaveOptions=ObjCreate("Photoshop.JPEGSaveOptions")
   ;if @error Then Exit
   With $ObjSaveOptions
	  .EmbedColorProfile = True
	  .FormatOptions = 1
	  .Matte = 1
	  .Quality = 1
   EndWith
   Dim $path
   $path=$filename&".jpg"
   ConsoleWrite($path&@CRLF)
   $doc.SaveAS($path,$ObjSaveOptions,True,2)
EndFunc

