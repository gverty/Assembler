include \masm64\include64\masm64rt.inc
.data?
  hInstance dq ?
  hIcon     dq ?
  hIcon2 dq ?
  hIcon3 dq ?
  hIcon4 dq ?
  hImg2  dq ?;
  hImg3  dq ?;
  hImg4  dq ?;
.data

szRunDialog1 db "Win1.exe",0; running 1 dialog window
szRunFigure db "6_2.exe",0



szTitle5 db "Some information",0
szInf5 db "Сегодня нет времени, завтра не будет сил, а послезавтра не будет нас.Ничего не откладывайте живите сейчас",10,
"masm64 dev.",10,10,"for x64 OS",10,"ver. 14.12.2021",0

szTitleA db "Автор",0
szInfA db "cit 120e",10,10,"Kulish Pavlo Pavlovych",10,
"K",0

szFileName db "6_2.exe",0   ; название файла для вызова информации
szFileNameAuthor db "WReg64-11.exe"

.code
entry_point proc
 mov hInstance,rv(GetModuleHandle,0)
 mov hIcon,rv(LoadImage,hInstance,10,IMAGE_ICON,256,256,LR_DEFAULTCOLOR)
 invoke DialogBoxParam,hInstance,1000,0,ADDR main,hIcon
invoke ExitProcess,0
    ret
entry_point endp

main proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
.switch uMsg
.case WM_INITDIALOG
invoke SendMessage,hWin,WM_SETICON,1,lParam ; значок для диалога
invoke SendMessage,rv(GetDlgItem,hWin,1001),\ ; значок в клиентской области
               STM_SETIMAGE,IMAGE_ICON,lParam
.case WM_COMMAND
   .switch wParam


     .case 1015       ;   

invoke WinExec,addr szRunDialog1,SW_SHOW  ;   	 

    
    .case 1005; Основные
mov hIcon2,rv(LoadImage,hInstance,11,IMAGE_ICON,256,256,LR_DEFAULTCOLOR)
invoke DialogBoxParam,hInstance,200,0,ADDR Dial2,hIcon2

    .case 1006; Дополнительные
mov hIcon3,rv(LoadImage,hInstance,12,IMAGE_ICON,256,256, LR_DEFAULTCOLOR)
invoke DialogBoxParam,hInstance,300,0,ADDR Dial3,hIcon3	

    .case 1017; Основные
mov hIcon4,rv(LoadImage,hInstance,11,IMAGE_ICON,256,256,LR_DEFAULTCOLOR)
invoke DialogBoxParam,hInstance,400,0,ADDR Dial4,hIcon4
    .case 228; Graphic figure
invoke WinExec,addr szRunFigure,SW_SHOW

 .case 1007; Дополнительные
mov hIcon4,rv(LoadImage,hInstance,12,IMAGE_ICON,256,256, LR_DEFAULTCOLOR)
invoke DialogBoxParam,hInstance,400,0,ADDR Dial4,hIcon4	

    .case 1010; О программе
    invoke MsgboxI,0,ADDR szInf5,ADDR szTitle5,MB_OK,13
	
	.case 1016   ; кнопка <EXIT>
            jmp exit1  
   .endsw
.case WM_CLOSE
 exit1: invoke EndDialog,hWin,0 ; 
 .endsw
    xor rax, rax
    ret
main endp

; Окно 2 Осн возм интерфейса
Dial2 proc hWin:QWORD,uMsg:QWORD,wParam:QWORD, lParam:QWORD
.switch uMsg
      .case WM_INITDIALOG
rcall SendMessage,hWin,WM_SETICON,1,lParam ; установить иконку в строке заголовка
mov hImg2,rvcall(GetDlgItem,hWin,202)
rcall SendMessage,hImg2,STM_SETIMAGE,IMAGE_ICON,lParam ; иконка в клиентской области

.case WM_COMMAND
   .switch wParam
     .case 220
   jmp exit2
   .endsw
 .case WM_CLOSE
 exit2:
    rcall EndDialog,hWin,0 
 .endsw
    xor rax, rax
    ret
Dial2 endp

; Окно 3 Доп возм интерфейса
Dial3 proc hWin:QWORD,uMsg:QWORD,wParam:QWORD, lParam:QWORD
.switch uMsg
      .case WM_INITDIALOG
rcall SendMessage,hWin,WM_SETICON,1,lParam ; установить иконку в строке заголовка
mov hImg3,rvcall(GetDlgItem,hWin,302)
rcall SendMessage,hImg3,STM_SETIMAGE,IMAGE_ICON,lParam ; иконка в клиентской области

.case WM_COMMAND
   .switch wParam
     .case 320
 jmp exit3  
   .endsw

 .case WM_CLOSE
exit3:
    rcall EndDialog,hWin,0 
 .endsw
    xor rax, rax
    ret
Dial3 endp

; Окно 4 Доп возм интерфейса
Dial4 proc hWin:QWORD,uMsg:QWORD,wParam:QWORD, lParam:QWORD
.switch uMsg
      .case WM_INITDIALOG
rcall SendMessage,hWin,WM_SETICON,1,lParam ; установить иконку в строке заголовка
mov hImg4,rvcall(GetDlgItem,hWin,402)
rcall SendMessage,hImg4,STM_SETIMAGE,IMAGE_ICON,lParam ; иконка в клиентской области

.case WM_COMMAND
   .switch wParam
     .case 403
     invoke WinExec,addr szFileNameAuthor,SW_SHOW  ;
     ;invoke MsgboxI,0,ADDR szInfA,ADDR szTitleA,MB_OK,13;////zalupa is here

   .endsw

 .case WM_CLOSE

    rcall EndDialog,hWin,0 
 .endsw
    xor rax, rax
    ret
Dial4 endp


end

