include \masm64\include64\masm64rt.inc ; Структуры, константы, функции...

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
mov hInstance,rv(GetModuleHandle,0) ; получение и сохранение дескрипторa программы
   invoke WinMain,hInstance,SW_SHOWDEFAULT
   invoke ExitProcess,rax ; Возвращение управления ОС Windows и освобождение ресурсов
entry_point endp
   
WinMain proc hInst:HINSTANCE, CmdShow:DWORD
LOCAL wc:WNDCLASSEX ; Резервирование стека под структуру класса окна
LOCAL msg:MSG ; резервирование стека под структуру MSG
LOCAL hwnd:HWND ; резервирование стека под дескриптор окна

   push hInstance     ; Сохранение в стеке дескриптора программы
   pop wc.hInstance   ; Возвращение дескриптора в поле структуры
   mov wc.cbSize,SIZEOF WNDCLASSEX ; Количество байтов структуры WNDCLASSEX
   mov wc.style,CS_HREDRAW or CS_VREDRAW  ; Cтиль и поведение окна
   lea rax,WndProc              ; Получение адреса процедуры WndProc
   mov wc.lpfnWndProc,rax                ; Адрес процедуры WndProc
   mov wc.hbrBackground,COLOR_WINDOW+1   ; Цвет окна
   invoke GetStockObject,WHITE_BRUSH     ; Чтение описателя кисти
   mov wc.hbrBackground,rax       ; Цвет заполнения окна
   mov wc.lpszMenuName,0          ; Имя ресурса меню
   lea rax, ClassName      ; Получение адреса переменной с именем класса
   mov wc.lpszClassName,rax       ; Имя класса
   invoke LoadIcon, NULL, IDI_APPLICATION ; Загрузка отображаемой пиктограммы
   mov wc.hIcon, rax       ; Дескриптор "большой" пиктограммы
   mov wc.hIconSm, rax     ; Дескриптор пиктограммы маленького окошка
   invoke LoadCursor,0,IDC_ARROW ; Загрузка курсора
   mov wc.hCursor,rax      ; Курсор
   mov wc.cbClsExtra,0     ; Количество доп. байтов для структуры класса
   mov wc.cbWndExtra,0     ; Количество доп. байтов для структуры окна
   invoke RegisterClassEx,ADDR wc ; Функция регистрации класса окна

   ; Установка размеров и центрирование окна
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

   invoke CreateWindowEx, WS_EX_TOOLWINDOW, ADDR ClassName,\ ; Стиль и адрес имени класса
      ADDR AppName, WS_POPUP,\  ; Адрес имени окна и базовый стиль окна
          xCtr,yCtr,width_,height,0,0,hInst,0 ; Координаты окна и дескрипторы
   mov hwnd,rax ; Сохранение дескриптора окна
mov hBitmap,rv(LoadImage,hInstance,addr BitMap,IMAGE_BITMAP,0,0,LR_LOADFROMFILE)
   invoke ShowWindow,hwnd,SW_SHOWNORMAL ; Видимость окна
m0: ; WHILE TRUE. Главный цикл программы
   invoke GetMessage,ADDR msg,0,0,0 ; Чтение сообщения
   or eax, eax ; Формирование признаков
   jz Quit ; Перейти на метку Quit, если еах = 0 
   invoke DispatchMessage, ADDR msg ; Отправление сообщения к WndProc
   jmp m0 ; Окончание цикла обрабатывания сообщений
Quit:
   mov rax, msg.wParam
   ret ; Возвращение из процедуры WinMain
WinMain endp ; Окончание процедуры WinMain

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
LOCAL hdc:HDC        ; Резервирование стека под дескриптор окна
LOCAL ps:PAINTSTRUCT ; Резервирование стека под структуру PAINTSTRUCT
LOCAL rect:RECT      ; Резервирование стека под структуру RECT
LOCAL bitmap : BITMAP
LOCAL hdcMem : HDC
LOCAL oldBitmap : HANDLE  ; HGDIOBJ = HANDLE. Описатель предыдущего изображения

.switch uMsg
.case WM_DESTROY        ; IF uMsg == WM_DESTROY (Уничтожение окна)
   invoke PostQuitMessage,0 ; Отправка сообщения WM_QUIT
   
.case WM_NCRBUTTONDOWN ; IF uMsg == WM_NCRBUTTONDOWN (Нажата правая кнопка мыши в неклиентской области)
   invoke SendMessage,hWnd,WM_DESTROY,0,0 ; Отправка сообщения об уничтожении окна
   invoke Sleep,1500

.case WM_NCHITTEST ; IF uMsg == WM_NCHITTEST (Тест нажатия кнопки мыши в неклиентской области)
   invoke DefWindowProc, hWnd, uMsg, wParam, lParam
   ; Перенаправление нажатия в клиентской области в неклиентскую
   .if rax == 1 ; 1 = HTCLIENT
   mov rax, 2   ; 2 = HTCAPTION
   ret
   .endif
   ret

.case WM_PAINT    ; IF uMsg == WM_PAINT (Перерисовка области окна)
   invoke GetWindowLong,hWnd,GWL_EXSTYLE ; Извлекает данные о расширенном стиле окна
   or eax,WS_EX_LAYERED    ; Добавление к существующим стилям WS_EX_LAYERED
   invoke SetWindowLong,hWnd,GWL_EXSTYLE,eax ; Установка нового стиля окна

   invoke SetLayeredWindowAttributes,hWnd,0,0,LWA_COLORKEY ; Установка прозрачности для окна
  mov hdc,rv(BeginPaint,hWnd,ADDR ps)    ; Вызов процедуры и заполнение структуры
  mov hdcMem,rv(CreateCompatibleDC,hdc)  ; Создание контекста устройства в памяти
  
  mov oldBitmap,rv(SelectObject,hdcMem,hBitmap) ; выбор нового изображения
   
   invoke GetObject,hBitmap,sizeof bitmap,addr bitmap
   invoke BitBlt,hdc,0,0,bitmap.bmWidth,bitmap.bmHeight,hdcMem,0,0,SRCCOPY ; Отображение изображения
   invoke SelectObject,hdcMem,oldBitmap
   invoke DeleteDC, hdcMem             ; Освобождение контекста

   invoke GetClientRect,hWnd,ADDR rect ; Заполнение структуры RECT (Размеры окна)
   invoke EndPaint,hWnd,ADDR ps        ; Окончание рисования
   
.default   ; Иначе
   invoke DefWindowProc,hWnd,uMsg,wParam,lParam ; Вызов оконной процедуры по-умолчанию
   ret     ; Возвращение из процедуры
.endsw     ; End switch

   xor eax, eax
   ret       ; Возвращение из процедуры
WndProc endp ; Окончание процедуры WndProc
end          ; Окончание программы
