include \masm64\include64\masm64rt.inc  ; ����������


.data       ; ������ ������ 
hInstance dq ?  ; ���������� ���������
hWnd      dq ?		; ����� ����
hCursor   dq ?		; ����� �������
sWid      dq ?		; ������ ����
sHgt      dq ?		; ������ ����

hIcon     dq ?  ; ���������� ������
hBmp      dq ?
hStatic   dq ?

szFileName1 db "WReg64-11.exe",0

.code            ; ������ ����
entry_point proc
GdiPlusBegin     ; initialise GDIPlus
mov hInstance, rv(GetModuleHandle,0)                   ; ��������� � ���������� ����������a ���������
mov hIcon,rv(LoadImage,hInstance,10,IMAGE_ICON,128,128,LR_DEFAULTCOLOR)  ; �������� � ���������� ����������a ������
mov hBmp, rv(ResImageLoad,20)
invoke DialogBoxParam,hInstance,100,0,ADDR main,hIcon
GdiPlusEnd       ; GdiPlus cleanup
invoke ExitProcess,0
ret
entry_point endp

main proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD


IDI_ICON EQU 1001

MSGBOXPARAMSA STRUCT
cbSize DWORD ?,?
hwndOwner QWORD ?
hInstance QWORD ?
lpszText QWORD ?
lpszCaption QWORD ?
dwStyle DWORD ?,?
lpszIcon QWORD ?
dwContextHelpId QWORD ?
lpfnMsgBoxCallback QWORD ?
dwLanguageId DWORD ?,?
MSGBOXPARAMSA ENDS

.data ; ������ ������
params MSGBOXPARAMSA <>  
buf1 dd 0,0

.code ; ������ ����
.switch uMsg
.case WM_INITDIALOG ; ��������� � �������� ����. ����

        invoke SendMessage,hWin,WM_SETICON,1,lParam

mov hStatic, rv(GetDlgItem,hWin,102)
        invoke SendMessage,hStatic,STM_SETIMAGE,IMAGE_ICON,lParam
        .return TRUE
.case WM_COMMAND ; ��������� �� ���� ��� ������
.switch wParam

.case 101  ; �����
rcall SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL

.case 104
invoke WinExec,addr szFileName1,SW_SHOW;

.endsw
.case WM_CLOSE           ; ���� ���� ��������� � �������� ����
invoke EndDialog,hWin,0  
.endsw
xor rax, rax
ret
main endp
end


