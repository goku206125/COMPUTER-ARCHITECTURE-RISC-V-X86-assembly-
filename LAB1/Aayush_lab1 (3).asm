.data
.eqv ascii_lc_min 97
.eqv ascii_lc_max 124
.eqv ascii_num_min 48
.eqv ascii_num_max 57

prompt:
	.string "Please Enter A String: \n"

input_string: 
	.space 256

result_string:
	.string "String result: \t"

result_lower_case:
	.string "Numnber of Lowercase Character: \t"

result_count:
	.string "\nNumber of Digits: \t"
	
.text

# Input String
	la a0, prompt
	li a7, 4
	ecall
	
	
	la a0, input_string
	li a1, 256
	li a7, 8
	ecall
	
#initialize loop variables
	
	li t0, 0				
	li t1, 0		
	mv t2 , a0
	
	li a2, ascii_lc_min
	li a3, ascii_lc_max
	li a4, ascii_num_min
	li a5, ascii_num_max
	
	
count_loop_lower_case:				
	
	lbu t3, (t2)
	beqz t3, next_loop
	blt t3 , a2, skip
	bgt t3, a3, skip
	addi t0, t0, 1
	addi t2, t2, 1
	j count_loop_lower_case
	
	
	
	
skip:
	addi t4, t4, 1
	addi t2, t2, 1
	j count_loop_lower_case
	
	
	
next_loop:

	addi t2 ,zero, 0
	addi t3 ,zero, 0
	
	mv t2, a0
	
	
count_loop_digit:
				
	lbu t3, (t2)
	beqz t3, check_even
	blt t3 , a4, skip2
	bgt t3, a5, skip2
	addi t1, t1, 1
	addi t2, t2, 1
	j count_loop_digit
	
	
	
	
skip2:
	
	addi t2, t2, 1
	j count_loop_digit	
	
	
check_even:
	mv s3 , t0
	mv s4 , t1
	
	li t2, 2
	rem t3 , s3, t2
	beqz t3 , replace_even
	j replace_odd
	
	
	
replace_even:
	

	li s2, 5
	li t0, 1  
	la t1, input_string
	
	 
even_loop: 
	lbu t2 , (t1)
	beqz t2, exit_loop
	rem t5, t0,s2
	
	beqz t5 , subsitute_even
	addi t0, t0, 1
	addi t1 ,t1, 1
	
	j even_loop

subsitute_even: 
		
	
	addi, s5, t2 ,-1
	sb s5 , (t1)

	addi t0, t0, 1
	addi t1 ,t1, 1
	
	j even_loop
	
	
replace_odd:
	
	li t5, '*'
	li s2, 5
	li t0 ,1
	la t1, input_string
	
odd_loop:
	lbu t2, (t1)
	beqz, t2, exit_loop
	rem t4, t0, s2
	beqz t4 , substitute_odd
	addi t0, t0 ,1
	addi t1, t1, 1
	
	j odd_loop
		
	
substitute_odd:
	
	sb t5, (t1)
	
	addi t0, t0, 1
	addi t1, t1, 1
	j odd_loop


exit_loop:
	la a0, result_string
	li a7, 4
	ecall
	
	la a0, input_string
	li a7, 4
	ecall
	
	
	
	
	
	la a0, result_lower_case
	li a7, 4
	ecall
	
	mv a0, s3
	li a7, 1
	ecall
	
	
	la a0, result_count
	li a7, 4
	ecall
	
	mv a0, s4
	li a7, 1
	ecall
	
	
	
