B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7.51
@EndOfDesignText@
'Static code module
Sub Process_Globals
	Private fx As JFX
End Sub


Sub export(tmList As List,savePath As String)
	Dim rootmap As Map
	rootmap.Initialize
	Dim tmxMap As Map
	tmxMap.Initialize
	tmxMap.Put("Attributes",CreateMap("version":"1.4"))
	Dim headerAttributes As Map
	headerAttributes.Initialize
	headerAttributes.Put("creationtool","BasicCAT")
	headerAttributes.Put("creationtoolversion","1.0.0")
	headerAttributes.put("adminlang","en")
	headerAttributes.put("srclang","en")
	headerAttributes.put("segtype","sentence")
	headerAttributes.put("o-tmf","BasicCAT")
	tmxMap.Put("header",headerAttributes)
	Dim body As Map
	body.Initialize
	Dim tuList As List
	tuList.Initialize
	For Each map1 As Map In tmList

		Dim tuMap As Map
		tuMap.Initialize
		Dim tuvList As List
		tuvList.Initialize
		For Each langcode As String In map1.Keys
			Dim seg As String
			seg=map1.Get(langcode)
			tuvList.Add(CreateMap("Attributes":CreateMap("xml:lang":langcode),"seg":seg))
		Next
		
		tuMap.Put("tuv",tuvList)
		tuList.Add(tuMap)
	Next
	body.Put("tu",tuList)
	tmxMap.Put("body",body)
	rootmap.Put("tmx",tmxMap)
	Dim tmxstring As String
	Try
		tmxstring=XMLUtils.getXmlFromMap(rootmap)
	Catch
		fx.Msgbox(Main.MainForm,"export failed because of tag problem","")
		Return
		Log(LastException)
	End Try
	File.WriteString(savePath,"",tmxstring)
End Sub

Sub exportQuick(tmList As List, savePath As String)
	Dim sb As StringBuilder
	sb.Initialize
	Dim head As String=$"<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<tmx version="1.4">
    <header>
        <creationtool>BasicCAT</creationtool>
        <creationtoolversion>1.0.0</creationtoolversion>
        <adminlang>en</adminlang>
        <srclang>en</srclang>
        <segtype>sentence</segtype>
        <o-tmf>BasicCAT</o-tmf>
    </header>
    <body>
	"$
	Dim tail As String=$"</body>
</tmx>"$
	Dim addedTM As Map
	addedTM.Initialize
	sb.Append(head)
	For Each tuMap As Map In tmList
		sb.Append("<tu>").Append(CRLF)
		For Each langcode As String In tuMap.Keys
			Dim seg As String
			seg=tuMap.Get(langcode)

			sb.Append($"<tuv xml:lang="${langcode}">"$).Append(CRLF)
			sb.Append("    ").Append("<seg>").Append(seg).Append("</seg>").Append(CRLF)
			sb.Append("</tuv>").Append(CRLF)
		Next
		sb.Append("</tu>").Append(CRLF)
	Next
	sb.Append(tail)
	File.WriteString(savePath,"",sb.ToString)
End Sub