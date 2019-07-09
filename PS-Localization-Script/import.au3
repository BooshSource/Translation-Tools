 #include <FileConstants.au3>
 #include <File.au3>

Local $oDictionary
$oDictionary = ObjCreate("Scripting.Dictionary")

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


Local $hFileOpen = FileOpen("翻译记忆.txt", $FO_READ)
If $hFileOpen = -1 Then
   MsgBox($MB_SYSTEMMODAL, "", "An error occurred when reading the file.")
   Return False
EndIf

While True
   $line=FileReadLine($hFileOpen)
   if @error Then ExitLoop
   $items=StringSplit($line,"	")
   $source=$items[1]
   $text=$items[2]
   if $source<>"" Then
	  $oDictionary.Add($source, $text)
   EndIf
WEnd

FileClose($hFileOpen)


 For $i=1 to $aFileList[0]
    $psdName=$aFileList[$i]
    $fileName=StringReplace($psdName,".psd","",-1, $STR_NOCASESENSE)
    ConsoleWrite("filename"&$fileName)
    ;$txtName=$fileName&".txt"
    ;if FileExists($txtName) Then
    ;    ConsoleWrite($txtName)
        Import($fileName)
    ;EndIf
 Next



 Func Import($fileName)
   $app = ObjCreate("Photoshop.Application")
   $doc = $app.open($fileName&".psd")


   $LayerSets=$doc.LayerSets
   $ArtLayers=$doc.ArtLayers
   handleLayerSets($LayerSets)
   handleArtLayers($ArtLayers)


   ;$doc.Save()
   ;SaveAs($doc,$filename)
   ;$doc.close()
EndFunc

Func handleLayerSets($LayerSets)
   For $i=1 to $LayerSets.Count
	  $LayerSet=$LayerSets.Item($i)
	  handleArtLayers($LayerSet.ArtLayers)
	  handleLayerSets($LayerSet.LayerSets)
   Next
EndFunc

Func handleArtLayers($ArtLayers)
   ConsoleWrite("handling")
   For $i=1 to $ArtLayers.Count
	  $ArtLayer=$ArtLayers.Item($i)
	  $source=$ArtLayer.name
	  $source=StringRegExpReplace($source,"\r","<r/>")
	  $source=StringRegExpReplace($source,"\n","<n/>")
	  ;$source=StringReplace($source," ","")
	  Dim $bounds[4]
	  $bounds=$ArtLayer.Bounds
	  ConsoleWrite($bounds[0] & @CRLF) ;x
	  ConsoleWrite($bounds[1] & @CRLF) ;y
	  ConsoleWrite($bounds[2] & @CRLF) ;width
	  ConsoleWrite($bounds[3] & @CRLF) ;height
	  Dim $position[2] ; two values
	  $position[0]=$bounds[0]
	  $position[1]=$bounds[1]
	  if $oDictionary.Exists($source) Then
		 ConsoleWrite("exists")
		 if $oDictionary.Item($source)<>$source Then
			if $ArtLayer.Kind=1  Then
			   $ArtLayer.clear()
			   $ArtLayer.Kind = 2
			   $ArtLayer.textItem.Position=$position
			EndIf
			$ArtLayer.textItem.Kind=2 ;paragraph
			$ArtLayer.textItem.Contents = $oDictionary.Item($source)
			if $font="" Then
			   $ArtLayer.textItem.Font= "NotoSansHans-Regular"
			Else
			   $ArtLayer.textItem.Font= $font
			EndIf
			$ArtLayer.textItem.Justification=2 ;center
			$ArtLayer.textItem.Capitalization=2 ;capcase
		 EndIf
	  Endif
   Next
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