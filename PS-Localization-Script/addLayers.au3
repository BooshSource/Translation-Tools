 #include <FileConstants.au3>
 #include <File.au3>

Global $FontSize = 6
Global $TextItemWidth = 50
Global $TextItemHeight = 50

if FileExists(@WorkingDir&"\config.ini")=0 Then
   IniWrite(@WorkingDir&"\config.ini", "General", "FontSize", "6")
   IniWrite(@WorkingDir&"\config.ini", "General", "TextItemWidth", "50")
   IniWrite(@WorkingDir&"\config.ini", "General", "TextItemHeight", "50")
Else
   $FontSize = IniRead (@WorkingDir&"\config.ini", "General", "FontSize", 6 )
   $TextItemWidth = IniRead (@WorkingDir&"\config.ini", "General", "TextItemWidth", 50 )
   $TextItemHeight = IniRead (@WorkingDir&"\config.ini", "General", "TextItemHeight", 50 )
Endif
ConsoleWrite($FontSize)

Local $hFileOpen = FileOpen(@WorkingDir&"\out.txt", $FO_READ)
If $hFileOpen = -1 Then
   MsgBox($MB_SYSTEMMODAL, "", "An error occurred when reading the file(out.txt does not exist).")
   Return False
EndIf

Global $app = ObjCreate("Photoshop.Application")
$app.Preferences.RulerUnits = 1
$app.Preferences.TypeUnits = 5

Global $doc

Global $previousFilename = ""

Global $index = 0

While True
   $index=$index+1
   $line=FileReadLine($hFileOpen)
   if @error Then ExitLoop
   $lineSplit=StringSplit($line, @TAB)
   ConsoleWrite($lineSplit)
   $X=$lineSplit[1]
   $Y=$lineSplit[2]
   $width=$lineSplit[3]
   $height=$lineSplit[4]
   $filename=$lineSplit[5]
   $bgcolor=$lineSplit[6]
   if $previousFilename<>$filename Then
	  if $previousFilename<>"" Then
		 SaveAndClose($doc,@WorkingDir &"\"& $previousFilename & ".psd")
	  EndIf
      $doc = $app.open(@WorkingDir &"\"& $fileName)
      $previousFilename=$filename
   EndIf
   $text=StringRight($line, StringLen($line) - StringInStr($line,@TAB,0,6))
   ConsoleWrite($X & @CRLF)
   ConsoleWrite($Y & @CRLF)
   ConsoleWrite($width & @CRLF)
   ConsoleWrite($height & @CRLF)
   ;ConsoleWrite($doc.Width & @CRLF)
   ;ConsoleWrite($doc.Height & @CRLF)
   ConsoleWrite($filename & @CRLF)
   ConsoleWrite($bgcolor & @CRLF)
   ConsoleWrite($text & @CRLF)
   addLayer($doc,$X,$Y,$width,$height,$text,$bgcolor,$index)
WEnd

;SaveAndClose($doc,@WorkingDir &"\"& $previousFilename & ".psd")

Func SaveAndClose($doc,$path)
   SaveAs($doc,$path)
   $doc.close(2); don't save
EndFunc

MsgBox(64,"","Layers Added")

Func addLayer($doc,$X,$Y,$width,$height,$text,$bgcolor,$index)
   if $bgcolor<>"transparent" Then
	  Dim $colors[3]
	  $colors = StringSplit($bgcolor,",")
	  ConsoleWrite($colors[1] & @CRLF)
	  ConsoleWrite($colors[2] & @CRLF)
	  ConsoleWrite($colors[3] & @CRLF)
	  Dim $r = $colors[1]
	  Dim $g = $colors[2]
      Dim $b = $colors[3]
	  Dim $maskArtLayer = $doc.artLayers.add()
	  Dim $Position[2]
	  $Position[0]=$X
	  $Position[1]=$Y
	  $maskArtLayer.bounds=$Position
	  $maskArtLayer.name="mask "&$index
	  Dim $color = ObjCreate("Photoshop.SolidColor")
	  $color.RGB.Red=int($r)
	  $color.RGB.Green=int($g)
	  $color.RGB.Blue=int($b)
	  Dim $region[5]
	  Dim $arr1[2]
	  $arr1[0]=$X
	  $arr1[1]=$Y
	  Dim $arr2[2]
	  $arr2[0]=$X
	  $arr2[1]=$Y+$height
	  Dim $arr3[2]
	  $arr3[0]=$x+$width
	  $arr3[1]=$y+$height
	  Dim $arr4[2]
	  $arr4[0]=$x+$width
	  $arr4[1]=$Y
	  $region[0]=$arr1
	  $region[1]=$arr2
	  $region[2]=$arr3
	  $region[3]=$arr4
	  $region[4]=$arr4
	  $doc.Selection.Select($region)
	  $doc.Selection.Fill($color)
   EndIf

   Dim $textLayer = $doc.artLayers.add()

   $textLayer.Kind=2
   $textLayer.textItem.Contents = $text
   $textLayer.textItem.Kind= 2 ;paragraph
   ConsoleWrite("size:"&$FontSize)
   $textLayer.textItem.Size   = Int($FontSize)
   $Position[0]=$X-10
   $Position[1]=$Y-10
   $textLayer.textItem.Position=$Position
   ConsoleWrite(int($width) & @CRLF)
   ConsoleWrite($doc.Width)
   $textLayer.textItem.Width=int($TextItemWidth)
   $textLayer.textItem.Height=int($TextItemHeight)
EndFunc

Func SaveAsJPG($doc,$path)
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

Func SaveAs($doc,$path)
   Dim $ObjSaveOptions=ObjCreate("Photoshop.PhotoshopSaveOptions")
   ;if @error Then Exit
   With $ObjSaveOptions
	.Layers = True
   EndWith
   ConsoleWrite($path&@CRLF)
   $doc.SaveAS($path,$ObjSaveOptions,True,2)
EndFunc