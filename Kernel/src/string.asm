;==============================
;GoldElfOS: Mk II
;
;Roy Procell
;2 May 2015
;
;Updated 7/18/2015 for GoldOS Mk IV
;
;String Manipulation System Calls
;Strings.asm
;
;Features:
;Strings:
;os_convert_string_upper (done!)
;os_convert_string_lower (done!)
;os_string_to_int
;os_int_to_string
;os_hex_to_ascii
;os_ascii_to_hex
;os_string_length (done!)
;os_string_truncate
;os_string_copy
;os_print_registers
;os_print_time
;==============================

;==================
;os_convert_string_upper
;Converts the specified string to upper case chars
;IN:	AX: string segment, SI: string address
;OUT:	Nothing
;==================
os_convert_string_upper:
	pusha
	mov es, ax
	
.convert:
	cmp byte [es:si], 0
	je .done
	cmp byte [es:si], 'a'
	jb .skip
	cmp byte [es:si], 'z'
	ja .skip
	sub byte [es:si], 20h
	inc si
	jmp .convert
	
.skip:
	inc si
	jmp .convert
	
.done:
	popa
	ret

;==================
;os_convert_string_lower
;Converts the specified string to upper case chars
;IN:	AX: string segment, SI: string address
;OUT:	Nothing
;==================
os_convert_string_lower:
	pusha
	mov es, ax
	
.convert:
	cmp byte [es:si], 0
	je .done
	cmp byte [es:si], 'a'
	jb .skip
	cmp byte [es:si], 'z'
	ja .skip
	add byte [es:si], 20h
	inc si
	jmp .convert
	
.skip:
	inc si
	jmp .convert
	
.done:
	popa
	ret
	
;==================
;os_string_length
;Counts how many chars are in a string
;IN: AX: segment of string, BX: offset of string
;OUT: CX: length of string
;==================
os_string_length:
	pusha
	mov ds, ax
	mov si, bx
	mov cx, 0
	
.count_loop:
	cmp byte [ds:si], 0
	je .done
	inc si
	inc cx
	jmp .count_loop
	
.done:
	mov word [.cx], cx
	popa
	mov cx, word [.cx]
	ret
	
.cx dw 0

;==================
;os_string_to_int
;Converts a string into 
;IN: AX: segment of file name string, BX: offset of file name string
;OUT: CX: length of string
;==================