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

   Local $iFileExists = FileExists(@WorkingDir& "\成品")
   if $iFileExists=0 Then
	  DirCreate(@WorkingDir& "\成品")
   EndIf

   Local $jileExists = FileExists(@WorkingDir& "\无文字")
   if $iFileExists=0 Then
	  DirCreate(@WorkingDir& "\无文字")
   EndIf

   SaveAs($doc,@WorkingDir&"\成品\"&$filename&".jpg")
   $LayerSets=$doc.LayerSets
   $ArtLayers=$doc.ArtLayers
   handleLayerSets($LayerSets)
   handleArtLayers($ArtLayers)
   SaveAs($doc,@WorkingDir&"\无文字\"&$filename&".jpg")
   $doc.close(2)
EndFunc

Func handleLayerSets($LayerSets)
   For $i=1 to $LayerSets.Count
	  $LayerSet=$LayerSets.Item($i)
	  handleArtLayers($LayerSet.ArtLayers)
	  handleLayerSets($LayerSet.LayerSets)
   Next
EndFunc


Func handleArtLayers($ArtLayers)
   For $i=1 to $ArtLayers.Count
	  $artLayer=$ArtLayers.Item($i)
	  if $artLayer.Kind=2 Then
		$artLayer.Visible=False
	  EndIf
   Next
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