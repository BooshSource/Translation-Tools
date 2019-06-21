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

Sub tesseract(img As Image,lang As String) As ResumableSub
	Dim imgPath As String=File.Combine(File.DirTemp,"image.jpg")
	Dim out As OutputStream=File.OpenOutput(imgPath,"",False)
	img.WriteToStream(out)
	out.Close
	
	Dim args As List
	args.Initialize
	args.AddAll(Array As String("image.png","output","-l",lang))
	Dim sh1 As Shell
	Log(File.Exists(File.Combine(File.DirApp,"tesseract-ocr"),"tesseract.exe"))
	wait for (isTesseractInstalled) Complete (tesseractInstalled As Boolean)
	If tesseractInstalled Then
		sh1.Initialize("sh1","tesseract",args)
	Else
		sh1.Initialize("sh1",File.Combine(File.Combine(File.DirApp,"tesseract-ocr"),"tesseract"),args)
	End If
	sh1.WorkingDirectory = File.DirTemp
	sh1.run(100000)
	wait for sh1_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
	If Success And ExitCode = 0 Then
		Log("Success")
		Log(StdOut)
		Dim text As String=File.ReadString(File.DirTemp,"output.txt")
		Return text
		'fx.Clipboard.SetString(TextArea1.Text)
	Else
        Return ""
	End If
End Sub

Sub isTesseractInstalled As ResumableSub
	Dim result As Boolean
	Dim sh As Shell
	sh.Initialize("sh","tesseract",Null)
	sh.run(10000)
	wait for sh_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
	If Success And ExitCode = 0 Then
		Log("Success")
		Log(StdOut)
		result=True
	Else
		Log("Error: " & StdErr)
		result=False
	End If
	Return result
End Sub

Sub baidu
	
End Sub