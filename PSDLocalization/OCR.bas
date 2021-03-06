﻿B4J=true
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
	Private Bconv As ByteConverter
	Private TesseractInstalled As Boolean
End Sub

Sub checkTessearct
	wait for (isTesseractInstalled) Complete (result As Boolean)
	TesseractInstalled=result
End Sub

Sub GetText(img As B4XBitmap,lang As String,engine As String) As ResumableSub
	Dim result As String
	If engine="tesseract" Then
		wait for (tesseract(img,lang)) Complete (result As String)
	else if engine = "baidu" Then
		wait for (baidu(img,"general",lang)) Complete (resultMap As Map)
		result=resultMap.Get("text")
	else if engine = "baidu_network" Then
		wait for (baidu(img,"network",lang)) Complete (resultMap As Map)
		result=resultMap.Get("text")
	else if engine = "youdao" Then
		wait for (youdao(img,lang)) Complete (regions As List)
		For Each region As Map In regions
			result=result&region.Get("text")
		Next
	End If
	Return result
End Sub

Sub GetTextWithLocation(img As B4XBitmap,lang As String,engine As String) As ResumableSub
    If engine = "baidu" Then
		wait for (baidu(img,"withLocation",lang)) Complete (resultMap As Map)
		Return resultMap
	else if engine = "youdao" Then
		wait for (youdao(img,lang)) Complete (regions As List)
		Return regions
	End If
End Sub

Sub tesseract(img As B4XBitmap,lang As String) As ResumableSub
	Dim imgPath As String=File.Combine(File.DirApp,"image.jpg")
	Dim out As OutputStream=File.OpenOutput(imgPath,"",False)
	img.WriteToStream(out,"100","JPEG")
	out.Close
	
	Dim args As List
	args.Initialize
	args.AddAll(Array As String("image.jpg","output","-l",lang))
	Dim sh1 As Shell
	Log(File.Exists(File.Combine(File.DirApp,"tesseract-ocr"),"tesseract.exe"))
	If TesseractInstalled Then
		sh1.Initialize("sh1","tesseract",args)
	Else
		sh1.Initialize("sh1",File.Combine(File.Combine(File.DirApp,"tesseract-ocr"),"tesseract"),args)
	End If
	sh1.WorkingDirectory = File.DirApp
	sh1.run(100000)
	wait for sh1_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
	If Success And ExitCode=0 Then
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
	'Dim su As StringUtils
	'Dim base64 As String=su.EncodeBase64(File.ReadBytes(File.DirApp,"image.jpg"))
	
End Sub

Sub saveImgToDiskWithSizeCheck(img As B4XBitmap,quality As Int, sizeLimit As Int)
	Dim imgPath As String=File.Combine(File.DirApp,"image.jpg")
	Dim out As OutputStream=File.OpenOutput(imgPath,"",False)
	img.WriteToStream(out,quality,"JPEG")
	out.Close
	Dim su As StringUtils
	Dim base64 As String=su.EncodeBase64(File.ReadBytes(File.DirApp,"image.jpg"))
	If base64.Length>sizeLimit Then
		Log("bigger than limit")
		If quality>=10 Then
			saveImgToDiskWithSizeCheck(img,quality-10,sizeLimit)
		End If
	End If
End Sub

Sub baidu(img As B4XBitmap, OCRType As String,lang As String) As ResumableSub
	saveImgToDiskWithSizeCheck(img,100,5000000)
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
				sb.Append(result.Get("words"))
			Next
			resultMap.Put("text",sb.ToString)
			resultMap.Put("resultList",resultList)
		Catch
			Log(LastException)
		End Try
	End If
	Return resultMap
End Sub


Sub detectBalloons(img As B4XBitmap) As ResumableSub
	saveImgToDiskWithSizeCheck(img,100,5000000)
	Dim job As HttpJob
	job.Initialize("",Me)
	Dim su As StringUtils
	
	Dim base64 As String=su.EncodeBase64(File.ReadBytes(File.DirApp,"image.jpg"))
	Log(base64)
	Dim bytes() As Byte
	bytes=base64.GetBytes("UTF-8")
	Log("bytes"&bytes.Length)
	Log(DateTime.Now)
	Log(BaiduExpiredTime)
	If BaiduExpiredTime<DateTime.Now Then
		wait for (getTokenForBaidu) Complete (token As String)
	End If
	
	Dim map1 As Map
	map1.Initialize
	map1.Put("image",base64)
	Dim json As JSONGenerator
	json.Initialize(map1)
	
	job.PostBytes("https://aip.baidubce.com/rpc/2.0/ai_custom/v1/detection/mangaTextarea?access_token="&BaiduToken,json.ToString.GetBytes("UTF8"))
	job.GetRequest.SetContentType("application/json")
	job.GetRequest.SetContentEncoding("UTF-8")
	wait for (job) JobDone(job As HttpJob)
	If job.Success Then
		Try
			Log(job.GetString)
			Return job.GetString
		Catch
			Log(LastException)
		End Try
	End If
	Return ""
End Sub

Sub getTokenForBaidu As ResumableSub
	Dim job As HttpJob
	job.Initialize("",Me)
	Try
		Dim credentials As List
		credentials=File.ReadList(File.DirApp,"baidu")
		Dim clientID,clientSecret As String
		clientID=credentials.Get(0)
		clientSecret=credentials.Get(1)
	Catch
		Log(LastException)
		Return ""
	End Try

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

Sub youdao(img As B4XBitmap,lang As String) As ResumableSub
	saveImgToDiskWithSizeCheck(img,100,2000000)
	Dim regions As List
	regions.Initialize
	Select lang
		Case "eng"
			lang="en"
		Case "chi_sim"
			lang="zh-CHS"
		Case "chi_tra"
			lang="zh-CHT"
		Case "jpn"
			lang="ja"
	End Select

	Dim appid,sign,key As String
	Try
		Dim credentials As List
		credentials=File.ReadList(File.DirApp,"youdao")
		appid=credentials.Get(0)
		key=credentials.Get(1)
	Catch
		Log(LastException)
		Return regions
	End Try

	

	Dim su As StringUtils
	Dim base64 As String=su.EncodeBase64(File.ReadBytes(File.DirApp,"image.jpg"))
	Dim salt As Int
	salt=Rnd(1,1000)

	DateTime.SetTimeZone(0)
	Dim timestamp As String=DateTime.Now
	timestamp=timestamp.SubString2(0,timestamp.Length-3)
	'Log(timestamp)
	Dim before, after As String
	before=base64.SubString2(0,10)
	'Log(before.Length)
	after=base64.SubString2(base64.Length-10,base64.Length)
	'Log(after.Length)
    Dim input As String
	input=before&base64.Length&after
	Dim curtime As Int=timestamp
	'Log(input)
	sign=appid&input&salt&curtime&key
	Dim md As MessageDigest
	sign=Bconv.HexFromBytes(md.GetMessageDigest(Bconv.StringToBytes(sign,"UTF-8"),"SHA-256"))
	'sign=sign.ToLowerCase
	Log(sign)
	
	Dim params As String
	base64=su.EncodeUrl(base64,"UTF-8")
	params="img="&base64&"&langType="&lang&"&detectType=10012&imageType=1&appKey="&appid&"&docType=json&signType=v3&curtime="&curtime&"&salt="&salt&"&sign="&sign
	
	Dim job As HttpJob
	job.Initialize("",Me)
	job.PostString("https://openapi.youdao.com/ocrapi",params)
	wait for (job) JobDone(job As HttpJob)
	If job.Success Then
		Try
			Log(job.GetString)
			Dim json As JSONParser
			json.Initialize(job.GetString)
			Dim map1 As Map
			map1=json.NextObject
			Dim result As Map = map1.Get("Result")

			regions=result.Get("regions")
		
			For Each region As Map In regions
				Dim text As String
				Dim lines As List
				lines=region.Get("lines")
				For Each line As Map In lines
					text=text&line.Get("text")&CRLF
				Next
				region.Put("text",text)
			Next
		Catch
			Log(LastException)
		End Try

	End If
	Log(text)
	Return regions
End Sub