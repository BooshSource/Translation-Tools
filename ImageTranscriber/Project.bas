B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.51
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private path As String
	Public projectFile As Map
	Public imgList As List
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(projectFilePath As String,isNew As Boolean)
	path=projectFilePath
	projectFile.Initialize
	If isNew=False Then
		readProjectFile
	End If
End Sub

Public Sub import(dirPath As String)
	projectFile.Put("dirPath",dirPath)
	Dim dirName As String=File.GetName(dirPath)
	Dim files As List=File.ListFiles(dirPath)
	imgList.Initialize
	For Each filename As String In files
		Dim imgMap As Map
		imgMap.Initialize
		imgMap.Put("filename",filename)
		imgMap.Put("text","")
		Dim emptyList As List
		emptyList.Initialize
		imgMap.Put("boxes",emptyList)
		imgList.Add(imgMap)
	Next
	projectFile.Put(dirName,imgList)
End Sub

Sub readProjectFile
	Dim json As JSONParser
	json.Initialize(File.ReadString(path,""))
	projectFile=json.NextObject
	Dim dirName As String=File.GetName(projectFile.get("dirPath"))
	imgList=projectFile.Get(dirName)
End Sub

Public Sub save
	Dim json As JSONGenerator
	json.Initialize(projectFile)
	File.WriteString(path,"",json.ToPrettyString(4))
End Sub

