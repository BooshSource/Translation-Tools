B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.32
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private tokenJO As JavaObject
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(jo As JavaObject)
	tokenJO=jo
End Sub

Public Sub getSurface As String
	Return tokenJO.RunMethod("getSurface",Null)
End Sub

Public Sub getAllFeatures As String
	Return tokenJO.RunMethod("getAllFeatures",Null)
End Sub

Public Sub getPartOfSpeechLevel2 As String
	Return tokenJO.RunMethod("getPartOfSpeechLevel2",Null)
End Sub

Public Sub getPartOfSpeechLevel1 As String
	Return tokenJO.RunMethod("getPartOfSpeechLevel1",Null)
End Sub

Public Sub getPartOfSpeechLevel3 As String
	Return tokenJO.RunMethod("getPartOfSpeechLevel3",Null)
End Sub

Public Sub getPartOfSpeechLevel4 As String
	Return tokenJO.RunMethod("getPartOfSpeechLevel4",Null)
End Sub

Public Sub getConjugationType As String
	Return tokenJO.RunMethod("getConjugationType",Null)
End Sub

Public Sub getConjugationForm As String
	Return tokenJO.RunMethod("getConjugationForm",Null)
End Sub

Public Sub getBaseForm As String
	Return tokenJO.RunMethod("getBaseForm",Null)
End Sub

Public Sub getReading As String
	Return tokenJO.RunMethod("getReading",Null)
End Sub

Public Sub getPronunciation As String
	Return tokenJO.RunMethod("getPronunciation",Null)
End Sub

Public Sub getJO As JavaObject
	Return tokenJO
End Sub