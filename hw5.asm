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
  li $t9, 0   # Initialize counter, $t9 = i
  move $t1, $a0  # Load the upper loop constraint, $t1 = num_students
  move $t8, $a3 #$t8 holds pointer to name
  move $t7, $a2 #$t7 holds credits_list
  move $t6, $a1 #$t6 holds id_list

  
  loop:
    beqz $t1, done
    sll $t0, $t9, 2 #multiply indx by 4


    #id_list
    add $t2, $t0, $t6 #address of id id_list
    lw $t3, 0($t2) #t3 = id_list[i]
    move $a0, $t3
    
    #credit_list
    add $t2, $t0, $t7 #address of credits_list
    lw $t3, 0($t2) #t3 = credit_list[i]
    move $a1, $t3

    #pointer to name
    move $a2, $t8
    
    name_loop:
      lb $t4, 0($t8)
      beqz $t4, done_loop
      addi $t8, $t8, 1
      j name_loop
    done_loop:

    #pointer to record
    sll $t0, $t9, 3 #multiply indx by 8
    sub $sp, $sp, $t0 #get indx of next record

    move $a3, $sp 

    addi $t8, $t8, 1
    addi $t1, $t1, -1
    addi $t9, $t9, 1

    # call init_student and save return value in $sp
    jal init_student

    # Move contents of $a3 (initialized student) into memory pointed by $sp
    sw $a3, 0($sp)   # Store the initialized student in the memory pointed by $sp
    j loop
  done:

  jr $ra  # Return from the function

	
insert:
  #array of pointers to student records
  #empty item: null pointer
  #when student record is deleted, item is replaced by -1 (0xFFFFFFFF)
  #given pointer to student record, insert the pointer to the hash table
  #if occupied, use linear probing to find empty index

  #return -1 if hash table is full and record could not be inserted
  #return array index the record was inserted in


  #$a0: pointer to student record
  #$a1: pointer to hash table
  #$a2: table_size
  #$v0: array index stored in or -1
	jr $ra
	
search:
	jr $ra

delete:
	jr $ra
