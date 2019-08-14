ConsoleWrite("PSD Layers Export")
Dim $filename
Dim $layerName

if $cmdLine[0]<>2 Then
   $filename="\01\1.psd"
   $layerName="色相/饱和度/明度 1 2"
   Exit(1)
Else
   $filename=$cmdLine[1]
   $layerName=$cmdLine[2]
EndIf



;MsgBox(64,$filename,$layerName)

$app = ObjCreate("Photoshop.Application")
if StringLeft($filename,0)="\" Then
   $doc = $app.open(@WorkingDir & $fileName)
Else
   $doc = $app.open(@WorkingDir & "\" & $fileName)
EndIf

$LayerSets=$doc.LayerSets
$ArtLayers=$doc.ArtLayers
handleLayerSets($LayerSets)
handleArtLayers($ArtLayers)

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
	  if $layerName = $ArtLayer.name Then
		 if $ArtLayer.visible=True Then
			SaveLayerToJPG($ArtLayer)
		 Else
			Exit(1)
		 EndIf

		 Exit

	  EndIf
   Next
EndFunc

Func SaveLayerToJPG($ArtLayer)
   Dim $bounds[4]
   $bounds = $ArtLayer.bounds
   if $bounds[3] = 0 Then ;empty
	  exit(1)
   EndIf
   $ArtLayer.copy()
   $newDoc = $app.documents.add()
   $newDoc.paste()
   SaveAs($newDoc)
   $newDoc.close(2)
 EndFunc


 Func SaveAs($newDoc)
    Dim $ObjSaveOptions=ObjCreate("Photoshop.JPEGSaveOptions")
    With $ObjSaveOptions
       .EmbedColorProfile = True
       .FormatOptions = 1
       .Matte = 1
       .Quality = 1
    EndWith
    Dim $path
    $path= @WorkingDir & "\out.jpg"
    ConsoleWrite($path&@CRLF)
    $doc.SaveAS($path,$ObjSaveOptions,True,2)
 EndFunc