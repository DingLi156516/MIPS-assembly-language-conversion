.data
	size:   .word 16
        stri: 	.word str_datai
        str_datai: .asciiz "Initial array:\n"
	strs: 	.word str_datas
	str_datas: .asciiz "Sorted array:\n"
	l: 	.word left
        left: .asciiz "["
        r: 	.word right
        right: .asciiz " ]\n"
           		
          dataArray:        	
                  	.align 2  # addresses should start on a word boundary
                  	.space 64 # 16 pointers to strings: 16*4 = 64

	  dataName:
	           	.align 5  # in the example, names start on a 32-byte boundary
	  		.asciiz " Joe"
           		.align 5
           		.asciiz " Jenny"
           		.align 5
           		.asciiz " Jill"
           		.align 5
           		.asciiz " John"
           		.align 5
           		.asciiz " Jeff"
           		.align 5
           		.asciiz " Joyce"
           		.align 5
           		.asciiz " Jerry"
           		.align 5
           		.asciiz " Janice"
           		.align 5
           		.asciiz " Jake"
           		.align 5
           		.asciiz " Jonna"
           		.align 5
           		.asciiz " Jack"
           		.align 5
           		.asciiz " Jocelyn"
           		.align 5
           		.asciiz " Jessie"
           		.align 5
           		.asciiz " Jess"
           		.align 5
           		.asciiz " Janet"
           		.align 5
           		.asciiz " Jane"
.text
 
	 main:
	 	# const char * data[] = {"Joe", "Jenny", "Jill", "John","Jeff", "Joyce", "Jerry", "Janice","Jake", "Jonna", "Jack", "Jocelyn","Jessie", "Jess", "Janet", "Jane"};
	 	la $t0, dataName
	 	la $t1, size
	 	lw $t1, 0($t1)
	 	li $t2,0
	 	# int i = 0;
	 	li $t3,0
	 	# loop is used to load each string into array
	 loop:
	 	sw $t0,dataArray($t2)
	 	addi $t0,$t0,32
	 	addi $t2,$t2,4
	 	addi $t3,$t3,1
	 	blt $t3,$t1,loop
	 	# printf("Initial array:\n")
	 	la $a0,str_datai
	 	jal print
	 	# jump to print array function
	 	# print_array(data, size);
	 	jal printarray
	 	# printf("Sorted array:\n")
	 	la $a0,str_datas
	 	jal print
	 	# load dataArray and len as arguments for quicksort
	 	la $s1, size
	 	li $a0,0
	 	lw $a1,($s1)
	 	# quick_sort(data, size)
	 	jal quicksort
	 	# print_array(data, size)
	 	jal printarray
	 	# exit(0)
	 	j exit
	 quicksort:
	 	# making space for CF
		subu $sp,$sp,200
		# save return address on CF 
		sw $ra,196($sp)
		# save frame pointer in stack 
		sw $fp,192($sp)
		# make the frame pointer point to the base of the call frame 
		addu $fp,$sp,200 
		# if (len <= 1) {
    		# return;
  		# }
		ble $a1,1,return2
		# store initial *a[]
		move $s4,$a0
		# int pivot = 0
		li $s0,0
		# len - 1
		sub $s1,$a1,1
		# i=0
		li $s2,0
		
	loop3:
		move $a0,$s2
		move $a1,$s1
		move $a2,$s4
		# store all the values that suitable
		sw $s0,0($sp)
		sw $s1,4($sp)
		sw $s2,8($sp)
		sw $s4,12($sp)
		# str_lt()
		jal strlt
		move $s3,$v0
		lw $s0,0($sp)
		lw $s1,4($sp)
		lw $s2,8($sp)
		lw $s4,12($sp)
		move $a0,$s2
		move $a1,$s0
		move $a2,$s4
		#swap pointers
		bne $s3,0,swapstrptrs
	returnhere:
		beq $s3,0,plus
		addi $s0,$s0,1
	plus:
		addi $s2,$s2,1
		blt $s2,$s1,loop3
		move $a0,$s0
		move $a1,$s1
		move $a2,$s4
		#swap pointers
		jal swapstrptrs2
		# quick_sort(a, pivot)
		move $a0,$s4
		move $a1,$s0
		sw $s0,0($sp)
		sw $s1,4($sp)
		sw $s2,8($sp)
		sw $s4,12($sp)
		sw $s3,16($sp)
		jal quicksort
		lw $s0,0($sp)
		lw $s1,4($sp)
		lw $s2,8($sp)
		lw $s4,12($sp)
		lw $s3,16($sp)
		#quick_sort(a + pivot + 1, len - pivot - 1);
		move $a0,$s4
		add $a0,$a0,$s0
		addi $a0,$a0,1
		move $a1,$s1
		sub $a1,$a1,$s0
		sw $s0,0($sp)
		sw $s1,4($sp)
		sw $s2,8($sp)
		sw $s4,12($sp)
		sw $s3,16($sp)
		jal quicksort
		lw $s0,0($sp)
		lw $s1,4($sp)
		lw $s2,8($sp)
		lw $s4,12($sp)
		lw $s3,16($sp)
		# return to main
	 	b return2
	 swapstrptrs:
	 	move $t1,$a1
	 	add $t1,$t1,$a2
	 	mul $t1,$t1,4
	 	move $t0,$a0
	 	add $t0,$t0,$a2
	 	mul $t0,$t0,4
	 	#&a[i]
	 	la $t2,dataArray($t0)
	 	#&a[pivot]
	 	la $t3,dataArray($t1)
	 	#const char *tmp = *s1;
  		#*s1 = *s2;
  		#*s2 = tmp;
	 	lw $t4,0($t3)
	 	lw $t5,0($t2)
	 	sw $t4,0($t2)
	 	sw $t5,0($t3) 
	 	j returnhere
	 swapstrptrs2: 
	 	move $t1,$a1
	 	add $t1,$t1,$a2
	 	mul $t1,$t1,4
	 	move $t0,$a0
	 	add $t0,$t0,$a2
	 	mul $t0,$t0,4
	 	#&a[pivot]
	 	la $t2,dataArray($t0)
	 	#&a[len - 1]
	 	la $t3,dataArray($t1)
	 	#const char *tmp = *s1;
  		#*s1 = *s2;
  		#*s2 = tmp;
	 	lw $t4,0($t3)
	 	lw $t5,0($t2)
	 	sw $t4,0($t2)
	 	sw $t5,0($t3)
	 	jr $ra
	 	
	 strlt:
	 	# making space for CF
	 	subu $sp,$sp,76 
	 	# save return address on CF
		sw $ra,72($sp) 
		# save return address on CF
		sw $fp,68($sp) 
		# make the frame pointer point to the base of the call frame
		addu $fp,$sp,76
		add $a0,$a0,$a2
		add $a1,$a1,$a2 
		mul $a0,$a0,4
	 	mul $a1,$a1,4
	 	lw $a0,dataArray($a0)
	 	lw $a1,dataArray($a1)
	 loop4:	
	 	#load byte of a[i]
	 	lb $t0, 0($a0)
	 	#load byte of a[len - 1]
	 	lb $t1, 0($a1)
	 	move $s0,$a1
	 	#*x!='\0' && *y!='\0'
	 	beq $t0,$zero,judge1  
		beq $t1,$zero,judge1
		#if ( *x < *y ) return 1
	 	blt $t0,$t1,strreturn1
	 	#if ( *y < *x ) return 0
	 	bgt $t0,$t1,strreturn0
	 	addi $a0,$a0,1
	 	addi $a1,$a1,1
		j loop4
	judge1:
		lb $t0,0($s0)
		#if ( *y == '\0' ) return 0
		beq $t0, $zero, strreturn0
		#else return 1
		bne $t0, $zero, strreturn1  	
	strreturn1:
		addi $v0,$zero,1
		b return3
	strreturn0:
		addi $v0,$zero,0
		b return3	
	return2:
    		lw $ra,196($sp)
		lw $fp,192($sp)
		addu $sp,$sp,200
		jr $ra
	return3:
		lw $ra,72($sp)
		lw $fp,68($sp)
		addu $sp,$sp,76
		jr $ra
		
	printarray:
	 	# making space for CF
    		subu $sp,$sp,76 
    		# save return address on CF
		sw $ra,72($sp)
		# save frame pointer in stack 
		sw $fp,68($sp)
		# save callee saved register 
		sw $s0,64($sp)
		# make the frame pointer point to the base of the call frame 
		addu $fp,$sp,32 
    		# printf("[");
    		la $a0, left
    		jal print
    		#int size = 16
	 	la $s1,size
	 	lw $s1,0($s1)
	 	li $s2,1
	 	li $s3,0
	 	#for (int i = 0; i < size; i++) {
    		#printf(" %s", a[i]);
  		#}
  		#loop2 is used to print array
	 loop2:
	 	bgt $s2,$s1,printright 
	 	lw $a0,dataArray($s3)
	 	li $v0,4
	 	syscall
	 	addi $s2,$s2,1
	 	addi $s3,$s3,4
	 	j loop2
	 	#printf(" ]\n");
    	printright:
    		la $a0, right
    		jal print
    		b return
    		#function to return to the mian
    	return:
    		lw $ra,72($sp)
		lw $fp,68($sp)
		lw $s0,64($sp)
		addu $sp,$sp,72
		jr $ra
		#print string			
    	print:
    		li $v0, 4
    		syscall
    		jr $ra	 
    	exit:
    		li $v0 10
    		syscall
