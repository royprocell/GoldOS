;Roy Procell
;7/7/2016
;GoldOS CLI

;Features:
;help - lists commands
;cls - clears screen
;cd - change directory
;dir - list contents of folder
;del - delete file
;ren - rename file
;copy - copy file
;size - returns size of file
;time - returns current time
;ver - returns version of GoldOS
;exit - quits program
;date - returns current date
;mkdir - creates a directory
;move - moves a file to the specified directory

;Syntax:
;*.bin - executes the program with all registers zero
;*.bin -? -? ... - executes the program with specific values for each register
;arg0 - AX
;arg1 - BX
;arg2 - CX
;arg3 - DX
;arg4 - SI
;arg5 - DI
;arg6 to arg9 - string

org 40960 ;subject to change

main:

input:
parse:

help:
	mov si, .msg
	mov di, 0
	int 0F4h
	
	jmp input
	
.msg db 'HELP, CD, CLS, COPY, DATE, DEL, DIR, EXIT, MKDIR, MOVE, REN, SIZE, TIME', 0

cls:
	jmp main

cd:
dir:
del:
ren:
copy:
size:
time:
ver:
exit_cmd:
date:
mkdir:
move:

execute:

exit:

vars:
welcome_msg db 'GoldOS CLI 1.0', 0
command times (80) db 0
arg0 times (80) db 0
arg1 times (80) db 0
arg2 times (80) db 0
arg3 times (80) db 0
arg4 times (80) db 0
arg5 times (80) db 0
arg6 times (80) db 0
arg7 times (80) db 0
arg8 times (80) db 0
arg9 times (80) db 0
