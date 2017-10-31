;GoldOS 4.0 Sound Functions
;
;Roy Procell
;10/30/2017
;
;Functions:
;os_speaker_on
;os_speaker_off

;==================
;os_speaker_on
;Sets a tone on the PC speaker
;IN: AX: tone frequency
;OUT: Nothing
;==================
os_speaker_on:
	push ax
	mov al, 0xB6
	out 43h, al
	pop ax
	out 42h, al
	mov al, ah
	out 42h, al
	in al, 61h
	or al, 3
	out 61h, al
	ret

;==================
;os_speaker_off
;Silences the PC speaker if there is a tone playing
;IN: Nothing
;OUT: Nothing
;==================
os_speaker_off:
	push ax
	in al, 61h
	and al, 0xFC
	out 61h, al
	pop ax
	ret