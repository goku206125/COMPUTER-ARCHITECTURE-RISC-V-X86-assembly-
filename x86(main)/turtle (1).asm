bits 32

%define		const_op_pen 	0
%define		const_op_mov 	1
%define		const_op_dir 	2
%define		const_op_pos 	3

%define		const_stride	1800

global 		turtle
global 		_turtle

SECTION .data
align 4
direction:		dd 1, 0, -1, 0, 0, 1, 0, -1
align 4
colors:			dd 0x000000, 0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0x00FFFF, 0x800080, 0xFFFFFF

SECTION .text
; turtle function
turtle:
_turtle:
	push 	ebp
	mov 	ebp, esp
;; args
%define 	arg_bitmap 		ebp+8
%define 	arg_binary 		ebp+12
%define 	arg_bounds 		ebp+16
;; locals
%define 	var_offset		ebp-4
%define 	var_opcode 		ebp-8
%define 	var_pos_x 		ebp-12
%define 	var_pos_y 		ebp-16
%define 	var_dir_x 		ebp-20
%define 	var_dir_y		ebp-24
%define 	var_color		ebp-28
%define 	var_udpen 		ebp-32
%define 	var_mdist 		ebp-36
;;
	sub		esp, 36
	mov		eax, [arg_binary]
	mov		[var_offset], eax
	mov		[var_opcode], dword 0
	mov		[var_pos_x], dword 0
	mov		[var_pos_y], dword 0
	mov		[var_dir_x], dword 0
	mov		[var_dir_y], dword 0
	mov		[var_color], dword 0
	mov		[var_udpen], dword 0
	mov		[var_mdist], dword 0
interpreter_loop:
	; if (offset >= commands + commands_size) break;
	mov		eax, [arg_binary]
	add		eax, [arg_bounds]
	cmp		eax, [var_offset]
	jle		interpreter_done
	;;;;; reading the current opcode
	; var_opcode = (command[index] << 8) | command[index + 1]
	xor		edx, edx
	mov		eax, [var_offset]
	mov		dh, [eax]
	mov		dl, [eax+1]
	mov		[var_opcode], edx
	add		[var_offset], dword 2
	and		edx, 3
	cmp		edx, const_op_pen
	je		opcode_pen
	cmp		edx, const_op_mov
	je		opcode_mov
	cmp		edx, const_op_dir
	je		opcode_dir
opcode_pos:
	;; shift and mask-out the X pos from 15:6
	; var_pos_x = (opcode >> 6) & 1023
	mov		eax, [var_opcode]
	shr		eax, 6
	and		eax, 1023
	mov		[var_pos_x], eax
	; check if we are out of bounds, i.e. position command is malformed
	mov		eax, [arg_binary]
	add		eax, [arg_bounds]
	cmp		eax, [var_offset]
	jle		turtle_error_bounds
	; var_opcode = (command[index] << 8) | command[index + 1]
	xor		edx, edx
	mov		eax, [var_offset]
	mov		dh, [eax]
	mov		dl, [eax+1]
	mov		[var_opcode], edx
	add		[var_offset], dword 2
	; var_pos_y = (opcode >> 10) & 63
	mov		eax, [var_opcode]
	shr		eax, 10
	and		eax, 63
	mov		[var_pos_y], eax
	jmp		interpreter_loop
opcode_pen:
	;; shift and mask-out the ud part and the color index
	; then read the color from the table
	mov		eax, [var_opcode]
	shr		eax, 3
	and		eax, 1
	mov		[var_udpen], eax
	mov		eax, [var_opcode]
	shr		eax, 13
	and		eax, 7
	mov		edx, [eax*4+colors]
	mov		[var_color], edx
	jmp		interpreter_loop
opcode_dir:
	;; shift and mask-out direction index
	; read direction values from the array
	mov		eax, [var_opcode]
	shr		eax, 2
	and		eax, 3
	mov		edx, [eax*4+direction]
	mov		[var_dir_x], edx
	add		eax, 4
	mov		edx, [eax*4+direction]
	mov		[var_dir_y], edx
	jmp		interpreter_loop
opcode_mov:
	;; shift and mask-out the movement amount
	mov		eax, [var_opcode]
	shr		eax, 2
	and		eax, 1023
	mov		[var_mdist], eax
	; commence movement, drawing if the pen is down
opcode_mov_loop:
	mov		eax, [var_mdist]
	test	eax,  eax
	jz		opcode_mov_done
	mov		eax, [var_pos_x]
	add		eax, [var_dir_x]
	mov		[var_pos_x], eax
	mov		eax, [var_pos_y]
	add		eax, [var_dir_y]
	mov		[var_pos_y], eax
	mov		eax, [var_udpen]
	test	eax, eax
	jz		opcode_mov_skip	
	; compute pixel offsets
	xor		edx, edx
	mov		eax, [var_pos_y]
	mov		ecx, const_stride
	mul		ecx
	mov		ecx, [var_pos_x]
	lea		ecx, [ecx+ecx*2]
	add		eax, ecx
	add		eax, [arg_bitmap]
	; write the pixel channels
	mov		ecx, [var_color]
	mov		[eax], cl
	mov		[eax+1], ch
	shr		ecx, 8
	mov		[eax+2], ch
opcode_mov_skip:
	dec		dword [var_mdist]
	jmp		opcode_mov_loop
opcode_mov_done:
	jmp		interpreter_loop
interpreter_done:
	xor		eax, eax
	xor		edx, edx
turtle_return:
	add		esp, 36
	mov     	esp, ebp
	pop		ebp
	ret
turtle_error_bounds:
	mov		eax, -1
	jmp		turtle_return