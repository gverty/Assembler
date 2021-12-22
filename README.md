# Assembler

Run project -> run kp.exe after compiling

MASM64
makeit.bat code:

:: вывод выполняющихся строк на экран
@echo off
:: установка переменной
set appname=%1

\masm64\bin64\ml64.exe /c %appname%.asm
\masm64\bin64\rc.exe %appname%.rc
\masm64\bin64\link.exe /SUBSYSTEM:WINDOWS /ENTRY:entry_point /nologo /LARGEADDRESSAWARE %appname%.obj %appname%.res

:: вывод списка файлов 
dir %appname%.*

:: удаление файла *.obj
del %appname%.obj
del %appname%.res
pause
