#include <FileConstants.au3>
#include <File.au3>

Local $aFileList = _FileListToArray(@WorkingDir, "*.psd", $FLTA_FILES, False)
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
   ConsoleWrite("filename:"&$fileName)
   Export($fileName)
Next

Func Export($fileName)
   $app = ObjCreate("Photoshop.Application")
   $doc=$app.open(@WorkingDir& "\" &$fileName&".psd")

   SaveAs($doc,@WorkingDir& "\" &$filename&".jpg")

   $doc.close(2)
EndFunc

Func SaveAs($doc,$path)
   Dim $ObjSaveOptions=ObjCreate("Photoshop.JPEGSaveOptions")
   ;if @error Then Exit
   With $ObjSaveOptions
	.EmbedColorProfile = True
	.FormatOptions = 1
	.Matte = 1
	.Quality = 12
   EndWith
   ConsoleWrite($path&@CRLF)
   $doc.SaveAS($path,$ObjSaveOptions,True,2)
EndFunc