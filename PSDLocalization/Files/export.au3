#include <FileConstants.au3>
#include <File.au3>

Local $hFileOpen = FileOpen(@WorkingDir&"\out.txt", $FO_READ)
If $hFileOpen = -1 Then
   MsgBox($MB_SYSTEMMODAL, "", "An error occurred when reading the file(out.txt does not exist).")
   Return False
EndIf

Dim $text=""
Dim $textForNonTextItem=""
Dim $res

While True
   $psdName=FileReadLine($hFileOpen)
   if @error Then ExitLoop
   ConsoleWrite($psdName & @CRLF)
   $fileName=StringReplace($psdName,".psd","",-1, $STR_NOCASESENSE)
   ConsoleWrite("filename: " & $fileName & @CRLF)
   $text=""
   $textForNonTextItem=""
   Export($fileName)
WEnd

Func Export($fileName)
   $app = ObjCreate("Photoshop.Application")
   $doc = $app.open(@WorkingDir & "\" & $fileName&".psd")
   $res = $doc.Resolution
   Local $hFileOpen = FileOpen(@WorkingDir & "\" & $fileName&".txt", $FO_OVERWRITE)
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
	  ;$content=StringReplace($content," ","")
	  ConsoleWrite($artLayer.name & @CRLF)
	  Dim $bounds[4]
	  $bounds=$ArtLayer.Bounds
	  Dim $X,$Y,$width,$height
	  $X=$bounds[0]
	  $Y=$bounds[1]
	  $width=$bounds[2]
	  $height=$bounds[3]
	  if $artLayer.Kind=2 Then
		 $content=$artLayer.textItem.Contents
		 $content=StringRegExpReplace($content,"\r\n"," ")
		 $content=StringRegExpReplace($content,"\r"," ")
	     $content=StringRegExpReplace($content,"\n"," ")
		 Dim $scale
		 $scale=$res/72
         $width=$artLayer.textItem.Width*$scale*$scale
		 $height=$artLayer.textItem.Height*$scale*$scale
		;ConsoleWrite("name:" & $artLayer.name & @CRLF)
		 $text=$text & $X & @TAB & $Y  & @TAB & $width & @TAB & $height & @TAB & $artLayer.name & @TAB & $content & @CRLF
	  Else
	;	 $textForNonTextItem=$textForNonTextItem & $content & @CRLF
		 $text=$text & $X & @TAB & $Y  & @TAB & $width & @TAB & $height & @TAB & $artLayer.name & @TAB & "non-text" & @CRLF
	  EndIf
   Next
EndFunc

