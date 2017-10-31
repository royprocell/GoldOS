;GoldOS 4.0 Port Functions
;
;Roy Procell
;10/30/2017
;
;Functions:
;os_port_out
;os_port_in

;==================
;os_wait
;Sends a byte to a port
;IN: DX: port, AL: data
;OUT: Nothing
;==================
os_port_out:
	out dx, al
	ret

;==================
;os_port_in
;Asks a port for a byte of data, and returns it to the user
;IN: DX: port
;OUT: AL: data
;==================
os_port_in:
	in al, dx
	ret