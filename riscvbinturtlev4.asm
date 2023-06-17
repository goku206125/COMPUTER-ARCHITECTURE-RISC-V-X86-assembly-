.eqv		max_bin_size 	8192
.eqv		max_bmp_size 	90000

.eqv		const_op_pen 	0
.eqv		const_op_mov 	1
.eqv		const_op_dir 	2
.eqv		const_op_pos 	3

.eqv		const_width		600
.eqv		const_height	50
.eqv		const_stride	1800
.eqv		const_rgb_size	3

.data
# data buffers
command:	.space 	max_bin_size
pixels:		.space	max_bmp_size
# hardcoded data
header:		.byte 	66, 77, 200, 95, 1, 0, 0, 0, 0, 0, 54, 0, 0, 0, 40, 0, 0, 0, 88, 2, 0, 0, 50, 0, 0, 0, 1, 0, 24, 0, 0, 0, 0, 0, 146, 95, 1, 0, 18, 11, 0, 0, 18, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
direction: 	.byte	1, 0, -1, 0, 0, 1, 0, -1
colors:		.word	0x000000, 0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0x00FFFF, 0x800080, 0xFFFFFF
# file paths (relative to where rars.jar is)
file_bin:	.asciz	"program.bin"
file_bmp:	.asciz 	"result.bmp"
# message strings
error_bin:	.asciz	"Error: Couldn't read the program binary\n"
error_bmp:	.asciz	"Error: Couldn't write the output bitmap\n"
error_cmd:	.asciz	"Error: Invalid program binary\n"
result_ret:	.asciz	"Turtle function returned: "

.text
main:
	# white-out the pixel buffer
	la		t0, pixels
	li		t1, max_bmp_size
	add		t1, t1, t0
	li		t2, 0xFF
white_loop:
	bge		t0, t1, white_done
	sb		t2, (t0)
	addi	t0, t0, 1
	j		white_loop
white_done:

	# open the program file
	li		a7, 1024
	la		a0, file_bin
	li		a1, 0 # read-only
	ecall
	# if handle < 0, means we couldn't open the program binary
	bltz	a0, return_err_bin
	# preserve the file handle in t0
	mv		t0, a0
	# read the bin file into command buffer
	li		a7, 63
	la		a1, command
	li		a2, max_bin_size
	ecall
	# preserve file size in t1
	mv		t1, a0
	# close the file handle
	li		a7, 57
	mv		a0, t0
	ecall

	# call the turtle function
	la		a0, pixels
	la		a1, command
	mv		a2, t1
	jal		turtle
	# preserve return result
	mv		t0, a0
	# print preamble
	li		a7, 4
	la		a0, result_ret
	ecall
	# print return result
	li		a7, 1
	mv		a0, t0
	ecall
	# print newline symbol
	li		a7, 11
	li		a0, '\n'
	ecall

	# open the bitmap file
	li		a7, 1024
	la		a0, file_bmp
	li		a1, 1 # write-only
	ecall
	# if handle < 0, means we couldn't open the bitmap file
	bltz	a0, return_err_bmp
	# preserve the file handle in t0
	mv		t0, a0
	# write the bitmap file to the disk
	li		a7, 64
	la		a1, header
	li		a2, 54
	ecall
	mv		a0, t0
	li		a7, 64
	la		a1, pixels
	li		a2, max_bmp_size
	ecall
	# close the file handle
	li		a7, 57
	mv		a0, t0
	ecall

	# exit safely
terminate:
	li		a7, 10
	ecall
	#
	
	# error
return_err_bin:
	li		a7, 4
	la		a0, error_bin
	ecall
	j		terminate
return_err_cmd:
	li		a7, 4
	la		a0, error_cmd
	ecall
	j		terminate
return_err_bmp:
	li		a7, 4
	la		a0, error_bmp
	ecall
	j		terminate
	# ###############

	# turtle opcode interpreter
	# a0: bitmap
	# a1: command
	# a2: command_size
turtle:
	.eqv	arg_bitmap	s0
	.eqv	arg_binary	s1
	.eqv	arg_bounds	s2
	.eqv	var_offset 	s3
	.eqv	var_opcode 	s4
	.eqv	var_pos_x 	s5
	.eqv	var_pos_y 	s6
	.eqv	var_dir_x 	s7
	.eqv	var_dir_y 	s8
	.eqv	var_color 	s9
	.eqv	var_udpen 	s10
	.eqv	var_mdist 	s11
	# zero-out all variables
	mv		arg_bitmap, a0
	mv		arg_binary, a1
	mv		arg_bounds, a2
	mv		var_pos_x, zero
	mv		var_pos_y, zero
	mv		var_dir_x, zero
	mv		var_dir_y, zero
	mv		var_color, zero
	mv		var_udpen, zero
	# set the iterator (pointer) to the start of commands
	mv		var_offset, arg_binary
	# check if command_size is a multiple of 2
	li		t1, 2
	remu	t0, a2, t1
	bnez	t0, turtle_error_bounds
	# start of the interpreter loop
interpreter_loop:
	# if (offset >= commands + commands_size) break;
	add		t0, arg_binary, arg_bounds
	bge		var_offset, t0, interpreter_done
	##### reading the current opcode
	# var_opcode = (command[index] << 8) | command[index + 1]
	mv		t0, zero
	mv		t1, zero
	lbu		t0, (var_offset)
	lbu		t1, 1(var_offset)
	slli	t0, t0, 8
	or		var_opcode, t0, t1
	# increment the offset by 2
	addi	var_offset, var_offset, 2
	####
	# mask-out the actual opcode at 1:0	
	andi	t0, var_opcode, 3
	li		t1, const_op_pen
	beq		t0, t1, opcode_pen	
	li		t1, const_op_mov
	beq		t0, t1, opcode_mov
	li		t1, const_op_dir
	beq		t0, t1, opcode_dir
opcode_pos:
	## shift and mask-out the X pos from 15:6
	# var_pos_y = (opcode >> 6) & 1023
	srli	var_pos_x, var_opcode, 6
	andi	var_pos_x, var_pos_x, 1023
	# check if we are out of bounds, i.e. position command is malformed
	add		t0, arg_binary, arg_bounds
	bge		var_offset, t0, turtle_error_bounds	
	# var_opcode = (command[index] << 8) | command[index + 1]
	mv		t0, zero
	mv		t1, zero
	lbu		t0, (var_offset)
	lbu		t1, 1(var_offset)
	slli	t0, t0, 8
	or		var_opcode, t0, t1
	# increment the offset by 2
	addi	var_offset, var_offset, 2
	####
	## shift and mask-out the Y pos from 15:10
	# var_pos_y = (opcode >> 10) & 31
	srli	var_pos_y, var_opcode, 10
	andi	var_pos_y, var_pos_y, 31
	j		interpreter_loop
opcode_pen:
	## shift and mask-out the ud part and the color index
	# then read the color from the table
	srli	var_udpen, var_opcode, 3
	andi	var_udpen, var_udpen, 1
	srli	t0, var_opcode, 13
	andi	t0, t0, 7
	slli	t0, t0, 2
	la		t1, colors
	add		t0, t0, t1
	lw		var_color, (t0)
	j		interpreter_loop
opcode_dir:
	## shift and mask-out direction index
	# read direction values from the array
	srli	t0, var_opcode, 2
	andi	t0, t0, 3
	la		t1, direction
	add		t0, t0, t1
	lb 		var_dir_x, (t0)
	addi	t0, t0, 4
	lb		var_dir_y, (t0)
	j		interpreter_loop
opcode_mov:
	## shift and mask-out the movement amount
	srli	var_mdist, var_opcode, 2
	andi	var_mdist, var_mdist, 1023
	# commence movement, drawing if the pen is down
opcode_mov_loop:
	blez	var_mdist, opcode_mov_done
	add		var_pos_x, var_pos_x, var_dir_x
	add		var_pos_y, var_pos_y, var_dir_y
	beqz	var_udpen, opcode_mov_skip
	# compute pixel offsets
	li		t0, const_stride
	mul		t0, t0, var_pos_y
	li		t1, const_rgb_size
	mul		t1, t1, var_pos_x
	add		t0, t0, t1
	add		t0, t0, arg_bitmap
	# write the pixel channels
	mv		t1, var_color
	andi	t2, t1, 0xFF
	sb		t2, (t0)
	srli	t1, t1, 8
	andi	t2, t1, 0xFF
	sb		t2, 1(t0)
	srli	t1, t1, 8
	andi	t2, t1, 0xFF
	sb		t2, 2(t0)	
opcode_mov_skip:
	addi	var_mdist, var_mdist, -1
	j		opcode_mov_loop
opcode_mov_done:
	j		interpreter_loop
interpreter_done:
	mv		a0, zero
turtle_return:
	jr		ra
turtle_error_bounds:
	li		a0, -1
	jr		ra
