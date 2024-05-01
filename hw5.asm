.text

#part 1: initialize
init_student:
  # $a0: student id (22 bits)
  # $a1: num_credits (10 bits)
  # $a2: pointer to name (32 bits)
  # $a3: address of student record - record is uninitialized region of memory, 8 bytes long.
  
  #shift student id left by 10 bits
  sll $a0, $a0, 10
  #combine student id ($a0) and num_credits ($a1)
  or $t0, $a0, $a1
  #store combined student id and credits in student record
  sw $t0, 0($a3)     # Store student ID and credits in student record

  sw $a2, 4($a3)

  jr $ra
	
print_student:
  # $a0: pointer to student record struct (8 bytes)
  
  # Load the student ID and credits from the student record
  lw $t0, 0($a0)     # Load 32 bits which contains student ID + credits
  srl $t1, $t0, 10   # Extract the student ID (22 bits)
  andi $t2, $t0, 0x3FF   # Extract the number of credits (10 bits)
  
  # Load the pointer to the name from the student record
  lw $t3, 4($a0)     # Load the lower 32 bits of the pointer to the name
  
  # Print the student ID
  li $v0, 1           # Print integer
  move $a0, $t1
  syscall
  
  # Print space
  li $a0, 32          # ASCII space
  li $v0, 11          # Print character
  syscall
  
  # Print num_credits
  li $v0, 1
  move $a0, $t2
  syscall
  
  # Print space
  li $a0, 32
  li $v0, 11
  syscall
  
  # Loop to print each character of the string
print_loop:
    lb $a1, 0($t3)     # Load a byte from the address stored in $a2
    beqz $a1, end_print  # Exit loop if we reach null terminator
    move $a0, $a1       # Load character to print
    li $v0, 11          # print char
    syscall             
    addi $t3, $t3, 1    # increment index by one
    j print_loop       

end_print:


  jr $ra

	
init_student_array:
	jr $ra
	
insert:
	jr $ra
	
search:
	jr $ra

delete:
	jr $ra
