.text

init_student:
	#$a0: student id 
	#$a1: num_credits
	#$a2: pointer to name 
	#$a3: pointer to student record

	#allocate memory for student record in heap
	li $v0, 9 #srbk
	li $a0, 8 #allocate 8 bytes for student record
	syscall #$v0 points to memory 

	sw $a0, 4($v0) #store sudent id
	sw $a1, 2($v0) #store num_credits
	sw $a2, 0($v0) #store pointer to student name

	jr $ra
	
print_student:
	jr $ra
	
init_student_array:
	jr $ra
	
insert:
	jr $ra
	
search:
	jr $ra

delete:
	jr $ra
