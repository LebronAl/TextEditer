.386
.model flat, stdcall
option casemap:none
;-----------------------------------------------------------------------
;Include �ļ�����
;-----------------------------------------------------------------------
include			windows.inc
include			gdi32.inc
includelib		gdi32.lib
include			user32.inc
includelib		user32.lib
include			kernel32.inc
includelib		kernel32.lib
include			comctl32.inc
includelib		comctl32.lib
include			comdlg32.inc
includelib		comdlg32.lib
;-----------------------------------------------------------------------
;Equ ��ֵ����
;-----------------------------------------------------------------------
;Menu
IDM_MAIN		equ    	1000h

IDM_NEW			equ    	1101h
IDM_OPEN		equ    	1102h
IDM_SAVE		equ    	1103h
IDM_SAVEAS		equ    	1104h
IDM_PAGESET		equ		1105h
IDM_QUIT		equ		1106h

IDM_UNDO		equ		1201h
IDM_REDO		equ		1202h
IDM_CUT			equ		1203h
IDM_COPY		equ		1204h
IDM_PASTE		equ		1205h
IDM_DELETE		equ		1206h
IDM_FIND		equ		1207h
IDM_REPLACE		equ		1208h
IDM_ALL			equ		1209h
IDM_DATE		equ		1210h

IDM_FONT		equ		1301h

IDM_HELP		equ		1401h
IDM_ABOUT		equ		1402h

;Accelerators 	
IDA_MAIN		equ		2000h
;Statusbar
IDCC_STATUSBAR	equ		3000h
;-----------------------------------------------------------------------
;���ݶ�
;-----------------------------------------------------------------------
.data
	hInstance		dd		?
	hWinMain		dd		?
	hStatusBar		dd		?
	hWinEdit		dd		?
	hFile			dd 		?
	hFind			dd 		?
	hReplace		dd 		?
	hMainMenu		dd		?
	hSubMenu		dd		?
	;OPENFILENAME
	szFile			db 		MAX_PATH	dup(?)
	szFileTitle		db 		MAX_PATH	dup(?)
	;CHOOSEFONT
	stLogFont		LOGFONT<?>
	;CHOOSECOLOR
	szFontColors	dd		16			dup(?)
	;FINDREPLACE
	iWM_FINDREPLACE	dd		?
	stFr			FINDREPLACE<?>
	szFindWhat		db		100			dup(?)
	szReplaceWith	db		100			dup(?)
	;StatusBar
	szFormat_1		db		'��������ļ���С:%d�ֽ� %d��', 0
	;ȫ�ִ洢���ڴ�С
	stRect_MainWin 	RECT<?>
	;�к����
	charFmt  		db  	'%4u', 0
	lpEditProc		dd		?
	;ȫ�ִ洢����
	stCharFormat	CHARFORMAT<?>
	;ʱ��
	stSystemTime SYSTEMTIME <>
	stTimeString db 30 dup(?)

.const
	szClassName		db		'MyTextEditor',0
	szCaptionMain	db		'TextEditor++',0
	szText			db		"Let's do something!",0
	szSaveSucceed	db		'����ɹ�', 0
	szNotice		db		'��ʾ', 0
	;OPENFILENAME
	szFilter		db		'�ı��ļ�(*.txt)', 0, '*.txt', 0
					db		'�����ļ�(*.*)', 0, '*.*', 0, 0
	szDefaultExt		db		'txt', 0
	szFileHasModified	db 	'�ļ��ѱ��޸�,�Ƿ񱣴�?', 0
	;FINDREPLACE
	szFindReplace	db    	'commdlg_FindReplace', 0
	szNotFound		db		'�ı���û���ҵ�ƥ����!', 0
	;EDITSTREAM
	szCannotOpenTheFile	db		'�޷��򿪸��ļ�.', 0

	szDllRiched20	db		'riched20.dll',0
	szClassEdit		db		'RichEdit20A',0
	szFont			db		'����',0
	szTxt			db		'�޸�ʽ�ı�',0

	dwStatusWidth	dd		300,500,-1

	szHelpTitle		db		'����',0
	szHelp			db		'������鿴��ҵ�ĵ�',0

	szAboutTitle	db		'����TextEditor++',0
	szAbout			db		'����Win32�����ı��༭��',0dh,0ah,0dh,\
							'�����ߣ�̷���� ¬���� ���Ļ�',0dh,0ah,0

;-----------------------------------------------------------------------
;�����
;-----------------------------------------------------------------------
.code
;-----------------------------------------------------------------------
;��ʾ�кţ������к�����
;-----------------------------------------------------------------------
_ShowLineNum  	PROC  	
				local	@stClientRect:RECT		;RichEdit�Ŀͻ�����С
				local @hDcEdit				;RichEdit��Dc���豸������
				local @Char_Height			;�ַ��ĸ߶�
				local @Line_Count				;�ı���������	
				local @ClientHeight			;RichEdit�Ŀͻ����߶�
				local	@CharFmt:CHARFORMAT		;RichEdit�е�һ���ṹ�����ڻ�ȡ�ַ���һϵ����Ϣ������ֻ��������ȡ�ַ��߶�	
				local	@hdcBmp					;��RichEdit���ݵ�λͼdc
				local	@hdcCpb					;��RichEdit���ݵ�Dc
				local	@stBuf[10]:byte			;��ʾ�кŵĻ�����
				local @Margin						;�м��
				pushad
				
				;��λͼ����RichEdit������		
				invoke  GetDC, hWinEdit										;��ȡRichEdit��Dc	
				mov		@hDcEdit, eax
				invoke  CreateCompatibleDC, @hDcEdit						;������RichEdit���ݵ�λͼDc
				mov		@hdcCpb, eax
				invoke  GetClientRect, hWinEdit, addr @stClientRect			;������RichEdit���ݵ�λͼ
				mov		ebx, @stClientRect.bottom
				sub		ebx, @stClientRect.top
				mov		@ClientHeight, ebx
				invoke  CreateCompatibleBitmap, @hDcEdit, 45, @ClientHeight;
				mov		@hdcBmp, eax
				invoke  SelectObject, @hdcCpb, @hdcBmp						
				;�����ɫ
				invoke  CreateSolidBrush, 0face87h							
				invoke  FillRect, @hdcCpb, addr @stClientRect, eax			
				invoke  SetBkMode, @hdcCpb, TRANSPARENT		
				;��ȡ������
				invoke  SendMessage, hWinEdit, EM_GETLINECOUNT, 0, 0
				mov 	@Line_Count, eax	
				;��ȡ�ı���ʽ
				invoke  RtlZeroMemory, addr @CharFmt, sizeof @CharFmt
				mov		@CharFmt.cbSize, sizeof @CharFmt	
				invoke  SendMessage, hWinEdit, EM_GETCHARFORMAT, SCF_DEFAULT, addr @CharFmt;��ȡ�ַ��߶ȣ���Ӣ��Ϊ��λ����ת��Ϊ����ֻҪ����20����
				;��ȡ�и�
				mov		eax, @CharFmt.yHeight									
				cdq
				mov		ebx, 20
				div		ebx
				mov		@Char_Height, eax
				;��ȡ�м��
				mov		ebx, 3
				div		ebx
				mov		@Margin, eax

				invoke	RtlZeroMemory, addr @stBuf, sizeof @stBuf				
				;������ʾ�кŵ�ǰ��ɫ
				invoke  SetTextColor, @hdcCpb, 0000000h
				mov		ebx, @Char_Height
				mov		@Char_Height,1 
				;��ȡ�ı����е�һ���ɼ����е��кţ�û������к���ʾ��������ı��Ĺ�����������
				invoke  SendMessage, hWinEdit, EM_GETFIRSTVISIBLELINE, 0, 0
				mov		edi, eax
				inc		edi			
				;��λͼdc��ѭ������к�
				.while	edi <= @Line_Count
						invoke  wsprintf, addr @stBuf, addr charFmt, edi			;���ش洢���ַ���
						invoke  TextOut, @hdcCpb, 1, @Char_Height, addr @stBuf, eax 
						mov		edx, @Char_Height
						add		edx, ebx
						add		edx, 	@Margin	;��������м�࣬������ȷ��
						mov		@Char_Height, edx
						inc  	edi
						.break  .if  edx > @ClientHeight 
				.endw		
				;����"����"��λͼ����"��"��RichEdit��
				invoke	BitBlt, @hDcEdit, 0, 0, 45, @ClientHeight, @hdcCpb, 0, 0, SRCCOPY 
				invoke	DeleteDC, @hdcCpb
				invoke	ReleaseDC, hWinEdit, @hDcEdit
				invoke	DeleteObject, @hdcBmp
			
				popad							
				
				ret

_ShowLineNum 	ENDP
;-----------------------------------------------------------------------
;�ı��༭����
;-----------------------------------------------------------------------
_SubProcEdit  	PROC	hWnd, uMsg, wParam, lParam
				local	@stPs: PAINTSTRUCT
				local	@stPt: POINT
				local	@stRange:CHARRANGE
				
				mov		eax, uMsg
				.if		eax == WM_PAINT
						invoke	CallWindowProc, lpEditProc, hWnd, uMsg, wParam, lParam
						invoke  BeginPaint, hWinEdit, addr @stPs
						invoke  _ShowLineNum
						invoke  EndPaint, hWinEdit, addr @stPs
						ret
				.elseif	eax == WM_RBUTTONDOWN
						;�����Ҽ����
						invoke 	GetCursorPos, addr @stPt
						invoke 	TrackPopupMenu, hSubMenu, TPM_LEFTALIGN, @stPt.x, @stPt.y, 0, hWinEdit, NULL
				.elseif eax == WM_COMMAND
						;�����ı������Ҽ��˵�ѡ��
						mov		eax, wParam
						.if ax == IDM_UNDO
								invoke  SendMessage, hWinEdit, EM_UNDO, 0, 0

						.elseif ax == IDM_REDO
								invoke  SendMessage, hWinEdit, EM_REDO, 0, 0

						.elseif ax == IDM_CUT
								invoke  SendMessage, hWinEdit, WM_CUT, 0, 0

						.elseif ax == IDM_COPY
								invoke  SendMessage, hWinEdit, WM_COPY, 0, 0

						.elseif ax == IDM_PASTE
								invoke  SendMessage, hWinEdit, WM_PASTE, 0, 0

						.elseif ax == IDM_DELETE
								invoke  SendMessage, hWinEdit, WM_CLEAR, 0, 0

						.elseif ax == IDM_ALL
								mov	@stRange.cpMin, 0
								mov	@stRange.cpMax, -1
								invoke  SendMessage, hWinEdit, EM_EXSETSEL, 0, addr @stRange

						.elseif ax == IDM_FIND
								and		stFr.Flags, not FR_DIALOGTERM
								invoke	FindText, addr stFr
								mov		hFind, eax

						.elseif ax == IDM_REPLACE
								and		stFr.Flags, not FR_DIALOGTERM
								invoke	ReplaceText, addr stFr
								mov		hReplace, eax
						.endif
				.endif
				invoke  CallWindowProc, lpEditProc, hWnd, uMsg, wParam, lParam
				ret

_SubProcEdit 	ENDP
;-----------------------------------------------------------------------
_PageSet PROC
	local	@stPs:PAGESETUPDLG
	invoke	RtlZeroMemory,addr @stPs,sizeof @stPs
	mov		@stPs.lStructSize,sizeof @stPs
	push	hWinMain
	pop		@stPs.hwndOwner
	invoke	PageSetupDlg,addr @stPs
	ret

_PageSet ENDP
;-----------------------------------------------------------------------
_CheckModify	PROC
	;�ж��ĵ��Ƿ��޸Ĺ�
	invoke 	SendMessage, hWinEdit, EM_GETMODIFY, 0, 0
	.if 	eax
		invoke	MessageBox, hWinMain, addr szFileHasModified, addr szNotice, MB_YESNOCANCEL
		.if		eax == IDYES
			.if 	!hFile
				call 	_SaveAs
			.else
				call 	_Save
			.endif
		.elseif	eax == IDCANCEL
			mov		eax, FALSE
			ret
		.endif
	.endif
	mov 	eax, TRUE
	ret
				
_CheckModify	ENDP
;-----------------------------------------------------------------------
_ProcStream		PROC	uses ebx edi esi dwCookie, lpBuffer, dwBytes, lpBytes
			
				.if 	dwCookie
						invoke	ReadFile, hFile, lpBuffer, dwBytes, lpBytes, NULL
				.else
						invoke  WriteFile, hFile, lpBuffer, dwBytes, lpBytes, NULL
				.endif
				
				xor		eax, eax
				
				ret
				
_ProcStream		ENDP
;-----------------------------------------------------------------------
_New			PROC

				invoke	CloseHandle, hFile
				invoke 	DestroyWindow, hWinEdit
				invoke 	GetClientRect, hWinMain, addr stRect_MainWin
				mov		eax, stRect_MainWin.bottom
				sub		eax, 0018h
				invoke 	CreateWindowEx, WS_EX_CLIENTEDGE, offset szClassEdit, NULL,\
								WS_CHILD or WS_VISIBLE or WS_VSCROLL or ES_AUTOVSCROLL or ES_MULTILINE or ES_NOHIDESEL or ES_WANTRETURN or ES_LEFT,\
								0, 0, stRect_MainWin.right, eax,\
								hWinMain, NULL, hInstance, NULL
				mov		hWinEdit, eax
				invoke 	SendMessage, hWinEdit, EM_SETTEXTMODE, TM_PLAINTEXT, 0
				invoke 	SendMessage, hWinEdit, EM_EXLIMITTEXT, NULL, -1
				invoke  SendMessage, hWinEdit, EM_SETMARGINS, EC_RIGHTMARGIN or EC_LEFTMARGIN, 00050005h + 45
				invoke 	RtlZeroMemory, addr stCharFormat, sizeof stCharFormat
				mov		stCharFormat.cbSize, sizeof CHARFORMAT
				mov		stCharFormat.dwMask, CFM_BOLD or CFM_COLOR or CFM_FACE or CFM_ITALIC or CFM_SIZE or CFM_UNDERLINE or CFM_STRIKEOUT
				mov		stCharFormat.yHeight, 12 * 20
				invoke 	lstrcpy, addr stCharFormat.szFaceName, addr szFont
				invoke 	SendMessage, hWinEdit, EM_SETCHARFORMAT, SCF_ALL, addr stCharFormat
				invoke  SetWindowLong, hWinEdit, GWL_WNDPROC, addr _SubProcEdit
				mov		lpEditProc, eax
				
				;���ñ�����
				invoke 	SetWindowText, hWinMain, addr szCaptionMain
				invoke  SendMessage, hStatusBar, SB_SETTEXT, 0, NULL
				invoke 	SendMessage, hStatusBar, SB_SETTEXT, 1, NULL
				
				ret
				
_New			ENDP
;-----------------------------------------------------------------------
_Open			PROC	
				local @stOfn: OPENFILENAME
				local @stEs: EDITSTREAM
				local @szBuffer[256]: byte
				local @FileSize
				local	@LineNumber
				
				invoke 	RtlZeroMemory, addr @stOfn, sizeof @stOfn
				push		hWinMain
				pop		@stOfn.hwndOwner
				mov		@stOfn.lStructSize, sizeof OPENFILENAME
				mov		@stOfn.lpstrFilter, offset szFilter
				mov		@stOfn.lpstrFile, offset szFile
				mov		@stOfn.nMaxFile, MAX_PATH
				mov		@stOfn.lpstrFileTitle, offset szFileTitle
				mov		@stOfn.nMaxFileTitle, MAX_PATH
				mov		@stOfn.Flags, OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
				mov		@stOfn.lpstrDefExt, offset szDefaultExt 
				
				invoke 	GetOpenFileName, addr @stOfn
				.if eax
					;�ɹ����ļ�
					invoke	CreateFile, addr szFile, GENERIC_READ or GENERIC_WRITE,\
							FILE_SHARE_READ or FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
					.if		eax == INVALID_HANDLE_VALUE
							invoke	MessageBox, hWinMain, addr szCannotOpenTheFile, NULL, MB_OK or MB_ICONSTOP
							ret
					.endif
					push 	eax 
					.if 	hFile
							invoke 	CloseHandle, hFile
					.endif
					pop 	eax
					mov		hFile, eax
					mov		@stEs.dwCookie, TRUE
					mov		@stEs.dwError, NULL
					mov		@stEs.pfnCallback, offset _ProcStream
					invoke 	SendMessage, hWinEdit, EM_STREAMIN, SF_TEXT, addr @stEs
					invoke  SendMessage, hWinEdit, EM_SETMODIFY, FALSE, NULL

					;���ò���״̬����Ϣ
					invoke 	GetFileSize, hFile, NULL
					mov		@FileSize, eax
					invoke  SendMessage, hWinEdit, EM_GETLINECOUNT, 0, 0
					mov		@LineNumber, eax
					invoke 	wsprintf, addr @szBuffer, addr szFormat_1, @FileSize, @LineNumber
					invoke  SendMessage, hStatusBar, SB_SETTEXT, 0, addr @szBuffer
					invoke 	SendMessage, hStatusBar, SB_SETTEXT, 1, addr szFile

					;���ı�����
					invoke 	SetWindowText, hWinMain, @stOfn.lpstrFileTitle

				.endif	
				ret
				
_Open			ENDP	
;-----------------------------------------------------------------------
_Save			PROC
				local	@stEs: EDITSTREAM
				local @szBuffer[256]: byte
				local @FileSize
				local	@LineNumber
				
				invoke 	SetFilePointer, hFile, 0, 0, FILE_BEGIN
				invoke 	SetEndOfFile, hFile
				mov 	@stEs.dwCookie, FALSE
				mov 	@stEs.pfnCallback, offset _ProcStream
				invoke 	SendMessage, hWinEdit, EM_STREAMOUT, SF_TEXT, addr @stEs
				invoke 	SendMessage, hWinEdit, EM_SETMODIFY, FALSE, 0

				;���ò���״̬����Ϣ
				invoke 	GetFileSize, hFile, NULL
				mov		@FileSize, eax
				invoke  SendMessage, hWinEdit, EM_GETLINECOUNT, 0, 0
				mov		@LineNumber, eax
				invoke 	wsprintf, addr @szBuffer, addr szFormat_1, @FileSize, @LineNumber
				invoke  SendMessage, hStatusBar, SB_SETTEXT, 0, addr @szBuffer
				invoke 	SendMessage, hStatusBar, SB_SETTEXT, 1, addr szFile

				invoke 	MessageBox, hWinMain, offset szSaveSucceed, offset szNotice, MB_OK
				ret
				
_Save			ENDP	
;-----------------------------------------------------------------------	
_SaveAs			PROC
				local 	@stOfn: OPENFILENAME

				
				invoke 	RtlZeroMemory, addr @stOfn, sizeof @stOfn
				push	hWinMain
				pop		@stOfn.hwndOwner
				mov		@stOfn.lStructSize, sizeof OPENFILENAME
				mov		@stOfn.lpstrFilter, offset szFilter
				mov		@stOfn.lpstrFile, offset szFile
				mov		@stOfn.nMaxFile, MAX_PATH
				mov		@stOfn.lpstrFileTitle, offset szFileTitle
				mov		@stOfn.nMaxFileTitle, MAX_PATH
				mov		@stOfn.Flags, OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
				mov		@stOfn.lpstrDefExt, offset szDefaultExt 
				
				invoke 	GetSaveFileName, addr @stOfn
				.if		eax
					invoke	CreateFile, addr szFile, GENERIC_READ or GENERIC_WRITE,\
							FILE_SHARE_READ or FILE_SHARE_WRITE, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
					.if		eax == INVALID_HANDLE_VALUE
							invoke	MessageBox, hWinMain, addr szCannotOpenTheFile, NULL, MB_OK or MB_ICONSTOP
							mov		eax, FALSE
							ret
					.endif
					push 	eax 
					.if 	hFile
							invoke 	CloseHandle, hFile
					.endif
					pop 	eax
					mov		hFile, eax
					call 	_Save

					;�ɹ���ʾ
					invoke 	MessageBox, hWinMain, offset szSaveSucceed, offset szNotice, MB_OK
				.endif

				mov 	eax, TRUE
				
				ret
				
_SaveAs			ENDP
;-----------------------------------------------------------------------
_Quit			PROC
				invoke _CheckModify
				.if eax
					invoke 	DestroyWindow, hWinMain
					invoke 	PostQuitMessage, NULL
				.endif
				ret
				
_Quit			ENDP
;-----------------------------------------------------------------------
_FindReplace	PROC
				local	@stFtEx: FINDTEXTEX
				
				invoke 	SendMessage, hWinEdit, EM_EXGETSEL, 0, addr @stFtEx.chrg
				.if		stFr.Flags & FR_DOWN
						push	@stFtEx.chrg.cpMax
						pop 	@stFtEx.chrg.cpMin
				.endif
				mov 	@stFtEx.chrg.cpMax, -1
				
				mov 	@stFtEx.lpstrText, offset szFindWhat
				mov     ecx, stFr.Flags
				and 	ecx, FR_MATCHCASE or FR_DOWN or FR_WHOLEWORD
				
				invoke	SendMessage, hWinEdit, EM_FINDTEXTEX, ecx, addr @stFtEx
				.if 	eax == -1
						invoke	MessageBox, NULL, addr szNotFound, addr szNotice, MB_OK
						ret
				.endif
				invoke	SendMessage, hWinEdit, EM_EXSETSEL, 0, addr @stFtEx.chrgText
				invoke	SendMessage, hWinEdit, EM_SCROLLCARET, NULL, NULL
				.if		stFr.Flags & FR_REPLACE
						invoke	SendMessage, hWinEdit, EM_REPLACESEL, TRUE, addr szReplaceWith
				.endif
				.if		stFr.Flags & FR_REPLACEALL 
						invoke 	SendMessage, hWinEdit, WM_SETTEXT, 0, addr szReplaceWith
				.endif
				ret
				
_FindReplace	ENDP
;-----------------------------------------------------------------------
_SetFont PROC _lpszFont,_dwFontSize,_dwColor
		local	@stCf:CHARFORMAT

		invoke	RtlZeroMemory,addr @stCf,sizeof @stCf
		mov	@stCf.cbSize,sizeof @stCf
		mov	@stCf.dwMask,CFM_SIZE or CFM_FACE or CFM_BOLD or CFM_COLOR
		push _dwColor
		pop @stCf.crTextColor
		push	_dwFontSize
		pop	@stCf.yHeight
		mov	@stCf.dwEffects,0
		invoke	lstrcpy,addr @stCf.szFaceName,_lpszFont
		invoke	SendMessage,hWinEdit,EM_SETTEXTMODE,1,0
		invoke	SendMessage,hWinEdit,EM_SETCHARFORMAT,SCF_ALL,addr @stCf

		ret
_SetFont ENDP
;-----------------------------------------------------------------------
_ChooseFont			PROC
				local 	@stCf: CHOOSEFONT
				
				pushad
				invoke 	RtlZeroMemory, addr @stCf, sizeof @stCf
				mov		@stCf.lStructSize, sizeof @stCf
				push		hWinMain
				pop		@stCf.hwndOwner
				mov		@stCf.lpLogFont, offset stLogFont
				push		szFontColors
				pop		@stCf.rgbColors
				mov		@stCf.Flags, CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT or CF_EFFECTS
				
				invoke	ChooseFont, addr @stCf
				.if			eax
							mov eax,@stCf.iPointSize
							shl eax,1
							invoke _SetFont,addr stLogFont.lfFaceName,eax,@stCf.rgbColors
				.endif
				popad
				
				ret		
_ChooseFont			ENDP	
;-----------------------------------------------------------------------
_Date 			PROC
				invoke GetLocalTime ,ADDR stSystemTime

				mov ebx, offset stTimeString

				mov ax, stSystemTime.wYear
				mov dx, 0
				mov cx, 1000
				div cx
				add al, 48
				mov [ebx], al
				inc ebx
				mov ax, dx
				mov dx, 0
				mov cx, 100
				div cx
				add al, 48
				mov [ebx], al
				inc ebx
				mov ax, dx
				mov dx, 0
				mov cx, 10
				div cx
				add al, 48
				mov [ebx], al
				inc ebx
				mov ax, dx
				add al, 48
				mov [ebx], al
				inc ebx

				mov al, 47
				mov [ebx], al
				inc ebx

				mov ax, stSystemTime.wMonth
				mov dx, 0
				mov cx, 10
				div cx
				add al, 48
				mov [ebx], al
				inc ebx
				mov ax, dx
				add al, 48
				mov [ebx], al
				inc ebx

				mov al, 47
				mov [ebx], al
				inc ebx

				mov ax, stSystemTime.wDay
				mov dx, 0
				mov cx, 10
				div cx
				add al, 48
				mov [ebx], al
				inc ebx
				mov ax, dx
				add al, 48
				mov [ebx], al
				inc ebx
				invoke SendMessage, hWinEdit,EM_REPLACESEL,0,addr stTimeString

				ret
_Date			ENDP
;-----------------------------------------------------------------------
;���ڹ���
;-----------------------------------------------------------------------
_ProcWinMain PROC USES ebx edi esi,hWnd,uMsg,wParam,lParam 
	;wParam������16λ��֪ͨ�룬��16λ������ID  lParam�Ƿ���WM_COMMAND��Ϣ���Ӵ��ھ��
	;�˵���Ϣ��֪ͨ����0�����ټ���Ϣ��֪ͨ����1
	;���ڲ˵��ͼ��ټ�������WM_COMMAND��Ϣ��lParam��ֵΪ0
	local @stPos: POINT
	local @stRange:CHARRANGE
	mov	eax,uMsg
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	.if	eax == WM_CREATE
				;��ʼ����ע����Һ��滻
				invoke 	RtlZeroMemory, addr stFr, sizeof stFr
				mov		stFr.lStructSize, sizeof FINDREPLACE
				push	hWnd
				pop		stFr.hwndOwner
				mov		stFr.Flags, FR_DOWN
				;��δ������ʾ��Ϣ����
				mov		stFr.lpstrFindWhat, offset szFindWhat
				mov		stFr.wFindWhatLen, sizeof szFindWhat
				mov		stFr.lpstrReplaceWith, offset szReplaceWith
				mov		stFr.wReplaceWithLen, sizeof szReplaceWith
				invoke 	RegisterWindowMessage, addr szFindReplace
				mov		iWM_FINDREPLACE, eax
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
				;�����ı�����	
				invoke	CreateWindowEx,WS_EX_OVERLAPPEDWINDOW,OFFSET szClassEdit,NULL,\
					WS_CHILD or WS_VISIBLE or WS_VSCROLL or ES_AUTOVSCROLL or ES_MULTILINE or ES_NOHIDESEL or ES_WANTRETURN or ES_LEFT,\
					0, 0, 0, 0, hWnd, NULL, hInstance, NULL
				mov		hWinEdit, eax
				invoke	SendMessage, hWinEdit, EM_SETTEXTMODE, TM_PLAINTEXT, 0
				invoke	SendMessage, hWinEdit, EM_SETEVENTMASK, 0, ENM_MOUSEEVENTS
				invoke	SendMessage, hWinEdit, EM_EXLIMITTEXT, NULL, -1
				invoke	SendMessage, hWinEdit, EM_SETMARGINS, EC_RIGHTMARGIN or EC_LEFTMARGIN, 00050000h + 45
				invoke	RtlZeroMemory, addr stCharFormat, sizeof stCharFormat  
				mov		stCharFormat.cbSize, sizeof CHARFORMAT
				mov		stCharFormat.dwMask, CFM_BOLD or CFM_COLOR or CFM_FACE or CFM_ITALIC or CFM_SIZE or CFM_UNDERLINE or CFM_STRIKEOUT
				mov		stCharFormat.yHeight, 12 * 20
				invoke	SendMessage, hWinEdit, EM_SETCHARFORMAT, SCF_ALL, addr stCharFormat
				invoke	lstrcpy, addr stCharFormat.szFaceName, addr szFont
				invoke  SetWindowLong, hWinEdit, GWL_WNDPROC, addr _SubProcEdit
				mov		lpEditProc, eax

				invoke GetSubMenu,hMainMenu,1
				mov hSubMenu,eax
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	.elseif	eax == WM_COMMAND
				;�������˵�ѡ��
				mov eax,wParam
				.if ax == IDM_NEW
					invoke	_CheckModify
					.if	eax
						invoke _New
					.endif

				.elseif ax == IDM_OPEN
					invoke _CheckModify
					.if	eax
						invoke _Open
					.endif

				.elseif ax == IDM_SAVE
					.if !hFile
						call _SaveAs
					.else
						call _Save
					.endif

				.elseif ax == IDM_SAVEAS
					call	_SaveAs

				.elseif ax == IDM_PAGESET
					call _PageSet

				.elseif ax == IDM_QUIT
					invoke _Quit

				.elseif ax == IDM_UNDO 
					invoke SendMessage, hWinEdit, EM_UNDO, 0, 0

				.elseif ax == IDM_REDO
					invoke SendMessage, hWinEdit, EM_REDO, 0, 0

				.elseif ax == IDM_CUT
					invoke SendMessage, hWinEdit, WM_CUT, 0, 0

				.elseif ax == IDM_COPY
					invoke SendMessage, hWinEdit, WM_COPY, 0, 0

				.elseif ax == IDM_PASTE
					invoke SendMessage, hWinEdit, WM_PASTE, 0, 0

				.elseif ax == IDM_DELETE
					invoke SendMessage, hWinEdit, WM_CLEAR, 0, 0

				.elseif ax == IDM_FIND
					and stFr.Flags, not FR_DIALOGTERM
					invoke FindText, addr stFr
					mov hFind, eax

				.elseif ax == IDM_REPLACE 
					and stFr.Flags, not FR_DIALOGTERM
					invoke ReplaceText, addr stFr
					mov hReplace, eax

				.elseif ax == IDM_ALL 
					mov @stRange.cpMin, 0
					mov @stRange.cpMax, -1
					invoke SendMessage, hWinEdit, EM_EXSETSEL, 0, addr @stRange

				.elseif ax == IDM_DATE
					call _Date

				.elseif ax == IDM_FONT
					call _ChooseFont
					call _ShowLineNum

				.elseif ax == IDM_HELP
					invoke  MessageBox, hWinMain,addr szHelp, addr szHelpTitle, MB_OK

				.elseif ax == IDM_ABOUT
					invoke  MessageBox, hWinMain,addr szAbout, addr szAboutTitle, MB_OK
				.endif		
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	.elseif	eax == WM_RBUTTONDOWN
				invoke  GetCursorPos, addr @stPos
				invoke  TrackPopupMenu, hSubMenu, TPM_LEFTALIGN, @stPos.x, @stPos.y, NULL, hWinEdit, NULL
;-----------------------------------------------------------
	;!!!��λ����û���������/�滻ҳ�沢ѡ��ȡ��ʱ����......��֪������������ô�ж��û��Ƿ�ѡ��ȡ��?
	.elseif eax == iWM_FINDREPLACE
				.if stFr.Flags & FR_DIALOGTERM
				;�û�����ȡ�����Ի���ر�
				.else
					call _FindReplace
				.endif
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    .elseif eax == WM_SIZE
				invoke 	MoveWindow, hStatusBar, 0, 0, 0, 0, TRUE
				invoke 	GetClientRect, hWnd, addr stRect_MainWin
				mov		ebx, stRect_MainWin.bottom
				sub		ebx, 0018h
				invoke 	MoveWindow, hWinEdit, 0, 0, stRect_MainWin.right, ebx, TRUE
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	.elseif	eax ==	WM_ACTIVATE
			mov	eax,wParam
			.if	(ax ==	WA_CLICKACTIVE ) || (ax == WA_ACTIVE)
				invoke	SetFocus,hWinEdit
			.endif
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	.elseif	eax == WM_CLOSE
				call _Quit
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	.else
				invoke DefWindowProc, hWnd, uMsg, wParam,lParam
				ret
	.endif
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	xor eax,eax
	ret
_ProcWinMain ENDP
;-----------------------------------------------------------------------
_WinMain	PROC
	local @stWndClass: WNDCLASSEX
	local @stMsg: MSG
	local @hAccelerator: DWORD
	local @hRichEdit: DWORD
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;ע���ı��༭��
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	invoke	LoadLibrary,addr szDllRiched20
	mov		@hRichEdit,eax
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;�õ����ھ��������˵��ͼ��ټ�
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	invoke	GetModuleHandle,NULL
	mov		hInstance,eax
	invoke	LoadMenu,hInstance,IDM_MAIN
	mov		hMainMenu,eax
	invoke	LoadAccelerators,hInstance,IDA_MAIN
	mov		@hAccelerator,eax
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;ע�ᴰ����
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	invoke	RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
	invoke	LoadCursor,0, IDC_ARROW
	mov		@stWndClass.hCursor, eax
	invoke	LoadIcon,0,IDI_APPLICATION
	mov		@stWndClass.hIcon, eax
	push	hInstance
	pop		@stWndClass.hInstance
	mov		@stWndClass.cbSize, sizeof WNDCLASSEX
	mov		@stWndClass.style, CS_HREDRAW or CS_VREDRAW
	mov		@stWndClass.lpfnWndProc, offset _ProcWinMain
	mov		@stWndClass.hbrBackground, COLOR_WINDOW+1
	mov		@stWndClass.lpszClassName, offset szClassName
	invoke	RegisterClassEx, addr @stWndClass
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;��������ʾ����
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	invoke	CreateWindowEx,WS_EX_CLIENTEDGE,\
				offset szClassName,offset szCaptionMain,\
				WS_OVERLAPPEDWINDOW ,\
				100,100,600,400,\
				NULL,hMainMenu,hInstance,NULL
	mov		hWinMain,eax
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;����״̬��
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	invoke	CreateStatusWindow,WS_CHILD or WS_VISIBLE or SBARS_SIZEGRIP,NULL,hWinMain,IDCC_STATUSBAR
	mov		hStatusBar,eax
	invoke	SendMessage, hStatusBar, SB_SETPARTS, 2, offset dwStatusWidth
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;��ʾ�����´���
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	invoke	ShowWindow,hWinMain,SW_SHOWNORMAL
	invoke	UpdateWindow,hWinMain
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;��Ϣѭ��
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	.while TRUE
				invoke	GetMessage, addr @stMsg, NULL,0,0
				.break .if eax == 0
				invoke	TranslateAccelerator,hWinMain,@hAccelerator,addr @stMsg
				.if eax == 0
					invoke	TranslateMessage, addr @stMsg
					invoke	DispatchMessage, addr @stMsg
				.endif
	.endw
	invoke	FreeLibrary, @hRichEdit
	ret
_WinMain ENDP
;-----------------------------------------------------------------------
main PROC
	call	_WinMain
	invoke	ExitProcess, NULL
main ENDP
;-----------------------------------------------------------------------
END main