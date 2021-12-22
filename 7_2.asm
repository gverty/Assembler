include \masm64\include64\masm64rt.inc

.data
    hInstance dq ? ; ���������� ��������
    hWnd      dq ? ; ���������� ����
    hIcon     dq ? ; ���������� ������
    hCursor   dq ? ; ���������� �������
    sWid      dq ? ; ������ �������� (�����. �������� �� x)
    sHgt      dq ? ; ������ �������� (�����. �������� �� y)

    wid       dq ?
    hgt       dq ?
    lft       dq ? ; ���. ���������� ���������� � ����� 
    top       dq ? ; � ���������� ������ �� ����� ���. ����. 

    classname db "template_class",0
    caption db "������������ ������ 7-2",0
    AppName db "������ ������ ������� � ������������ ������� ���� �������� � ��� ����������� � ����� � �������������� ����������� ����� � ������ �� ��� ���, ���� �� ����� ������ ������������ �������",0

.code
entry_point proc
    mov hInstance,rv(GetModuleHandle,0)       ; ��������� � ���������� ����������a ��������
    mov hIcon,  rv(LoadIcon,hInstance,10)     ; �������� � ���������� ����������a ������
    mov hCursor,rv(LoadCursor,0,IDC_ARROW)    ; �������� ������� � ����������
    mov sWid,rv(GetSystemMetrics,SM_CXSCREEN) ; ��������� ���. �������� �� � ��������
    mov sHgt,rv(GetSystemMetrics,SM_CYSCREEN) ; ��������� ���. �������� �� y ��������
    call main
    invoke ExitProcess,0
    ret
entry_point endp

main proc
    LOCAL wc  :WNDCLASSEX               ; ���������� ��������� ����������
    mov wc.cbSize,SIZEOF WNDCLASSEX     ; �����. ������ ���������
    mov wc.style,CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW ; ����� ����
    mov wc.lpfnWndProc,ptr$(WndProc)    ; ����� ��������� WndProc
    mov wc.cbClsExtra,0                 ; ���������� ������ ��� ��������� ������
    mov wc.cbWndExtra,0                 ; ���������� ������ ��� ��������� ����
    mrm wc.hInstance,hInstance          ; ���������� ���� ����������� � ���������
    mrm wc.hIcon,  hIcon                ; ����� ������
    mrm wc.hCursor,hCursor              ; ����� �������
    mrm wc.hbrBackground,0              ; ���� ����
    mov wc.lpszMenuName,0               ; ���������� ���� � ��������� � ������ ������� ����
    mov wc.lpszClassName,ptr$(classname); ��� ������
    mrm wc.hIconSm,hIcon
    invoke RegisterClassEx,ADDR wc      ; ����������� ������ ����
    mov wid, 500                        ; ������ ����������������� ���� � ��������
    mov hgt, 320                        ; ������ ����������������� ���� � ��������
    mov rax,sWid                        ; �����. �������� �������� �� x
    sub rax,wid                         ; ������ � = �(��������) - �(���� ������������)
    shr rax,1                           ; ��������� �������� �
    mov lft,rax 

    mov rax, sHgt                       ; �����. �������� �������� �� y
    sub rax, hgt ;
    shr rax, 1 ;
    mov top, rax ;
    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES, \
        ADDR classname,ADDR caption, \
        WS_OVERLAPPED or WS_VISIBLE or WS_SYSMENU,\
        lft,top,wid,hgt,0,0,hInstance,0
    mov hWnd,rax ; ���������� ����������� ����
    call msgloop
    ret
main endp

msgloop proc
    LOCAL msg  :MSG
    LOCAL pmsg :QWORD
    mov pmsg,ptr$(msg)                  ; ��������� ������ ��������� ���������
    jmp gmsg                            ; jump directly to GetMessage()
  mloop:
    invoke TranslateMessage,pmsg
    invoke DispatchMessage,pmsg         ; �������� �� ������������ � WndProc
  gmsg:
    test rax, rv(GetMessage,pmsg,0,0,0) ; ���� GetMessage �� ������ ����
    jnz mloop
    ret
msgloop endp

WndProc proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
LOCAL hdc:HDC                           ; �������������� ����� ��� ����������� ����
LOCAL ps:PAINTSTRUCT                    ; ��� ��������� PAINTSTRUCT
LOCAL rect:RECT                         ; ��� ��������� ��������� RECT

.switch uMsg
    .case WM_DESTROY ; ���� ���� ��������� ��� ����������� ����
        invoke PostQuitMessage,NULL

    .case WM_NCRBUTTONDOWN          ; ��������� �� ������ ����� � ������������ �������
        m1:
            invoke Sleep, 1
        .case WM_CHAR               ; ��������
            push wParam
            cmp wParam,97
            jae Move
            jmp _end
            jmp m1
            
        Move:
            add lft, 20
            invoke MoveWindow,hWin,lft,top,wid,hgt,TRUE

            _end:
            
    .endsw
    
invoke DefWindowProc,hWin,uMsg,wParam,lParam
ret
WndProc endp
end
