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
	

#for part 3, issue when calling print_student. seems as though it infinitively loops. when called once, no issue. 
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

  #print string
  li $v0, 4
  move $a0, $t3
  syscall

  jr $ra

init_student_array:
  #$a0: num_students
  #$a1: id_list
  #$a2: credits_list
  #$a3: *names, such as Wolfie\0Donna\0Leopold
  #$sp: records[], pointer to uninitialized region of memory with size 8*num_students

  # Initialize counter, save inputs to temporary values
  #li $t9, 0   # Initialize counter, $t9 = i
  
  move $t1, $a0  # Load the upper loop constraint, $t1 = num_students
  
  
  
  
  #ok i'm going to store everything above. 
  
  lw $t5, 0($sp)

  addi $sp, $sp, -20
  sw $ra, 0($sp)
  sw $s0, 4($sp)
  sw $s1, 8($sp)
  sw $s2, 12($sp)
  sw $s3, 16($sp)
  move $s0, $a3 #s0 stores pointer to name
  move $s1, $a2 #s1 stores credits_list
  move $s2, $a1 #s2 stores id_list, t6
  
  li $s3, 0 #s3: initialize counter
  
  
  loop:
    beqz $t1, done
    sll $t0, $s3, 2 #multiply indx by 4


    #id_list
    add $t2, $t0, $s2 #address of id id_list
    lw $t3, 0($t2) #t3 = id_list[i]
    move $a0, $t3
    
    #credit_list
    add $t2, $t0, $s1 #address of credits_list
    lw $t3, 0($t2) #t3 = credit_list[i]
    move $a1, $t3

    #pointer to name
    move $a2, $s0
    
    name_loop:
      lb $t4, 0($s0)
      beqz $t4, done_loop
      addi $s0, $s0, 1
      j name_loop
    done_loop:

    #pointer to record
    sll $t0, $s3, 3 #multiply indx by 8
    add $t5, $t5, $t0 #get indx of next record

    move $a3, $t5 

    addi $s0, $s0, 1
    addi $t1, $t1, -1
    addi $s3, $s3, 1

    # call init_student, this function saves student data to $a3
    jal init_student

    j loop
  done:
  lw $ra, 0($sp)
  lw $s0, 4($sp)
  lw $s1, 8($sp)
  lw $s2, 12($sp)
  lw $s3, 16($sp)
  addi $sp, $sp, 20
  jr $ra  # Return from the function

	
insert:
  #$a0: pointer to student record
  #$a1: pointer to hash table
  #$a2: table_size
  #$v0: array index stored in hash, or -1

  #make space in $sp, save registers
  addi $sp, $sp, -8 #allocate space on stack
  sw $ra, 4($sp)
  sw $s0, 0($sp)

  #load student id+credits
  lw $s0, 0($a0) #load id and credits into $s0
  srl $s0, $s0, 10 #isolate the student's id
  div $s0, $a2 #get the index of current student in hash table
  mfhi $t0 #INDEX IN HASH TABLE
 
  #copy original index in hash table
  move $t1, $t0 #$t1 original index in hash table

  #loop: calculate and check whether current index is occupied
  #within loop: do linear probing. each time i linearly probe, check again
    #check if empty -> insert, $v0 = indx
    #check if -1 -> insert, $v0 = indx
    #linear probe
      #if end up back at original index, $v0 = -1

  check_index: 
    #check what is stored at index in hash table currently 
    #calculate index with offset (4)
    #sll $t1, $t1, 2 #multiply by 4
    #lw $t2, $t1()


	jr $ra
	
search:
	jr $ra

delete:
	jr $ra
