;==============================
;GoldElfOS: Mk II
;
;Roy Procell
;21 April 2015
;
;Keyboard System Calls
;Keyboard.asm
;
;Features:
;Keyboard:
;os_wait_for_key
;os_check_for_key
;==============================

;==================
;os_wait_for_key
;BIOS interrupt: waits for key press
;IN:	Nothing
;OUT:	AH: BIOS scan code, AL: ASCII character
;==================
os_wait_for_key:
	pusha
	mov ax, 0
	mov ah, 10h
	int 16h
	mov word [.tmp], ax
	popa
	mov ax, word [.tmp]
	ret
	
.tmp dw 0

;==================
;os_check_for_key
;BIOS interrupt: checks for key press without waiting
;IN:	Nothing
;OUT:	AH: BIOS scan code, AL: ASCII character
;==================
os_check_for_key:
	pusha
	mov ax, 0
	mov ah, 11h
	int 16h
	mov word [.tmp], ax
	popa
	mov ax, word [.tmp]
	ret
	
.tmp dw 0