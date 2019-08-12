#include <FileConstants.au3>
#include <File.au3>
if $cmdLine[0]=1 Then
   $filename = $cmdLine[1]
Else
   Exit
endif

$app = ObjCreate("Photoshop.Application")
$app.Preferences.RulerUnits = 1
$app.Preferences.TypeUnits = 5

$doc = $app.open(@WorkingDir &"\"& $fileName)

Local $hFileOpen = FileOpen( @WorkingDir & "\res.txt", $FO_OVERWRITE)
If $hFileOpen = -1 Then
   MsgBox($MB_SYSTEMMODAL, "", "An error occurred when reading the file.")
   Return False
EndIf
FileWrite($hFileOpen, $doc.Resolution)
FileClose($hFileOpen)

$doc.close(2)

