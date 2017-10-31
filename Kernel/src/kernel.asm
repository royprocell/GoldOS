;GoldOS 4.0
;
;Roy Procell
;7/13/2015
;
;The main kernel file of GoldOS

setup:
	;sets up interrupts
	%include 'C:\users\golde\documents\github\GoldOS\kernel\src\setup.asm'
	;%include 'C:\users\roy\desktop\GoldOS\setup.asm'

main:
	;draws main screen
	%include 'C:\users\golde\documents\github\GoldOS\kernel\src\main.asm'
	;%include 'C:\users\roy\desktop\GoldOS\main.asm'
	
%include 'C:\users\golde\documents\github\GoldOS\kernel\src\video.asm'
%include 'C:\users\golde\documents\github\GoldOS\kernel\src\keyboard.asm'
%include 'C:\users\golde\documents\github\GoldOS\kernel\src\string.asm'
%include 'C:\users\golde\documents\github\GoldOS\kernel\src\disk.asm'
%include 'C:\users\golde\documents\github\GoldOS\kernel\src\fat16.asm'
%include 'C:\users\golde\documents\github\GoldOS\kernel\src\ports.asm'
%include 'C:\users\golde\documents\github\GoldOS\kernel\src\sound.asm'
%include 'C:\users\golde\documents\github\GoldOS\kernel\src\math.asm'
%include 'C:\users\golde\documents\github\GoldOS\kernel\src\misc.asm'
%include 'C:\users\golde\documents\github\GoldOS\kernel\src\int.asm'

;%include 'C:\users\roy\desktop\GoldOS\video.asm'
;%include 'C:\users\roy\desktop\GoldOS\keyboard.asm'
;%include 'C:\users\roy\desktop\GoldOS\string.asm'
;%include 'C:\users\roy\desktop\GoldOS\disk.asm'
;%include 'C:\users\roy\desktop\GoldOS\fat16.asm'
;%include 'C:\users\roy\desktop\GoldOS\ports.asm'
;%include 'C:\users\roy\desktop\GoldOS\sound.asm'
;%include 'C:\users\roy\desktop\GoldOS\math.asm'
;%include 'C:\users\roy\desktop\GoldOS\misc.asm'
;%include 'C:\users\roy\desktop\GoldOS\int.asm'

system_messages:
	os_welcome db "Welcome to GoldOS!", 0
	os_help db "Use the arrow keys to", 0
	os_help_2 db "choose an option from", 0
	os_help_3 db "the list below.", 0
	os_desc db "Option", 0
	os_desc_2 db "Description:", 0
	os_confirm db "Are you sure?", 0
	os_warning db "Warning!", 0
	os_error db "Error!", 0
	os_file_not_found db "File not found!", 0
	os_file_not_found_2 db "Press any key.", 0
	os_notice db "Notice!", 0
	os_shutdown db "Do you really want to", 0
	os_shutdown_2 db "shut down your", 0
	os_shutdown_3 db "computer?", 0
	
system_files:
	os_file_file db "FILEMNGRBIN",0
	os_text_file db "TEXTEDITBIN",0
	os_imge_file db "IMGEDIT BIN",0
	os_calc_file db "CALC    BIN",0
	os_demo_file db "DEMO    BIN",0
	os_info_file db "INFO    BIN",0
	os_cnfg_file db "CONFIG  BIN",0
	;os_loff_file db "SHUTDOWNBIN",0
	os_test_file db "FAFSA   BIN",0
system_variables:
	os_option_counter db 0
	os_disk_num db 0
	os_gfx_var db 0
	
system_icons:
	;used as storage for app icons
	%include 'C:\users\golde\documents\github\GoldOS\kernel\src\icons.asm'
	;%include 'C:\users\roy\desktop\GoldOS\icons.asm'

db 'FS BUFFER'
fs_buffer: