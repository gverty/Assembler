include \masm64\include64\masm64rt.inc ; ���������, ���������, �������...

.data
   BitMap db "nestandart.bmp", 0
   width_ dq ?
   height dq ?
   xCtr dq ?
   yCtr dq ?
   pzsFiles db "meow.wav", 0
   AppName db "App", 0
   ClassName db "Class", 0
   isCaptures db 0
   hitResult dq ?
   hInstance HINSTANCE ?
   hBitmap HBITMAP ?

.code 			                   
entry_point proc
mov hInstance,rv(GetModuleHandle,0) ; ��������� � ���������� ����������a ���������
   invoke WinMain,hInstance,SW_SHOWDEFAULT
   invoke ExitProcess,rax ; ����������� ���������� �� Windows � ������������ ��������
entry_point endp
   
WinMain proc hInst:HINSTANCE, CmdShow:DWORD
LOCAL wc:WNDCLASSEX ; �������������� ����� ��� ��������� ������ ����
LOCAL msg:MSG ; �������������� ����� ��� ��������� MSG
LOCAL hwnd:HWND ; �������������� ����� ��� ���������� ����

   push hInstance     ; ���������� � ����� ����������� ���������
   pop wc.hInstance   ; ����������� ����������� � ���� ���������
   mov wc.cbSize,SIZEOF WNDCLASSEX ; ���������� ������ ��������� WNDCLASSEX
   mov wc.style,CS_HREDRAW or CS_VREDRAW  ; C���� � ��������� ����
   lea rax,WndProc              ; ��������� ������ ��������� WndProc
   mov wc.lpfnWndProc,rax                ; ����� ��������� WndProc
   mov wc.hbrBackground,COLOR_WINDOW+1   ; ���� ����
   invoke GetStockObject,WHITE_BRUSH     ; ������ ��������� �����
   mov wc.hbrBackground,rax       ; ���� ���������� ����
   mov wc.lpszMenuName,0          ; ��� ������� ����
   lea rax, ClassName      ; ��������� ������ ���������� � ������ ������
   mov wc.lpszClassName,rax       ; ��� ������
   invoke LoadIcon, NULL, IDI_APPLICATION ; �������� ������������ �����������
   mov wc.hIcon, rax       ; ���������� "�������" �����������
   mov wc.hIconSm, rax     ; ���������� ����������� ���������� ������
   invoke LoadCursor,0,IDC_ARROW ; �������� �������
   mov wc.hCursor,rax      ; ������
   mov wc.cbClsExtra,0     ; ���������� ���. ������ ��� ��������� ������
   mov wc.cbWndExtra,0     ; ���������� ���. ������ ��� ��������� ����
   invoke RegisterClassEx,ADDR wc ; ������� ����������� ������ ����

   ; ��������� �������� � ������������� ����
   mov width_, 300
   mov height, 206
   invoke GetSystemMetrics,SM_CXSCREEN
   shr rax,2
   mov rbx,rax
   mov rax,width_
   shr rax,2
   sub rbx,rax
   mov xCtr,rbx
   invoke GetSystemMetrics, SM_CYSCREEN
   shr rax,2
   mov rbx,rax
   mov rax,height
   shr rax,2
   sub rbx,rax
   mov yCtr,rbx

   invoke CreateWindowEx, WS_EX_TOOLWINDOW, ADDR ClassName,\ ; ����� � ����� ����� ������
      ADDR AppName, WS_POPUP,\  ; ����� ����� ���� � ������� ����� ����
          xCtr,yCtr,width_,height,0,0,hInst,0 ; ���������� ���� � �����������
   mov hwnd,rax ; ���������� ����������� ����
mov hBitmap,rv(LoadImage,hInstance,addr BitMap,IMAGE_BITMAP,0,0,LR_LOADFROMFILE)
   invoke ShowWindow,hwnd,SW_SHOWNORMAL ; ��������� ����
m0: ; WHILE TRUE. ������� ���� ���������
   invoke GetMessage,ADDR msg,0,0,0 ; ������ ���������
   or eax, eax ; ������������ ���������
   jz Quit ; ������� �� ����� Quit, ���� ��� = 0 
   invoke DispatchMessage, ADDR msg ; ����������� ��������� � WndProc
   jmp m0 ; ��������� ����� ������������� ���������
Quit:
   mov rax, msg.wParam
   ret ; ����������� �� ��������� WinMain
WinMain endp ; ��������� ��������� WinMain

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
LOCAL hdc:HDC        ; �������������� ����� ��� ���������� ����
LOCAL ps:PAINTSTRUCT ; �������������� ����� ��� ��������� PAINTSTRUCT
LOCAL rect:RECT      ; �������������� ����� ��� ��������� RECT
LOCAL bitmap : BITMAP
LOCAL hdcMem : HDC
LOCAL oldBitmap : HANDLE  ; HGDIOBJ = HANDLE. ��������� ����������� �����������

.switch uMsg
.case WM_DESTROY        ; IF uMsg == WM_DESTROY (����������� ����)
   invoke PostQuitMessage,0 ; �������� ��������� WM_QUIT
   
.case WM_NCRBUTTONDOWN ; IF uMsg == WM_NCRBUTTONDOWN (������ ������ ������ ���� � ������������ �������)
   invoke SendMessage,hWnd,WM_DESTROY,0,0 ; �������� ��������� �� ����������� ����
   invoke Sleep,1500

.case WM_NCHITTEST ; IF uMsg == WM_NCHITTEST (���� ������� ������ ���� � ������������ �������)
   invoke DefWindowProc, hWnd, uMsg, wParam, lParam
   ; ��������������� ������� � ���������� ������� � ������������
   .if rax == 1 ; 1 = HTCLIENT
   mov rax, 2   ; 2 = HTCAPTION
   ret
   .endif
   ret

.case WM_PAINT    ; IF uMsg == WM_PAINT (����������� ������� ����)
   invoke GetWindowLong,hWnd,GWL_EXSTYLE ; ��������� ������ � ����������� ����� ����
   or eax,WS_EX_LAYERED    ; ���������� � ������������ ������ WS_EX_LAYERED
   invoke SetWindowLong,hWnd,GWL_EXSTYLE,eax ; ��������� ������ ����� ����

   invoke SetLayeredWindowAttributes,hWnd,0,0,LWA_COLORKEY ; ��������� ������������ ��� ����
  mov hdc,rv(BeginPaint,hWnd,ADDR ps)    ; ����� ��������� � ���������� ���������
  mov hdcMem,rv(CreateCompatibleDC,hdc)  ; �������� ��������� ���������� � ������
  
  mov oldBitmap,rv(SelectObject,hdcMem,hBitmap) ; ����� ������ �����������
   
   invoke GetObject,hBitmap,sizeof bitmap,addr bitmap
   invoke BitBlt,hdc,0,0,bitmap.bmWidth,bitmap.bmHeight,hdcMem,0,0,SRCCOPY ; ����������� �����������
   invoke SelectObject,hdcMem,oldBitmap
   invoke DeleteDC, hdcMem             ; ������������ ���������

   invoke GetClientRect,hWnd,ADDR rect ; ���������� ��������� RECT (������� ����)
   invoke EndPaint,hWnd,ADDR ps        ; ��������� ���������
   
.default   ; �����
   invoke DefWindowProc,hWnd,uMsg,wParam,lParam ; ����� ������� ��������� ��-���������
   ret     ; ����������� �� ���������
.endsw     ; End switch

   xor eax, eax
   ret       ; ����������� �� ���������
WndProc endp ; ��������� ��������� WndProc
end          ; ��������� ���������
