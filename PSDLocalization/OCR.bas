B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7.51
@EndOfDesignText@
'Static code module
Sub Process_Globals
	Private fx As JFX
	Private BaiduToken As String
	Private BaiduExpiredTime As Long=0
	Private TesseractInstalled As Boolean
End Sub

Sub GetText(img As B4XBitmap,lang As String,engine As String) As ResumableSub
	Dim result As String
	If engine="tesseract" Then
		wait for (tesseract(img,lang,TesseractInstalled)) Complete (result As String)
	else if engine = "baidu" Then
		wait for (baidu(img,"general",lang)) Complete (resultMap As Map)
		result=resultMap.Get("text")
	else if engine = "baidu_network" Then
		wait for (baidu(img,"network",lang)) Complete (resultMap As Map)
		result=resultMap.Get("text")
	End If
	Return result
End Sub

Sub checkTessearct
	wait for (isTesseractInstalled) Complete (result As Boolean)
	TesseractInstalled=result
End Sub

Sub GetTextWithLocation(img As B4XBitmap,engine As String) As ResumableSub
    If engine = "baidu" Then
		wait for (baidu(img,"withLocation",lang)) Complete (resultMap As Map)
	End If
	Return resultMap
End Sub

Sub tesseract(img As B4XBitmap,lang As String,isInstalled As Boolean) As ResumableSub
	Dim imgPath As String=File.Combine(File.DirApp,"image.jpg")
	Dim out As OutputStream=File.OpenOutput(imgPath,"",False)
	img.WriteToStream(out,"100","JPEG")
	out.Close
	
	Dim args As List
	args.Initialize
	args.AddAll(Array As String("image.jpg","output","-l",lang))
	Dim sh1 As Shell
	Log(File.Exists(File.Combine(File.DirApp,"tesseract-ocr"),"tesseract.exe"))

	If isInstalled Then
		sh1.Initialize("sh1","tesseract",args)
	Else
		sh1.Initialize("sh1",File.Combine(File.Combine(File.DirApp,"tesseract-ocr"),"tesseract"),args)
	End If
	sh1.WorkingDirectory = File.DirApp
	sh1.run(100000)
	wait for sh1_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
	If Success And ExitCode = 0 Then
		Log("Success")
		Log(StdOut)
		Dim text As String=File.ReadString(File.DirApp,"output.txt")
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
	If Success Then
		Log("Success")
		Log(StdOut)
		result=True
	Else
		Log("Error: " & StdErr)
		result=False
	End If
	Return result
End Sub

Sub saveImgToDisk(img As B4XBitmap)
	Dim imgPath As String=File.Combine(File.DirApp,"image.jpg")
	Dim out As OutputStream=File.OpenOutput(imgPath,"",False)
	img.WriteToStream(out,"100","JPEG")
	out.Close
End Sub

Sub baidu(img As B4XBitmap, OCRType As String,lang As String) As ResumableSub
	saveImgToDisk(img)
	Dim resultMap As Map
	Dim job As HttpJob
	job.Initialize("",Me)
	Dim su As StringUtils
	
	
	Dim base64 As String=su.EncodeBase64(File.ReadBytes(File.DirApp,"image.jpg"))
	base64=su.EncodeUrl(base64,"UTF-8")
	Log(DateTime.Now)
	Log(BaiduExpiredTime)
	If BaiduExpiredTime<DateTime.Now Then
		wait for (getTokenForBaidu) Complete (token As String)
	End If
	Dim endpoint As String
	Select OCRType
		Case "general"
			endpoint="https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic"
		Case "withLocation"
			endpoint="https://aip.baidubce.com/rest/2.0/ocr/v1/general"
		Case "network"
			endpoint="https://aip.baidubce.com/rest/2.0/ocr/v1/webimage"
	End Select
	
	Select lang
		Case "eng"
			lang="ENG"
		Case "chi_sim"
			lang="CHN_ENG"
		Case "chi_tra"
			lang="CHN_ENG"
		Case "jpn"
			lang="JAP"
	End Select
	
	job.PostString(endpoint,"access_token="&BaiduToken&"&probability=true&image="&base64&"&language_type="&lang)
	job.GetRequest.SetContentType("application/x-www-form-urlencoded")
	wait for (job) JobDone(job As HttpJob)
	If job.Success Then
		Try
			Log(job.GetString)
			Dim json As JSONParser
			json.Initialize(job.GetString)
			Dim resultMap As Map=json.NextObject
			Dim resultList As List
			resultList=resultMap.Get("words_result")
			Dim sb As StringBuilder
			sb.Initialize
			For Each result As Map In resultList
				sb.Append(result.Get("words")).Append(CRLF)
			Next
			resultMap.Put("text",sb.ToString)
			resultMap.Put("resultList",resultList)
		Catch
			Log(LastException)
		End Try
	End If
	Return resultMap
End Sub

Sub getTokenForBaidu As ResumableSub
	Dim job As HttpJob
	job.Initialize("",Me)
	Dim credentials As List
	credentials=File.ReadList(File.DirApp,"baidu")
	Dim clientID,clientSecret As String
	clientID=credentials.Get(0)
	clientSecret=credentials.Get(1)
	Dim params As String
	params="?grant_type=client_credentials&client_id="&clientID&"&client_secret="&clientSecret
	job.Download("https://aip.baidubce.com/oauth/2.0/token"&params)
	
	wait for (job) JobDone(job As HttpJob)
	If job.Success Then
		Try
			Dim json As JSONParser
			json.Initialize(job.GetString)
			BaiduToken=json.NextObject.Get("access_token")
			'Dim expiredseconds As Long=json.NextObject.Get("expires_in")
			BaiduExpiredTime=DateTime.Now+2592000*1000
			Log("2592000")
			Log(DateTime.Now)
			Log(BaiduExpiredTime)
		Catch
			Log(LastException)
		End Try
	End If
	Return BaiduToken
End Sub