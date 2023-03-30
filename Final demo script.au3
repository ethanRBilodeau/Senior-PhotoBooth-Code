#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:	Ethan Bilodeau
 Date: 		3/21/2023

 Sources used:
	https://www.autoitscript.com/forum/topic/92196-generate-random-alphanumeric-text/#comment-662781

 Script Function:
	Final Demo Script 

#ce ----------------------------------------------------------------------------

;external files and packages included
#include <MsgBoxConstants.au3>	
#include <FileConstants.au3>
#include <AutoItConstants.au3>
#include <findLatestFile.au3>
#include <ExtMsgBox.au3>

AutoItSetOption("MouseCoordMode",0)	;setting mouse coordinate

;initalizing buttons to their functions
HotKeySet('b', 'startProcess')
HotKeySet('f', 'exitProgram')

$maxPics = 5		;global variable for maximum number of pictures allowed
$picsTaken = 0		;global variable for current number of pictures taken

;while loop allows for continuous reading of buttons being pressed
;debouncing is accounted for in external program running on arduino
;where where buttons are read as keyboard inputs
While 1	
	Sleep(50)
WEnd


;Function: exitProgram
;Purpose: Takes photo booth out of ready mode and ends script looping.
;				Run in case of using computer for purposes other than regular photo booth function.
;
;Input:	Button (insert color) that can be found inside the photo booth cabinet.  Will override any
;			regular photo booth function an stop script at its current progress.  Script/.exe will need
;			to be restarted in order for photo booth to work again.
;
;Return: Nothing, the script will stop running
Func exitProgram()
	Exit
EndFunc


;Function: fakeFunc
;Purpose: Placeholder function to "deactivate" buttons while they are not supposed to be pressed.
;
;Input:	None, automatically called when needed.
;
;Return: Nothing
Func fakeFunc()
	;does nothing, used for deactivating hotkeys during specific durations
EndFunc


;Function: randomCode
;Purpose: Generates random code for folder that user's photos will be stored in.  This code will
;				also be given to the user in order for them to redeem their photos.
;
;Input:	None, the function is run once at the beginning of every photo booth session.
;
;Return: A string of length seven(fourth digit will be "-") of random digits and capital letters.
;
;Source: Inspired by user GEOSoft from Autoit forums.
;				https://www.autoitscript.com/forum/topic/92196-generate-random-alphanumeric-text/#comment-662781
Func randomCode()
	$iLen = 6
	$sStr = ""
	Do
	   $sHold = Chr(Random(48, 90, 1))
	   If StringRegExp($sHold, "(?i)[a-z0-9]") Then $sStr &= $sHold
	   If StringLen($sStr) = $iLen/2 Then 
		   $sStr &= "-"
		   $iLen += 1
		EndIf
	Until StringLen($sStr) = $iLen

	Return $sStr
EndFunc


;Function: takePic
;Purpose: Opens camera application and moves mouse to take pictrure.  Also generates a text box to let the
;				user know that the camera will take a picture imminently.
;
;Input:	None
;
;Return: Nothing
;
;Source: Majority of code is originally authored by me.
;			Camera launch line from user Sascha on stack overflow forums.
;			https://stackoverflow.com/questions/39080176/launch-camera-application-windows-10-using-autoit
Func takePic()
	local $iPID = ShellExecuteWait("explorer.exe", "shell:AppsFolder\Microsoft.WindowsCamera_8wekyb3d8bbwe!App")
	WinActivate("Camera")
	Sleep(1000)
	WinSetState("Camera","",@SW_MAXIMIZE)
	WinWaitActive("Camera")
	_ExtMsgBoxSet(4 +32, 1 + 4, Default, Default, 30, "Arial")
	_ExtMsgBox(128, " ", "", "Get Ready!", 5, 50, 50)
	_ExtMsgBoxSet(Default)
	MouseMove(1161,300,0)
	WinWaitActive("Camera")
	Sleep(50)
	MouseClick("left")
	WinWaitActive("Camera")
	Sleep(300)
	WinSetState("Camera","",@SW_RESTORE)
	WinWaitActive("Camera")
	$picsTaken +=1
	Sleep(500)
EndFunc

Func displayNewPic()
	MouseMove(1161,525,0)
	WinWaitActive("Camera")
	Sleep(50)
	MouseClick("left")
	WinWaitActive("Camera")
	WinSetState("Camera","",@SW_MAXIMIZE)
	WinWaitActive("Camera")
EndFunc

Func returnToCam()
	WinSetState("Camera","",@SW_RESTORE)
	WinWaitActive("Camera")
	MouseMove(27,52,5)
	WinWaitActive("Camera")
	Sleep(50)
	MouseClick("left")
	WinWaitActive("Camera")
	Sleep(50)
	MouseClick("left")
	WinWaitActive("Camera")
EndFunc

Func startProcess()
	HotKeySet('b', 'fakeFunc')
	$string = randomCode()
	$gDriveDir = 'G:\My Drive\Photos\' & $string
	DirCreate($gDriveDir)
	
	$takeAnother = ""
	
	_ExtMsgBoxSet(4 +32, 1 + 4, Default, Default, 30, "Arial", 700)
	$sMsg = "The camera will open and take your picture. "
	$sMsg &= "After this, a random code will be displayed. "
	$sMsg &= "Save this code to redeem your pictures."

	$iRetValue = _ExtMsgBox(128, " ", "INSTRUCTIONS", $sMsg, 20, 0, 0)

	Sleep(250)
	
	While(NOT($takeAnother = 9))
		Call("takePic")
		Sleep(500)
		Call("displayNewPic")
		Sleep(1000)
		$lastPicDir = _FindLatestLog('C:\Users\ebilodea\Pictures\Camera Roll', '*.jpg')
		FileCopy($lastPicDir, $gDriveDir)
		If $picsTaken < $maxPics Then
			(4 +32, 1 + 4, Default, Default, 20, "Arial")
			$sMsg = "Take another picture?"&@CRLF&"If yes, press the button."&@CRLF&"If no, do nothing, the box will go away"
			$takeAnother =_ExtMsgBox(128, $MB_OK,  ($maxPics-$picsTaken)&"/" & $maxPics & " Pictures Left", $sMsg, 10, 1, 1)
			ConsoleWrite($takeAnother & @CRLF)
			_ExtMsgBoxSet(Default)
			If $takeAnother = 1 Then
				Call("returnToCam")
			EndIf
		Else
			ExitLoop
		EndIf
	WEnd
	
	WinClose("Camera")
	Sleep(1000)
	
	;$sDriveDir = 
	;$cameraRollDir = 'C:\Users\ebilodea\Pictures\Camera Roll'
	
	
	
	;DirCopy($lastPicDir, $sDriveDir)
	;FileDelete($lastPicDir)
	;_ExtMsgBoxSet(4 +32, 1 + 4, Default, Default, 30, "Arial")
	;$sMsg = "Scan this QR code to get your pictures delivered."
	_ExtMsgBoxSet(4 +32, 1 + 4, Default, Default, 30, "Arial", 700)
	$sMsg = "Get your phone out and take a picture of the code that will be displayed next."
	$sMsg &= @CRLF & "Press the yellow button when phone is ready"

	;shellexecute("G:\My Drive\QR code.png")

	$iRetValue = _ExtMsgBox(128, $MB_OK, "IMPORTANT", $sMsg, 60, 0, 0)

	Sleep(1000)

	$sMsg = "The code to collect your pictures is:"
	$sMsg &= @CRLF & @CRLF
	$sMsg &= $string
	$sMsg &= @CRLF & @CRLF
	$sMsg &= "Take a picture if you need."

	$iRetValue = _ExtMsgBox(128, " ", "IMPORTANT", $sMsg, 30, 100, 150)

	;WinActivate("QR code.png ‎- Photos")
	;WinClose("QR code.png ‎- Photos")

	$sMsg = "Your session is over." & @CRLF & "Scan the QR code to get your pictures :)"

	$iRetValue = _ExtMsgBox(128, " ", "Session Done", $sMsg, 5, 0, 0)
	_ExtMsgBoxSet(Default)

	HotKeySet('b', 'startProcess')
	$picsTaken = 0
EndFunc