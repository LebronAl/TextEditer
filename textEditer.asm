.386
.model flat, stdcall
option casemap:none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;Include �ļ�����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include         windows.inc
include         gdi32.inc
includelib      gdi32.lib
include         user32.inc
includelib      user32.lib
include         kernel32.inc
includelib      kernel32.lib
include         comctl32.inc
includelib      comctl32.lib
include         comdlg32.inc
includelib      comdlg32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;Equ ��ֵ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;Menu
IDM_MAIN         equ           1000h

IDM_NEW          equ           1101h
IDM_OPEN         equ           1102h
IDM_SAVE          equ           1103h
IDM_SAVEAS      equ           1104h
IDM_PAGESET     equ          1105h
IDM_QUIT          equ           1106h

IDM_UNDO        equ           1201h
IDM_CUT            equ           1202h
IDM_COPY         equ            1203h
IDM_PASTE         equ           1204h
IDM_DELETE        equ           1205h
IDM_FIND           equ           1206h
IDM_FINDNEXT   equ           1207h
IDM_REPLACE     equ            1208h
IDM_TURN          equ            1209h
IDM_ALL             equ            1210h
IDM_DATE          equ            1211h

IDM_FONT         equ             1301h

IDM_HELP          equ             1401h
IDM_ABOUT       equ             1402h

;Accelerators 	
IDA_MAIN	      equ           2000h
;Statusbar
IDCC_STATUSBAR    equ      3000h
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  
.data?
	hInstance dd ?
	hWinMain dd ?
	hStatusBar dd ?
	hWinEdit dd ?
	hMainMenu dd ?
	hSubMenu dd ?

.const
	szClassName db 'MyTextEditer',0
	szCaptionMain db 'TextEditer++',0
	szText db "Let's do something!",0

	szDllRiched20    db       'riched20.dll',0
	szClassEdit         db       'RichEdit20A',0
	szFont               db        '����',0
	szTxt                 db         '�޸�ʽ�ı�',0

	dwStatusWidth dd          200,500,300,-1

	szAboutTitle     db          '����TextEditer++����Ϣ',0
	szAbout            db         '����Win32���ı��༭��',0dh,0ah,0dh,\
										  '�����ߣ�̷���� ¬���� ���Ļ�',0dh,0ah,0

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;�����
.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Init PROC
	local @stCharFormat: CHARFORMAT
	
	invoke CreateWindowEx,WS_EX_OVERLAPPEDWINDOW,OFFSET szClassEdit,NULL,\
	WS_CHILD or WS_VISIBLE or WS_VSCROLL or ES_AUTOVSCROLL or ES_MULTILINE or ES_NOHIDESEL or ES_WANTRETURN or ES_LEFT,\
	0,0,0,0,hWinMain,NULL,hInstance,NULL
	mov     hWinEdit, eax
	invoke  SendMessage, hWinEdit, EM_SETTEXTMODE, TM_PLAINTEXT, 0
	invoke  SendMessage, hWinEdit, EM_SETEVENTMASK, 0, ENM_MOUSEEVENTS
    invoke  SendMessage, hWinEdit, EM_SETMARGINS, EC_RIGHTMARGIN or EC_LEFTMARGIN, 00050000h     ;���кŵ�ʱ��ø�
	invoke  RtlZeroMemory, addr @stCharFormat, sizeof @stCharFormat  
    invoke  SendMessage, hWinEdit, EM_EXLIMITTEXT, NULL, -1
    mov     @stCharFormat.cbSize, sizeof @stCharFormat
    mov     @stCharFormat.dwMask, CFM_BOLD or CFM_COLOR or CFM_FACE or CFM_ITALIC or CFM_SIZE or CFM_UNDERLINE or CFM_STRIKEOUT
    mov     @stCharFormat.yHeight, 12 * 20
	invoke  SendMessage, hWinEdit, EM_SETCHARFORMAT, SCF_ALL, addr @stCharFormat
    invoke  lstrcpy, addr @stCharFormat.szFaceName, addr szFont

	ret
_Init ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_PageSet PROC
	local @stPs:PAGESETUPDLG
	invoke RtlZeroMemory,addr @stPs,sizeof @stPs
	mov @stPs.lStructSize,sizeof @stPs
	push hWinMain
	pop @stPs.hwndOwner
	invoke PageSetupDlg,addr @stPs
	ret
_PageSet ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Quit  PROC
				invoke DestroyWindow, hWinMain
				invoke PostQuitMessage,NULL
				ret
_Quit  ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;���ڹ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcWinMain PROC USES ebx edi esi,hWnd,uMsg,wParam,lParam 
    ;wParam������16λ��֪ͨ�룬��16λ������ID  lParam�Ƿ���WM_COMMAND��Ϣ���Ӵ��ھ��
    ;�˵���Ϣ��֪ͨ����0�����ټ���Ϣ��֪ͨ����1
    ;���ڲ˵��ͼ��ټ�������WM_COMMAND��Ϣ��lParam��ֵΪ0
	local @stRect:RECT
	local @stPos: POINT
	mov eax,uMsg
;**********************************************************************************
	.if	eax == WM_CREATE
				push hWnd
				pop hWinMain
				call _Init
				invoke GetSubMenu,hMainMenu,1
				mov hSubMenu,eax
;**********************************************************************************
	.elseif   eax == WM_COMMAND
				mov eax,wParam
				.if ax == IDM_NEW

				.elseif ax == IDM_OPEN

				.elseif ax == IDM_SAVE

				.elseif ax == IDM_SAVEAS

				.elseif ax == IDM_PAGESET
					call _PageSet
				.elseif ax == IDM_QUIT
					call _Quit
				.elseif ax == IDM_UNDO 

				.elseif ax == IDM_PASTE  

				.elseif ax == IDM_DELETE 

				.elseif ax == IDM_FIND

				.elseif ax == IDM_FINDNEXT

				.elseif ax == IDM_REPLACE 

				.elseif ax == IDM_TURN

				.elseif ax == IDM_ALL 

				.elseif ax == IDM_DATE

				.elseif ax == IDM_FONT

				.elseif ax == IDM_HELP

				.elseif ax == IDM_ABOUT
						invoke  MessageBox, hWinMain,addr szAbout, addr szAboutTitle, MB_OK
				.endif		
;**********************************************************************************
	.elseif	eax == WM_RBUTTONDOWN
				invoke  GetCursorPos, addr @stPos
				invoke  TrackPopupMenu, hSubMenu, TPM_LEFTALIGN, @stPos.x, @stPos.y, NULL, hWinEdit, NULL
;**********************************************************************************
    .elseif    eax == WM_SIZE
	            invoke  MoveWindow, hStatusBar, 0, 0, 0, 0, TRUE
                invoke  GetClientRect, hWnd, addr @stRect
                mov     ebx, @stRect.bottom

                sub      ebx, 0018h
                invoke  MoveWindow, hWinEdit, 0, 0, @stRect.right, ebx, TRUE
;**********************************************************************************
	.elseif	eax == WM_CLOSE
				call _Quit
;**********************************************************************************
	.else
				invoke DefWindowProc, hWnd, uMsg, wParam,lParam
				ret
	.endif
;**********************************************************************************
	xor eax,eax
	ret
_ProcWinMain ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_WinMain	PROC
	local @stWndClass:WNDCLASSEX
	local @stMsg:MSG
	local @hAccelerator: DWORD
	local @hRichEdit: DWORD
;**********************************************************************************
;ע���ı��༭��
;**********************************************************************************
	invoke LoadLibrary,addr szDllRiched20
	mov @hRichEdit,eax
;**********************************************************************************
;�õ����ھ��������˵��ͼ��ټ�
;**********************************************************************************
	invoke GetModuleHandle,NULL
	mov hInstance,eax
	invoke LoadMenu,hInstance,IDM_MAIN
	mov hMainMenu,eax
	invoke LoadAccelerators,hInstance,IDA_MAIN
	mov @hAccelerator,eax
;**********************************************************************************
;ע�ᴰ����
;**********************************************************************************
	invoke RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
	invoke LoadCursor,0, IDC_ARROW
	mov @stWndClass.hCursor, eax
	invoke LoadIcon,0,IDI_APPLICATION
	mov @stWndClass.hIcon, eax
	push hInstance
	pop @stWndClass.hInstance
	mov @stWndClass.cbSize, sizeof WNDCLASSEX
	mov @stWndClass.style, CS_HREDRAW or CS_VREDRAW
	mov @stWndClass.lpfnWndProc, offset _ProcWinMain
	mov @stWndClass.hbrBackground, COLOR_WINDOW+1
	mov @stWndClass.lpszClassName, offset szClassName
	invoke RegisterClassEx, addr @stWndClass
;**********************************************************************************
;��������ʾ����
;**********************************************************************************
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,\
				offset szClassName,offset szCaptionMain,\
				WS_OVERLAPPEDWINDOW ,\
				100,100,600,400,\
				NULL,hMainMenu,hInstance,NULL
	mov hWinMain,eax
;**********************************************************************************
;����״̬��
;**********************************************************************************
	invoke CreateStatusWindow,WS_CHILD or WS_VISIBLE or SBARS_SIZEGRIP,NULL,hWinMain,IDCC_STATUSBAR
	mov hStatusBar,eax
	invoke  SendMessage, hStatusBar, SB_SETPARTS, 4, offset dwStatusWidth
;**********************************************************************************
;��ʾ�����´���
;**********************************************************************************
	invoke ShowWindow,hWinMain,SW_SHOWNORMAL
	invoke UpdateWindow,hWinMain
;**********************************************************************************
;��Ϣѭ��
;**********************************************************************************
	.while TRUE
				invoke GetMessage, addr @stMsg, NULL,0,0
				.break .if eax==0
				invoke TranslateAccelerator,hWinMain,@hAccelerator,addr @stMsg
				.if eax == 0
					invoke TranslateMessage, addr @stMsg
					invoke DispatchMessage, addr @stMsg
				.endif
	.endw
	invoke  FreeLibrary, @hRichEdit
	ret
_WinMain ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
main PROC
	call _WinMain
	invoke ExitProcess, NULL
main ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
END main


