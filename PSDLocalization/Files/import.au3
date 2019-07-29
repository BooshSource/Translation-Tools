 #include <FileConstants.au3>
 #include <File.au3>

Global $FontSize = 6
Global $TextItemWidth = 50
Global $TextItemHeight = 50
Global $Language = 1

if FileExists(@WorkingDir&"\config.ini")=0 Then
   IniWrite(@WorkingDir&"\config.ini", "General", "FontSize", "6")
   IniWrite(@WorkingDir&"\config.ini", "General", "TextItemWidth", "50")
   IniWrite(@WorkingDir&"\config.ini", "General", "TextItemHeight", "50")
   IniWrite(@WorkingDir&"\config.ini", "General", "Language", "1")
Else
   $FontSize = IniRead (@WorkingDir&"\config.ini", "General", "FontSize", 6 )
   $TextItemWidth = IniRead (@WorkingDir&"\config.ini", "General", "TextItemWidth", 50 )
   $TextItemHeight = IniRead (@WorkingDir&"\config.ini", "General", "TextItemHeight", 50 )
   $Language = IniRead (@WorkingDir&"\config.ini", "General", "Language", 1 )
Endif


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
   $layerName=$items[1]
   $text=$items[2]
   ConsoleWrite($layerName & @CRLF)
   ConsoleWrite($text & @CRLF)
   if $layerName<>"" Then
	  if $oDictionary.Exists($layerName) Then
	  	  ConsoleWrite("already added!")
	  Else
	      $oDictionary.Add($layerName, $text)
	  EndIf
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
	  $layerName=$ArtLayer.name
	  ;$source=StringReplace($source," ","")
	  Dim $bounds[4]
	  $bounds=$ArtLayer.Bounds
	  ;ConsoleWrite($bounds[0] & @CRLF) ;x
	  ;ConsoleWrite($bounds[1] & @CRLF) ;y
	  ;ConsoleWrite($bounds[2] & @CRLF) ;width
	  ;ConsoleWrite($bounds[3] & @CRLF) ;height
	  Dim $position[2] ; two values
	  $position[0]=$bounds[0]
	  $position[1]=$bounds[1]
	  ConsoleWrite($layerName)
	  if $oDictionary.Exists($layerName) Then
		 ConsoleWrite("exists"  & @CRLF)
		 if $oDictionary.Item($layerName)<>$layerName Then
			if $ArtLayer.Kind=1  Then
			   $ArtLayer.clear()
			   $ArtLayer.Kind = 2
			   $ArtLayer.textItem.Position=$position
			   $ArtLayer.textItem.Kind=2 ;paragraph
			   $ArtLayer.textItem.Width=int($TextItemWidth)
               $ArtLayer.textItem.Height=int($TextItemHeight)
			Else
			   $ArtLayer.textItem.Kind=2 ;paragraph
			EndIf
			$ArtLayer.textItem.Contents = $oDictionary.Item($layerName)
			if $font="" Then
			   $ArtLayer.textItem.Font= "NotoSansHans-Regular"
			Else
			   $ArtLayer.textItem.Font= $font
			EndIf
			$ArtLayer.textItem.Justification=2 ;center
			$ArtLayer.textItem.Capitalization=2 ;capcase
			$ArtLayer.textItem.Language= int($Language)
			$ArtLayer.textItem.Hyphenation= True
		 EndIf
	  Else
		 ConsoleWrite("not exists"  & @CRLF)
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