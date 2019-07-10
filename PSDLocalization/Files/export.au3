#include <FileConstants.au3>
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

Dim $text=""
Dim $textForNonTextItem=""
For $i=1 to $aFileList[0]
   $psdName=$aFileList[$i]
   $fileName=StringReplace($psdName,".psd","",-1, $STR_NOCASESENSE)
   ConsoleWrite("filename"&$fileName)
   $text=""
   $textForNonTextItem=""
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
   ;Local $nFileOpen = FileOpen($fileName&"-NonText.txt", $FO_OVERWRITE)
  ; If $nFileOpen = -1 Then
	;  MsgBox($MB_SYSTEMMODAL, "", "An error occurred when reading the file.")
	;  Return False
   ;EndIf

   $LayerSets=$doc.LayerSets
   $ArtLayers=$doc.ArtLayers
   handleLayerSets($LayerSets)
   handleArtLayers($ArtLayers)
   FileWrite($hFileOpen, $text)
   ;FileWrite($nFileOpen, $textForNonTextItem)
   FileClose($hFileOpen)
   ;FileClose($nFileOpen)
   $doc.close()
EndFunc

Func handleLayerSets($LayerSets)
   For $i=1 to $LayerSets.Count
	  $LayerSet=$LayerSets.Item($i)
	  handleArtLayers($LayerSet.ArtLayers)
	  handleLayerSets($LayerSet.LayerSets)
   Next
EndFunc


Func handleArtLayers($ArtLayers)
   For $i=$ArtLayers.Count to 1 Step -1
	  $artLayer=$ArtLayers.Item($i)
	  Dim $content = $artLayer.name
	  ;$content=StringReplace($content," ","")
	  ConsoleWrite($content& @CRLF)
	  if $artLayer.Kind=2 Then
		 $content=$artLayer.textItem.Contents
		 $content=StringRegExpReplace($content,"\r\n"," ")
		 $content=StringRegExpReplace($content,"\r"," ")
	     $content=StringRegExpReplace($content,"\n"," ")
		;ConsoleWrite("name:" & $artLayer.name & @CRLF)
		 $text=$text & $content & @CRLF ;& $Layer.name & @TAB
	  Else
	;	 $textForNonTextItem=$textForNonTextItem & $content & @CRLF
		 $text=$text & $content & @TAB & "non-text" & @CRLF
	  EndIf
   Next
EndFunc

