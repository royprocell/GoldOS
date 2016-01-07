;GoldOS 4.0 Miscellaneous Functions
;
;Roy Procell
;7/23/2015
;
;Functions:
;os_random
;os_wait (done!)

;==================
;os_wait
;Stops execution for a certain number of microseconds
;IN: CX:DX: microseconds to wait (CX is high word, DX is lower word)
;OUT: Nothing
;==================
os_wait:
	pusha
	mov ah, 86h
	int 15h
	popa
	ret

;==================
;os_clear_blinking_bit_bl
;Makes sure text isn't blinking on older computers
;IN: Nothing
;OUT: Nothing
;==================
os_clear_blinking_bit_bl:
	btr ebx, 7
	ret
	
;==================
;os_clear_blinking_bit_bh
;Makes sure text isn't blinking on older computers
;IN: Nothing
;OUT: Nothing
;==================
os_clear_blinking_bit_bh:
	btr ebx, 13
	ret