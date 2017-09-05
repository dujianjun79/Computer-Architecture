# File Header
# finalproject.asm
# Jianjun Du
# disamble MIPS machine code to assemble language code for any proceeding programs
# Need to input machine code from file, and output the assemble code to another file

# Procedure Header:assmeble
# The procedure returns the assemble language code for one instruction
# Jianjun Du

#This part of programming is extracting data from a file, and transfer them from string to integers.
.data

file:
	  .asciiz "input.txt"	          # File name
	  .word	    0
buffer:	  .space   1024		         # Place to store character
myarray:    .space   1024
prompt3:    .asciiz "The decoded instruction is:\n"

	.text
main:

# Open File

	li	$v0, 13			# 13=open file
	la	$a0, file		          # $a2 = name of file to read
	add	$a1, $0, $0		# $a1=flags=O_RDONLY=0
	add	$a2, $0, $0		# $a2=mode=0
	syscall				# Open FIle, $v0<-fd
	add	$s0, $v0, $0	         # store fd in $s0


# Read 4 bytes from file, storing in buffer
	li	$v0, 14			# 14=read from  file
	add	$a0, $s0, $0	          # $s0 contains fd
	la	$a1, buffer		# buffer to hold int
	li	$a2, 1024			# Read 4 bytes
	syscall

# Close File
done:
	li	$v0, 16			# 16=close file
	add	$a0, $s0, $0	        # $s0 contains fd
	syscall				# close file


	la $s0,buffer     # pass address of buffer to s0
	li $t2,0          # used in atoi()
	la $s1,myarray    # integers stored in myarray
	li $t3,0          # track how many instructions in the file
	
sum_loop:               # This is the algorithm tranferring string to integer
	lb $t1,($s0)	
	addu $s0,$s0,1
	beq $t1,'q', exit         # in the end of the file, there is a 'q' to quit from the file
          beq $t1,13,nextline       # fetch next line of instruction
          mul $t2,$t2,10	
	sub $t1,$t1,'0'          # t1=t1-'0'	
	add $t2,$t2,$t1		        		
	j sum_loop
	
nextline:	
          addu $t3,$t3,1       # track how many instructions
	
	sw $t2,($s1)
	addu $s1,$s1,4      # an integer occupies 4 bytes
	addu $s0,$s0,1      # jump over the '\n' character
	li $t2,0            # reset the intege initiation
		
	j sum_loop
exit:
	la $a0,prompt3           #  load the string "\nThe decoded instructions are:"
	li $v0,4                 #  print the string to output
	syscall
          la $a0, myarray          # a pointer to the first array
          move $a1,$t3             # second parameter for the procedure, the dimension of the arrays
          jal assemble
        
          li $v0, 10               # exit system
	syscall

#This part of programming is fetching  instruction from machine code
.data
newline:   .asciiz "\n"
blank:     .asciiz " "
comma:     .asciiz ", "
dollar:    .asciiz "$"
left:      .asciiz "("
right:     .asciiz ")"
I0:  .asciiz "beq"
I1:  .asciiz "bne"
I2:  .asciiz "blez"
I3:  .asciiz "bgtz"
I4:  .asciiz "addi"
I5:  .asciiz "addiu"
I6:  .asciiz "slti"
I7:  .asciiz "sltiu"
I8:  .asciiz "andi"
I9:  .asciiz "ori"
I10: .asciiz "xori"
I11: .asciiz "lui"
I12: .asciiz "lb"
I13: .asciiz "lh"
I14: .asciiz "lw"
I15: .asciiz "sw"
j0:  .asciiz "j"
j1:  .asciiz "jal"
j2:  .asciiz "jr"
j3:  .asciiz "jalr"
s0:  .asciiz "syscall"
R0:  .asciiz "sll"
R1:  .asciiz "srl"
R2:  .asciiz "mult"
R3:  .asciiz "add"
R4:  .asciiz "addu"
R5:  .asciiz "sub"
R6:  .asciiz "subu"
R7:  .asciiz "mfhi"
R8:  .asciiz "mflo"


.text
assemble:
          addi $sp, $sp, -8        # callee frame, save the registers used by caller          
          move $s6,$a0             # pointer to the array
          move $s7,$a1             # store the demension of the array
          li $t7,0                 # initialize the loop control to zero
  innerloop:
    	beq $s7,$t7,inner_exit   #  if s7==t7, we are out of loop
          lw $t0,($s6)             # load instruction from the array	
	srl $t1,$t0,26     
	move $s0,$t1             # $s0 holds the opcode
	beqz $t1,Rtype

    Itype:                                                        
          sll $t1,$t0,6
          srl $t2,$t1,27
          move $s1,$t2        # $s1 holds rs
          
          sll $t1,$t0,11
          srl $t2,$t1,27
          move $s2,$t2        # $s2 holds rt
                             
          sll $t1,$t0,16
          srl $t2,$t1,16
          move $s3, $t2      # $s3 holds constant or address
          
          beq $s0,2,switch_j0
          beq $s0,3,switch_j1
          beq $s0,3,switch_j1
          beq $s0,4,switch_0
          beq $s0,5,switch_1
          beq $s0,6,switch_2
          beq $s0,7,switch_3
          beq $s0,8,switch_4
          beq $s0,9,switch_5
          beq $s0,10,switch_6
          beq $s0,11,switch_7
          beq $s0,12,switch_8
          beq $s0,13,switch_9
          beq $s0,14,switch_10
          beq $s0,15,switch_11
          beq $s0,32,switch_12
          beq $s0,33,switch_13
          beq $s0,35,switch_14
          beq $s0,43,switch_15
          beq $s0,0,Rtype
          
          j switch_exit

switch_j0:     
          sll $t1,$t0,6
          srl $t2,$t1,4       # only shift 4 bits, because address is word, which means the bytes are four times
          move $s1,$t2        # $s1 holds target 
          
          
          li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, j0
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,34
          move $a0,$s1
          syscall
          
	j switch_exit

switch_j1:
	li $v0,4
          la $a0,newline
          syscall
                    
          sll $t1,$t0,6
          srl $t2,$t1,6
          move $s1,$t2        # $s1 holds target
          move $a0,$t2
          li $v0,1
          syscall
          
          li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, j1
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,34
          move $a0,$s1
          syscall

	j switch_exit
switch_0:
          li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, I0
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s3
          syscall
          
          j switch_exit
          
switch_1: 
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, I1
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s3
          syscall
          
          j switch_exit
          
switch_2: 
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, I2
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s3
          syscall
          
          j switch_exit

switch_3:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, I3
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s3
          syscall
          
	j switch_exit

switch_4:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, I4
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s3
          syscall
          
	j switch_exit

switch_5:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, I5
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s3
          syscall
          
	j switch_exit

switch_6:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, I6
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s3
          syscall
          
	j switch_exit

switch_7:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, I7
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s3
          syscall
          
	j switch_exit
	
switch_8:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, I8
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s3
          syscall
          
	j switch_exit

switch_9:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, I9
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s3
          syscall
          
	j switch_exit

switch_10:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, I10
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s3
          syscall
          
	j switch_exit

switch_11:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, I11
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
                  
          li $v0,1
          move $a0,$s2
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s3
          syscall
          
	j switch_exit
          
switch_12:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, I12
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s3
          syscall
          
          li $v0,4
          la $a0,left
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,right
          syscall
          
          j switch_exit
          
switch_13:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, I13
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
                  
          li $v0,1
          move $a0,$s2
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s3
          syscall
          
	j switch_exit
	
switch_14:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, I14
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s3
          syscall
          
          li $v0,4
          la $a0,left
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,right
          syscall
          
          j switch_exit

switch_15:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, I15
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s3
          syscall
          
          li $v0,4
          la $a0,left
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,right
          syscall
          
          j switch_exit
          
Rtype:                   
          sll $t1,$t0,6
          srl $t2,$t1,27
          move $s1,$t2      # $s1 holds rs
                   
          sll $t1,$t0,11
          srl $t2,$t1,27
          move $s2, $t2    # $s2 holds rt
                             
          sll $t1,$t0,16
          srl $t2,$t1,27
          move $s3,$t2     # $s3 holds rd
                    
          sll $t1,$t0,21
          srl $t2,$t1,27
          move $s4,$t2     # $s4 holds shamt
                   
          sll $t1,$t0,26
          srl $t2,$t1,26
          move $s5,$t2    # $s5 holds funct
          
          beq $s5,8,switch_j2
          beq $s5,9,switch_j3
          beq $s5,12,switch_s0
          beq $s5,0,switch_R0
          beq $s5,2,switch_R1
          beq $s5,24,switch_R2
          beq $s5,32,switch_R3
          beq $s5,33,switch_R4
          beq $s5,34,switch_R5
          beq $s5,35,switch_R6
          beq $s5,16,switch_R7
          beq $s5,18,switch_R8
                    
switch_j2:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, j2
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall 
                   
	j switch_exit
switch_j3:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, j3
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
                  
          li $v0,1
          move $a0,$s3
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
	j switch_exit
switch_s0:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, s0
          syscall
          
	j switch_exit
          
switch_R0:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, R0
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
                  
          li $v0,1
          move $a0,$s3
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s4
          syscall
	
	j switch_exit

switch_R1:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, R1
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
                  
          li $v0,1
          move $a0,$s3
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,34
          move $a0,$s4
          syscall
	j switch_exit

switch_R2:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, R2
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
                  
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
	j switch_exit
          
switch_R3:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, R3
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
                  
          li $v0,1
          move $a0,$s3
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
	j switch_exit
          
switch_R4:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, R4
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
                  
          li $v0,1
          move $a0,$s3
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
	j switch_exit
          
switch_R5:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, R5
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
                  
          li $v0,1
          move $a0,$s3
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
	j switch_exit
          
switch_R6:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, R6
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
                  
          li $v0,1
          move $a0,$s3
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s1
          syscall
          
          li $v0,4
          la $a0,comma
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          move $a0,$s2
          syscall
          
	j switch_exit
          
switch_R7:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, R7
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
                  
          li $v0,1
          move $a0,$s3
          syscall
          
          j switch_exit
          
switch_R8:
	li $v0,4
          la $a0,newline
          syscall
          
          li $v0,4
          la $a0, R8
          syscall
          
          li $v0,4
          la $a0,blank
          syscall
          
          li $v0,4
          la $a0,dollar
          syscall
                  
          li $v0,1
          move $a0,$s3
          syscall
          
          j switch_exit

switch_exit:
	addi $s6,$s6,4           #  point to the next element of the arrays           
          addi $t7,$t7,1           #  add 1 to the loop control
          j innerloop
          
inner_exit:
	addiu $sp, $sp, 8        # restore the stack pointer
          jr $ra                   # return to the caller
         
	
