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
  
  #move $t8, $a3 #$t8 holds pointer to name
  #move $t7, $a2 #$t7 holds credits_list
  #move $t6, $a1 #$t6 holds id_list
  
  
  #ok i'm going to store everything above. 
  
  lw $t5, 0($sp)

  addi $sp, $sp, -20
  sw $ra, 0($sp)
  sw $s0, 4($sp)
  sw $s1, 8($sp)
  sw $s2, 12($sp)
  sw $s3, 16($sp)
  move $s0, $a3 #s0 stores pointer to name, t8
  move $s1, $a2 #s1 stores credits_list, t7
  move $s2, $a1 #s2 stores id_list, t6
  li $s3, 0 ##s3: initialize counter, t9
  
  
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
    #sll $t0, $s3, 3 #multiply indx by 8
    
    #add $t5, $t5, $t0 #get indx of next record

    move $a3, $t5 

    addi $s0, $s0, 1
    addi $t1, $t1, -1
    addi $s3, $s3, 1

    # call init_student, this function saves student data to $a3
    jal init_student
    
    addi $t5, $t5, 8

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
  # $a0: pointer to student record
# $a1: pointer to hash table
# $a2: table_size
# $v0: array index stored in hash, or -1

# Make space in $sp, save registers
	addi $sp, $sp, -12  # Allocate space on the stack
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	sw $s1, 8($sp)  # Store pointer to hash table in $s1

# Load student id+credits
	lw $s0, 0($a0)  # Load id and credits into $s0
	srl $s0, $s0, 10  # Isolate the student's id
	move $t6, $s0 #store copy of student id in $t6
	div $s0, $a2  # Get the index of the current student in the hash table. ex: 3
	mfhi $s0  # INDEX IN HASH TABLE, without offset = 3

# Copy original index in hash table
	move $t1, $s0  # $t1 holds a copy of the original index in the hash table = 3
	li $t0, 4  # $t0 contains the word offset
	li $t1, -1  # TOMBSTONE VAL
	
	move $t5, $s0 #contains copy of original indx, again
	

# Loop: calculate and check whether the current index is occupied
# Within loop: do linear probing. Each time I linearly probe, check again
  # Check if empty -> insert, $v0 = index
  # Check if -1 -> insert, $v0 = index
  # Linear probe
    # If end up back at the original index, $v0 = -1

check_index:
  mul $t2, $t5, $t0 #get index in hash table, accounting for word size
  add $s1, $a1, $t2 #get address of index in hash table
  lw $t2, 0($s1) #get word from address of index in hash table
  beqz $t2, insert_to_table #if empty, insert
  beq $t2, $t1, insert_to_table #if word == TOMBSTONE_VAL, insert
  
  #else, we need to linear probe.
  addi $t6, $t6, 1 #increment the student's ID by one
  div $t6, $a2 #divide (id+1)/MAX
  mfhi $t5 #store remainder in $t5
  
  beq $t5, $s0, hash_full #if we get back to original index, the hash table is full.
  
  j check_index



  insert_to_table:
  	sw $a0, 0($s1)  # Store in $s1 
  	move $v0, $t5  # Contents
  	j exit


  hash_full:
  	li $v0, -1
  	j exit

  exit:
  	lw $ra, 4($sp)
  	lw $s0, 0($sp)
  	lw $s1, 8($sp)
  	addi $sp, $sp, 12

  jr $ra
	
	

search:
  #$a0: student id (integer)
  #$a1: address of hash table
  #$a2: table size

  # Search for matching student record using linear probe algorithm
  # Skip over the tombstone value when searching for a match
  # Return in $v0: pointer to student record if found, 0 if not
  # Return in $v1: array index in hash table where record was found, -1 if none found

  div $a0, $a2 # divide id by table size to get array index
  mfhi $t2 # $t0 = array index
  addi $sp, $sp, -8

  li $t0, 4  # $t0 contains the word offset
  li $t1, -1 #TOMBSTONE

  # Get index in the original array
  move $t5, $a0  # Copy student id
  sw $s0, 0($sp)
  sw $ra, 4($sp)

  move $s0, $t2  # Store remainder in $s0
  move $t4, $a1  # Copy address of hash table

find_elem:
  mul $t3, $t2, $t0  # Get index in the hash table, accounting for word offset
  add $t4, $a1, $t3  # Update address of the hash table
  lw $t6, 0($t4)  # Get address of student record. I'm confused - what's stored in the hash table exactly? -
  beq $t6, $t1, increment #skip over the tombstone value
  beqz $t6, increment 
 
  lw $t7, 0($t6)  # Load the student ID from the student record
  srl $t7, $t7, 10  # Extract the student ID (22 bits)

  beq $t7, $a0, found_elem  # Compare the loaded student ID with the input student ID

increment:		
  addi $t5, $t5, 1  # Increment ID by one
  div $t5, $a2  # Divide (id+1)/MAX
  mfhi $t2  # Store remainder in $t2
  beq $t2, $s0, not_found  # If back to the original index, student was not found
  j find_elem

found_elem:
  move $v0, $t6  # Pointer to student record
  move $v1, $t2  # Array index in hash table
  j exit_loop
not_found:
  li $v0, 0
  li $v1, -1
  j exit_loop

exit_loop:
  lw $ra, 4($sp)
  lw $s0, 0($sp)
  addi $sp, $sp, 8

  jr $ra


delete:
  #$a0: int id
  #$a1: struct student *table[]
  #$a2: int table_size

  #calls search. 
  #search for an item, then replace it with the tombstone value
  #if item not found, return -1. if found, return the array index where it was found

  addi $sp, $sp, -8 #create space on stack to store $ra
  sw $ra, 0($sp) #store $ra on stack
  sw $s0, 4($sp)
  li $t0, -1 #tombstone value
  li $t1, 4 #offset val

  jal search #call search 
  move $s0, $v0
  #if $v0 is null, then move $v0, -1
  beqz $s0, search_failed
  #otherwise, we have found the item. 
  # now, $v1 contains the index within the array, not multiplied by 4
  #so now we go in and replace hash[index] with $t0
  move $t3, $v1 #store index in $t3

  #replace.
  mul $t2, $t1, $t3 #get index in hash table, accounting for offset
  add $t4, $a1, $t2
  sw $t0, 0($t4) #replace pointer with $t1, which is the tombstone value
  move $v0, $t3 #move value in
  move $v1, $0 #clear $v1
  j end_delete
  



  search_failed:
    li $v0, -1
    j end_delete


  end_delete:
  lw $ra, 0($sp) #load back $ra
  lw $s0, 4($sp) #load back $s0
  addi $sp, $sp, 8 #deallocate space on stack 
 
  jr $ra