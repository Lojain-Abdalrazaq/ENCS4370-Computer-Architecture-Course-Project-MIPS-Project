################################################## the 1st project in ENCS4370 ##################################################
### ***************************** Done by:       Aseel Deek , Lojain Abdalrazaq      *****************************************###
### -------------------> A Simple Dictionary-based Compression and Decompression Tool in MIPS Assembly   <------------------- ###
#################################################################################################################################
.text
.globl main
	
main:
# menu infinit loop
	# asking the user if the dictionary exist or not
	la $a0, dict_existion # ask the user if the dict file is exist or not
	li $v0, 4 	      # load the value 4 to the $v0 to print the string
	syscall
	
 	# read the string answer
	li $v0, 8
	la $a0, dict_answer   # save the address of the buffer that we will save the input string in
	li $a1, 10	      # here is the max. number of the inout char
	syscall
	
	# now, we want to check the answer of the user is "yes" or "no"
	la $t0, dict_answer    	# load the address of the user input string to $t0
	la $t7, dict_answer    
	la $t1, yes_answer 	# load the address of the "yes" buffer
	la $t2, no_answer      	# load the address of the "no" buffer     
	li $t3,0               	# set the counter to 0 --> to calculate the length of the input string

# the end of the loop, the input string length will be stored in the $t3	
find_length: 
        lb $t4,($t7)          	# load character by charecter of the input string to the $t4 reg
        beqz $t4, finish_cout   # when we reach the end of the string --> equals to 0
        addi $t7, $t7 1         # increament the address pointer on the input string
        addi $t3, $t3,1         # either, increament  the counter $t3 by 1 
        j find_length
        
# checking the inout string, if yes, no, or print an error message       
finish_cout:      
        addi $t3,$t3,-1   	   	# substract the \n char form the input string, then check
        beq $t3, 3, check_if_yes  	# if the length of the input is equal to "3", check if it is yes
        beq $t3, 2, check_if_no   	# if the length of the inpout is equal to "2", then check if it is no
        bge $t3,4, error_message  	# if the message is greater than or equal 4, then print an error message
        blt $t3, 2, error_message 	# or the messgage is one char, then print an error message
         
        
        la $t0, dict_answer
        
# in this loop, we will compare between each char, if it was "yes" or "no", or invalid answer
check_if_yes:
	lb $t5, ($t0)     		# load a byte by byte from input string
        lb $t6, ($t1)     		# load a byte from target string "yes"
        beqz $t6, ans_is_yes_1   	# if end of target string "yes", go to equal_yes
        bne $t6, $t5, exitTheProgram 	# if the chars are not equals
        addi $t0, $t0, 1   		# increment input string pointer
        addi $t1, $t1, 1   		# increment target string pointer
        j check_if_yes
	
check_if_no:
	lb $t5, ($t0)     		# load a byte from inp ut string
        lb $t6, ($t2)     		# load a byte from target string "no"
        beqz $t6, ans_is_no 		# if end of target string "no", go to equal_yes
        bne $t6, $t5, exitTheProgram 	# if the chars are not equals
        addi $t0, $t0, 1   		# increment input string pointer
        addi $t2, $t2, 1   		# increment target string pointer
        j check_if_no
        
# this will print an error message when the input has invalid number of chars        
error_message: 
        la $a0,error_option   		# load the address of the error option to $a0 reg
        li $v0,4	       		# $v0 -> 4 to print string
        syscall
        j  exitTheProgram 		 
  
# chose the compresssion or the decompression  operations       
ans_is_yes_1:
	jal ans_is_yes
	j Copress_Or_Decompress 
	      
# if the dict_file is exist, then take its path, and check if it exists.
ans_is_yes:
# printing the statement for user to enter the dictionary.txt file path 
        la $a0,file_path_sentence  	# load the address of the error option to $a0 reg
        li $v0,4	       		# $v0 -> 4 to print string
        syscall
        
# then, we want to enter the path of the dictionary.txt file 
	li $v0, 8	      		# read the string answer
	la $a0, file_path   		# save the address of the buffer that we will save the input string in
	li $a1, 100	      		# here is the max. number of the input char
	syscall
	
# after taking the input file path, we will remove the '\n' char and replace it with '\0'
	la $s0,file_path 		# loading the address of the input file path
	add    $s2, $0, $0    		# $s2 = 0
    	addi    $s3, $0, '\n'    	# $s3 = '\n'
	
find_newLine:
	lb    $s1, 0($s0)    			# load character into $s0
        beq    $s1, $s3, replace_newline  	# Break if byte is newline
        addi    $s2, $s2, 1    			# increment counter
        addi    $s0, $s0, 1    			# increment str address
        j  find_newLine

# replacing the new line value which 0 which referes to the end of the line of char
replace_newline:
	sb $zero,0($s0)  
# now, after replaceming the new line, we will read the file and load the its content to the buffer
	li $v0, 13     			# system call to open the file
	la $a0, file_path  		# address of the string that contains the file path
	li $a1, 0   			# for the flag
	li $a2, 0   			# for the mode 
	syscall
# checking the existance of the file
	blt  $v0, 0, invalid_file_path 	# if the value of $v0 is not 0, then the file does not exist
	move $s0,$v0 			# save the file descriptor in $s0
# reading the file
	li $v0,14  			# system call to read the file, and load its values
	move $a0, $s0       		# File descriptor
   	la $a1, dict_word_buffer  	# Address of the buffer to store file contents
   	li $a2, 256         		# Maximum number of characters to read
	syscall             		# Read from the file
# closing the file
	li $v0, 16    			# system call to close the file
	move $a0,$s0     		# file descriptor to close
	syscall
	jr $ra 				# now, we saved the value of the input file path into the >> DICT BUFFER
	
		
# the invalid sentence will be printed when the file path does not exists
invalid_file_path:
        la $a0,error_file_path   	# load the address of the error option to $a0 reg
        li $v0,4	       		# $v0 -> 4 to print string
        syscall
	j  exitTheProgram 
	
# if the file does not exists, then create the file 'dictionary.txt'.
ans_is_no:
	
	li $v0,13 			# system call for opening the file
	la $a0, create_dict_file 	# load the addrss of the file path that want to create in
	li $a1,1   			# 1 for the writing mode only
	syscall
	move $s0,$v0    		# saving the file descriptor
	li $v0, 16   			# close the file mode
	move $a0,$s0   			# moves the value of the $s0 to the $a0
	syscall
	bge $a0,0,Copress_Or_Decompress  # the file is created succesfully
        j QuitProgram

Copress_Or_Decompress:
	la $a0,compress_decompress   	# load the address of the compresstion or decompression options to $a0 reg
        li $v0,4	             	# $v0 -> 4 to print string
        syscall
        li $v0, 12  			# syscall code for reading char from the user
	syscall
	move $t0,$v0
	beq $t0,'c', compresstion   	# compression 
	beq $t0,'d', decompression 	# decompression 
	beq $t0,'q', exitTheProgram 	# quit from program
	b error_message            	# if the option is ivalid, we print an error message 
	
##################################################################################################################################
## ************************************************** START COMPRESSION *******************************************************## 
##################################################################################################################################
compresstion:

	jal ans_is_yes			# Call the yes_function 
	jal resetRegisters		# reset registers   
	        
        la $s3, delimiters		# load the address of delimiters into $s3
        la $s1, word_buffer		# initialize the word pointer to the beginning of the buffer         
        la $s2, spcialchar_buffer   	# initialize the word pointer to the beginning of the buffer     
        
        li $t5, 0 			# reg $t5, will be be the binary codes for each word         
        li $s7, 0 			# register to clculate the compression unicdoe       
        li $t4, 0  			# register to count number of lines in compress file
        
# open the input file to read it
OpenFile:        
	li $v0,13           		# open the entred file 
    	la $a0, file_path     		# get the file name
    	li $a1,0           		# file flag = read (0)
    	syscall
    	move $s0,$v0        		# save the file descriptor. $s0 = file
    	
# Open the compressed file  
	li $v0, 13     			# system call for opening a file for writing
	la $a0, fileCompres 		# load the address of the filename into $a0
	li $a1, 1       		# flag for writing
	syscall        			# execute the system call
	move $s5, $v0  			# save the file descriptor in $s4 = for dictfile	
    	   	
ReadFile:	
	
	li $v0, 14			# read_file syscall code = 14
	move $a0,$s0			# file descriptor
	la $a1,fileWords  		# The buffer that holds the string of the WHOLE file ( fileWord = He!Do. )
	li $a2,1024			# hardcoded buffer length
	syscall 
	move $t3,$v0			# save number  of chars in the input file in $t3 
	
PrintFileContent:		

# print whats in the file in the console, 
	li $v0, 4	
	la $a0,fileWords
	syscall 
	
# print space on the concoul
	li $v0, 11
  	li $a0, '\n' 			
	syscall
	
# *******************************************************************************************************************************#		
#****************************             Start Reading the file(input file) content              *****************************************##
# *******************************************************************************************************************************#	
	
	la $a3, fileWords 		# load the address into $t0
	j loop 				# start the spliting to do the dict, and compresion
	li $t6, 0			# to count size of the word to be stored in the file
	
# loop through the sentence string
loop:
	
        lbu $t0, ($a3)   			# load the current character into $t0 
        beq $t0, $zero, printRatioandQuit    	# if the character is null (end of string), exit the loop 
                
# loop through the delimiters string     
        check_delimiters:
               	
           lbu $t1, ($s3)    		# load the current delimiter into $t1                          
           beq $t1, $zero, next_char   	# if the delimiter is null (end of string), it's not a delimiter, so continue to next character                             
           beq $t0, $t1, store_word   	# if the character is equal to the delimiter, it's a delimiter, so jump to store_word                                       
           addi $s3, $s3, 1 		# if the character is not equal to the delimiter, continue to next delimiter
           j check_delimiters  
                    
        j loop                         # if we reach this point, it's not a delimiter, so add the character to the current word

# move to the next memory location for the next word
next_char:
	sb $t0, ($s1) 			# store the value of the current charater in an address
    	addi $s1, $s1, 1  		# increment the word pointer	
        addi $a3, $a3, 1 		# move one to the next char 
        la $s3, delimiters 		# point to the beginning of the delimiters string      
        addi $t6, $t6, 1 		# continue to next character
        j loop
        
                    
# store the last word (if any) in memory, save the value of chars 
store_word:

	
        sb $zero, ($s1)    		# store the null terminator        
    	la $s1, word_buffer 		# reset the word pointer to the beginning of the buffer
    	lb $t7, 0($s1) 			# read the first byte of the word array
    	beqz $t7, addNewDelimiter 	# if the first byte of the word array zero, it means printSpace after the delimiter
    	
        
    	li $v0, 4		
	la $a0,word_buffer 		# print the word beffer content
	syscall
	
	li $v0, 11
  	li $a0, '\n' 			# print space on the concoul
  	syscall 
  
  		
# Open the file: 
	li $v0, 13     			# system call for opening a file for writing
	la $a0, fileOut 		# load the address of the filename into $a0
	li $a1, 0      			# flag for writing
	syscall        			# execute the system call
	move $s4, $v0  			# save the file descriptor in $s4 = for dictfile	
#read the file
	li $v0, 14			# read_file syscall code = 14
	move $a0,$s4			# file descriptor
	la $a1,hash_table  		# The buffer that holds the string of the WHOLE file
	li $a2,1024			# hardcoded buffer length
	syscall 
	move $t9, $v0	
#Close the file
    	li $v0, 16         		# close_file syscall code
    	move $a0,$s4      		# file descriptor to close
    	syscall
    	
# decide what to do: write direct, checkduplication     	
	beqz $t9, startWriting
	bnez $t9, check_duplication 
	
startWriting: 			   	     		   	     
#Re-Open the file for writing
	li $v0, 13     		# system call for opening a file for writing
	la $a0, fileOut 	# load the address of the filename into $a0
	li $a1, 1      		# flag for writing
	syscall        		# execute the system call
	move $s4, $v0  		# save the file descriptor in $s4 = for dictfile	 		
		
# Write the buffer to the file
	li $v0, 15     		# system call for writing to a file
	move $a0, $s4  		# move the file descriptor to $a0
	la $a1, word_buffer  	# load the address of the buffer into $a1
	move $a2, $t6     	# number of bytes to write (12 for a single integer)
	syscall        		# execute the system call
	li $t6, 0 
	
	
		     	
# save the dilmiter
saveDelimiter:
		    	
      		li $v0, 11	# print | as dict formate (1)  
		li $a0, 0x7C  	# load the ASCII code for comma into $a0
		syscall       	# execute the system call to print a comma character
		
# print to file 		
		li $v0, 15     # system call for writing to a file
		move $a0, $s4  # move the file descriptor to $a0
		la $a1, value  # load the address of the buffer into $a1
		li $a2, 1      # number of bytes to write (12 for a single integer)
		syscall        # execute the system call
		
		
 
		li $v0, 11
  		li $a0, '\n'  # newline character
		syscall 
		
# print to file		
		li $v0, 15     # system call for writing to a file
		move $a0, $s4  # move the file descriptor to $a0
		la $a1, space  # load the address of the buffer into $a1
		li $a2, 1      # number of bytes to write (12 for a single integer)
		syscall        # execute the system call
		
############################            << start of compresion >>        ####################################################
		
		# Saving register values on the stack
    		addi $sp, $sp, -16  	# Adjust stack pointer by 12 bytes
    		sw $t0, 0($sp)      	# Save the value of $t0 on the stack
    		sw $t1, 4($sp)      	# Save the value of $t1 on the stack
    		sw $a1, 8($sp)      	# Save the value of $t2 on the stack
    		sw $t5, 12($sp)     	# Save the value of $t5 on the stack
		
		# here print the compress value
		jal int2str2file  
		
		# Restoring register values from the stack
		lw $t5, 12($sp)     # Restore the value of $t5 from the stack
    		lw $t2, 8($sp)      # Restore the value of $t2 from the stack
    		lw $t1, 4($sp)      # Restore the value of $t1 from the stack
    		lw $t0, 0($sp)      # Restore the value of $t0 from the stack   		
    		addi $t5, $t5, 1 

    		addi $sp, $sp, 16   # Adjust stack pointer back by 12 bytes
    		
############################         << end of compresion >>       ##############################################################
	 		
		# save the dilimeter 				
                sb $t1, 0($s2) 		# store the value of the current charater in an address
		move $a0, $s2 		# load the address of the string into $a0
		li $v0, 4     		# load system call code for printing a string into $v0
    		syscall
    		
    		# print to file
		li $v0, 15     		# system call for writing to a file
		move $a0, $s4  		# move the file descriptor to $a0
		move $a1, $s2 		# load the address of the string into $a0
		li $a2, 1      		# number of bytes to write (12 for a single integer)
		syscall        		# execute the system call
		
############################           << start of compresion >>         ##############################################################		
		
		# Saving register values on the stack
    		addi $sp, $sp, -16   	# Adjust stack pointer by 12 bytes
    		sw $t0, 0($sp)      	# Save the value of $t0 on the stack
    		sw $t1, 4($sp)      	# Save the value of $t1 on the stack
    		sw $a1, 8($sp)      	# Save the value of $t2 on the stack
    		sw $t5, 12($sp)     	# Save the value of $t5 on the stack
		
		# here print the compress value
		jal int2str2file  
		
		# Restoring register values from the stack
		lw $t5, 12($sp)     	# Restore the value of $t5 from the stack
    		lw $t2, 8($sp)      	# Restore the value of $t2 from the stack
    		lw $t1, 4($sp)      	# Restore the value of $t1 from the stack
    		lw $t0, 0($sp)      	# Restore the value of $t0 from the stack   		
    		addi $t5, $t5, 1 

    		addi $sp, $sp, 16   	# Adjust stack pointer back by 12 bytes
    		
############################              << end of compresion >>          ##############################################################
		
    		# print | as dict formate
		li $v0, 11
		li $a0, 0x7C  		# load the ASCII code for comma into $a0
		syscall       		# execute the system call to print a comma character		
# print to file		
		li $v0, 15     		# system call for writing to a file
		move $a0, $s4  		# move the file descriptor to $a0
		la $a1, value  		# load the address of the buffer into $a1
		li $a2, 1      		# number of bytes to write (12 for a single integer)
		syscall        		# execute the system call
    	  				
        	# print space 
		li $v0, 11
  		li $a0, '\n'  		# newline character
		syscall
		
# print to file			
		li $v0, 15     		# system call for writing to a file
		 move $a0, $s4  	# move the file descriptor to $a0
		la $a1, space  		# load the address of the buffer into $a1
		li $a2, 1      		# number of bytes to write (12 for a single integer)
		syscall        		# execute the system call
						
		li $v0, 16         	# close_file syscall code
    		move $a0,$s4      	# file descriptor to close
    		syscall
    		
    		
    		
goTonextWord: 		    		
    		
    		addi $a3, $a3, 1		# move to the next character in the sentence
    		la $s3, delimiters 		# reset the delimiter pointer to the beginning of the delimiters string
    		la $s1, word_buffer 		# reset the word pointer to the beginning of the buffer
		j loop 				# continue to next character 
		
check_duplication: 
	la $s6, hash_table 			# content of the file: He|0x0000\n!|0x0001\n00
	la $s1, word_buffer 			# contents:He
	move $t8, $zero
	move $t7, $zero 
    	loop_1:
    		lbu $t8, ($s6)   			# load the current byte into $t8
    		check_words: 
    			lbu $t7, ($s1)   		# load the current byte into $t7 
    			beq $t8, $t7, increment_both
    			beqz $t7,dothing 		# when there is duplication
    			bne  $t8, $t7, skiptoNextchar 	# when there is no duplication 
dothing: 
	beq $t8 , 0x7C , addtheconstThenNewDelimiter 	# addtheconstThenNewDelimiter # addNewDelimiter
	j skiptoNextchar				# increment the counter of the compression constant, then skip 
	
increment_both:
	addi $s1, $s1, 1 
	addi $s6, $s6, 1 	# increment the word pointer
	j loop_1
	
skiptoNextchar: 
	li $t9, 0x0A 		# new line. 
	
# loop over all the hash table
here: 
	addi $s6, $s6, 1 			# increment the word pointer
	lbu $t8, ($s6)
	beqz $t8, appendToDict    		#( if you reach the end of the file, that means new word) --> append the word
	bne $t8, $t9, here
	beq $t8, $t9, comprewithNextLine 	# go to the next line of the file to do the compare again 
comprewithNextLine:  
	addi $s6, $s6, 1 			# increment the word pointer
	la $s1, word_buffer 			# reset the word buffer 
	addi $s7, $s7, 1 			# count number of lines.
	j loop_1  

appendToDict: 
	move $s7, $zero 			# reset the counter 
# Open the file: 
	li $v0, 13     				# system call for opening a file for writing
	la $a0, fileOut 			# load the address of the filename into $a0
	li $a1, 9      				# flag for appending
	syscall        				# execute the system call
	move $s4, $v0  				# save the file descriptor in $s4 = for dictfile	
	
# Write the buffer to the file
	li $v0, 15     				# system call for writing to a file
	move $a0, $s4 				# move the file descriptor to $a0
	la $a1, word_buffer 			# load the address of the buffer into $a1
	move $a2, $t6          			# number of bytes to write (12 for a single integer)
	syscall        				# execute the system call
	li $t6, 0 				# reset the coutner of the buffer size 
	
# print to file (|) 	
	li $v0, 15     				# system call for writing to a file
	move $a0, $s4  				# move the file descriptor to $a0
	la $a1, value  				# load the address of the buffer into $a1
	li $a2, 1      				# number of bytes to write (12 for a single integer)
	syscall        				# execute the system call
	
	
#print to file ( space) 
	li $v0, 15     				# system call for writing to a file
	 move $a0, $s4  			# move the file descriptor to $a0
	la $a1, space  				# load the address of the buffer into $a1
	li $a2, 1      				# number of bytes to write (12 for a single integer)
	syscall        				# execute the system call
	
############################              << start of compresion >>               ##############################################		
		
		# Saving register values on the stack
    		addi $sp, $sp, -16   		# Adjust stack pointer by 12 bytes
    		sw $t0, 0($sp)      		# Save the value of $t0 on the stack
    		sw $t1, 4($sp)      		# Save the value of $t1 on the stack
    		sw $a1, 8($sp)      		# Save the value of $t2 on the stack
    		sw $t5, 12($sp)     		# Save the value of $t5 on the stack
		
		jal int2str2file  		# here print the compress value
		
		# Restoring register values from the stack
		lw $t5, 12($sp)     		# Restore the value of $t5 from the stack
    		lw $t2, 8($sp)      		# Restore the value of $t2 from the stack
    		lw $t1, 4($sp)      		# Restore the value of $t1 from the stack
    		lw $t0, 0($sp)      		# Restore the value of $t0 from the stack   		
    		addi $t5, $t5, 1 

    		addi $sp, $sp, 16   		# Adjust stack pointer back by 12 bytes
    		
############################                 << end of compresion >>         ##############################################################	
	
# close the file:	
	li $v0, 16         			# close_file syscall code
    	move $a0,$s4      			# file descriptor to close
    	syscall
    	j addNewDelimiter

addNewDelimiter: 	
	li $t6, 0 			# reset the coutner of the buffer size ( added this line of code, 17th,5,2023
	la $s6, hash_table 		# content of the file: He|0x0000\n!|0x0001\n00
   	loop_2:
    		lbu $t8, ($s6)   	# load the current byte into $t8
    			beqz $t8, appendnewDelimiter
    			bne  $t8, $t1, toNextchar 			# when no duplication 
    			beq $t8, $t1,  doCompressionforDelimiter 	# goTonextWord # when the is duplication 

toNextchar:
	li $t9, 0x0A 				# new line. 
	beq $t8, $t9, calculateLineNumber
backhere:
	addi $s6, $s6, 1 			# increment the word pointer
	j loop_2

calculateLineNumber:
		addi $s7, $s7, 1
		j backhere

doCompressionforDelimiter: 
############################              << start of compresion >>               ##############################################				
		
		# Saving register values on the stack
    		addi $sp, $sp, -12   	# Adjust stack pointer by 12 bytes
    		sw $t0, 0($sp)      	# Save the value of $t0 on the stack
    		sw $t1, 4($sp)      	# Save the value of $t1 on the stack
    		sw $a1, 8($sp)      	# Save the value of $a1 on the stack    		
 
		jal addConstToCompressFile
		
		# Restoring register values from the stack
    		lw $t2, 8($sp)      	# Restore the value of $t2 from the stack
    		lw $t1, 4($sp)      	# Restore the value of $t1 from the stack
    		lw $t0, 0($sp)      	# Restore the value of $t0 from the stack   		
   		
    		addi $sp, $sp, 12   	# Adjust stack pointer back by 12 bytes
    		
############################                 << end of compresion >>         ########################################################
		
		j goTonextWord			

appendnewDelimiter:

	li $s7, 0  		# reset the count of $s7 
	
# Open the file: 
	li $v0, 13     		# system call for opening a file for writing
	la $a0, fileOut 	# load the address of the filename into $a0
	li $a1, 9      		# flag for appending
	syscall        		# execute the system call
	move $s4, $v0  		# save the file descriptor in $s4 = for dictfile	
	
# Write the buffer to the file
	sb $t1, char_buffer
	li $v0, 15     		# system call for writing to a file
	move $a0, $s4  		# move the file descriptor to $a0
	la $a1, char_buffer 	# load the address of the buffer into $a1
	li $a2, 1      		# number of bytes to write (12 for a single integer)
	syscall        		# execute the system call
	
# print to file ( |)  
	li $v0, 15     		# system call for writing to a file
	move $a0, $s4  		# move the file descriptor to $a0
	la $a1, value  		# load the address of the buffer into $a1
	li $a2, 1      		# number of bytes to write (12 for a single integer)
	syscall        		# execute the system call
	 	
# print to file ( space) 
	li $v0, 15     		# system call for writing to a file
	 move $a0, $s4  	# move the file descriptor to $a0
	la $a1, space  		# load the address of the buffer into $a1
	li $a2, 1      		# number of bytes to write (12 for a single integer)
	syscall        		# execute the system call
	
############################              << start of compresion >>     ##############################################################		
		
		# Saving register values on the stack
    		addi $sp, $sp, -16   	# Adjust stack pointer by 12 bytes
    		sw $t0, 0($sp)      	# Save the value of $t0 on the stack
    		sw $t1, 4($sp)      	# Save the value of $t1 on the stack
    		sw $a1, 8($sp)      	# Save the value of $t2 on the stack
    		sw $t5, 12($sp)     	# Save the value of $t5 on the stack
		
		jal int2str2file  	# here print the compress value
		
		# Restoring register values from the stack
		lw $t5, 12($sp)     	# Restore the value of $t5 from the stack
    		lw $t2, 8($sp)      	# Restore the value of $t2 from the stack
    		lw $t1, 4($sp)      	# Restore the value of $t1 from the stack
    		lw $t0, 0($sp)      	# Restore the value of $t0 from the stack   		
    		addi $t5, $t5, 1 

    		addi $sp, $sp, 16   	# Adjust stack pointer back by 12 bytes
    		
############################             << end of compresion >>     ##############################################################		
			
	
# close the file:	
	li $v0, 16         		# close_file syscall code
    	move $a0,$s4      		# file descriptor to close
    	syscall
	j goTonextWord																																											

# open and write in the compresed file 
int2str2file:
	move $t8,$zero 
	move $a1, $zero
	move $v0, $zero
	move $t1, $zero
	la $a1, counter_buffer 		# i need something like this 
	li $t0, 10 			# the reg here should not missedup sth
	addiu $v0, $a1, 11 		# start at the end of buffer  
	sb $zero, 0($v0) 		# store a NULL character
	
L2: 	divu $t5, $t0 			# LO = value/10, HI = value%10
	mflo $t5 			# $a0 = value/10
	mfhi $t1 			# $t1 = value%10
	addiu $t1, $t1, 48 		# convert digit into ASCII
	addiu $v0, $v0, -1 		# point to previous byte
	sb $t1, 0($v0) 			# store character in memory
	bnez $t5, L2 			# loop if value is not 0
	
	move $t8, $v0  			# neeed a registerrrrrrr 
	la $a0, ($t8)   		# Load the address of the string into $a0
	li $v0, 4         		# Set $v0 to 4 for printing a string
    	syscall           		# Perform the syscall
	
# Wrtie to file
	li $v0, 15     			# system call for writing to a file
	move $a0, $s5 			# move the file descriptor to $a0
	la $a1, ($t8)  			# load the address of the buffer into $a1
	li $a2, 4      			# number of bytes to write
	syscall        			# execute the system call

	# count the number of lines
	addi $t4, $t4, 1
	 
# print to file 
	li $v0, 15     			# system call for writing to a file
	move $a0, $s5  			# move the file descriptor to $a0
	la $a1, space  			# load the address of the buffer into $a1
	li $a2, 1      			# number of bytes to write (12 for a single integer)
	syscall        			# execute the system call	
	move $t8, $zero 
	
	jr $ra
	
# the main of this function is to print the same number of the word when duplication occure. 		      			        			        			      			        			        		
addConstToCompressFile: 

	la $a1, counter_buffer 		# i need something like this 
	li $t0, 10 			# the reg here should not missedup sth
	addiu $v0, $a1, 11 		# start at end of buffer  
	sb $zero, 0($v0) 		# store a NULL character
	
L3: 	divu $s7, $t0 			# LO = value/10, HI = value%10
	mflo $s7 			# $a0 = value/10
	mfhi $t1 			# $t1 = value%10
	addiu $t1, $t1, 48 		# convert digit into ASCII
	addiu $v0, $v0, -1 		# point to previous byte
	sb $t1, 0($v0) 			# store character in memory
	bnez $s7, L3 			# loop if value is not 0
	
	move $t8, $v0  			# neeed a registerrrrrrr 
	
	la $a0, ($t8)   		# Load the address of the string into $a0
	li $v0, 4         		# Set $v0 to 4 for printing a string
    	syscall           		# Perform the syscall
	
# Wrtie to file
	move $s5, $v0  			# save the file descriptor in $s4 = for dictfile	
	li $v0, 15     			# system call for writing to a file
	move $a0, $s5  			# move the file descriptor to $a0
	la $a1, ($t8)  			# load the address of the buffer into $a1
	li $a2, 4     			# number of bytes to write
	syscall        			# execute the system call

	addi $t4, $t4, 1 		# count the number of lines in compress file 
	
# print to file 
	li $v0, 15     			# system call for writing to a file
	move $a0, $s5  			# move the file descriptor to $a0
	la $a1, space  			# load the address of the buffer into $a1
	li $a2, 1      			# number of bytes to write (12 for a single integer)
	syscall        			# execute the system call	
	move $t8, $zero 
	jr $ra
	
addtheconstThenNewDelimiter:
############################              << start of compresion >>     ##############################################################	
		
		# Saving register values on the stack
    		addi $sp, $sp, -12   		# Adjust stack pointer by 12 bytes
    		sw $t0, 0($sp)      		# Save the value of $t0 on the stack
    		sw $t1, 4($sp)      		# Save the value of $t1 on the stack
    		sw $a1, 8($sp)      		# Save the value of $t2 on the stack
    		    		
		jal addConstToCompressFile
		# Restoring register values from the stack
		
    		lw $t2, 8($sp)      		# Restore the value of $t2 from the stack
    		lw $t1, 4($sp)      		# Restore the value of $t1 from the stack
    		lw $t0, 0($sp)      		# Restore the value of $t0 from the stack   		
   		
    		addi $sp, $sp, 12   		# Adjust stack pointer back by 12 bytes
		j addNewDelimiter

############################              << end of compresion >>     ##############################################################
# -------------------------------------------------------------------------------------------------------------------------------#

##################################################################################################################################
## ****************************************       START DECOMPRESSION      ************************************************** ## 		
##################################################################################################################################

decompression: 

	 
	jal ans_is_yes			# Ask the user to enter the path:
	jal resetRegisters 		# Call lable resetRegisters					
	li $t0, 0 			# counter number of lines in oput.txt.
			  
# Open the file (dictionry file): 
	li $v0, 13     			# system call for opening a file for writing
	la $a0, fileOut 		# load the address of the filename into $a0
	li $a1, 0      			# flag for reading
	syscall        			# execute the system call
	move $s4, $v0  			# save the file descriptor in $s4 = for dictfile	
#read the file
	li $v0, 14			# read_file syscall code = 14
	move $a0,$s4			# file descriptor
	la $a1,hash_table  		# The buffer that holds the string of the WHOLE file
	li $a2,1024			# hardcoded buffer length
	syscall 
#Close the file
    	li $v0, 16         		# close_file syscall code
    	move $a0,$s4      		# file descriptor to close
    	syscall
    	  	
  	
# Open the file compressed file: 
	li $v0, 13     			# system call for opening a file for writing
	la $a0, file_path 		# load the address of the filename into $a0
	li $a1, 0      			# flag for reading
	syscall        			# execute the system call
	move $s5, $v0  			# save the file descriptor in $s4 = for dictfile	
	
#read the file
	li $v0, 14			# read_file syscall code = 14
	move $a0,$s5			# file descriptor
	la $a1, compress_buffer		# The buffer that holds the string of the WHOLE file
	li $a2, 512			# hardcoded buffer length
	syscall 
	
#Close the file
    	li $v0, 16         		# close_file syscall code
    	move $a0,$s5     		# file descriptor to close
    	syscall  
    	  	   	
# Open the file Decompressed file: 
	li $v0, 13     			# system call for opening a file for writing
	la $a0, fileDecompressed 	# load the address of the filename into $a0
	li $a1, 1      			# flag for writting
	syscall        			# execute the system call
	move $s7, $v0  			# save the file descriptor in $s4 = for dictfile	   	
    	 	   	    	
countNumberofLines: 
	la $s6, hash_table 		# content of the file: He|0x0000\n!|0x0001\n00	
	LP1: 
	    lbu $t8, ($s6)   		# load the current byte into $t8
	    beqz $t8, printNumberofLines
	    beq  $t8, 0x0A, incrementCounter
	    addi $s6, $s6, 1 
	    j LP1	 	
incrementCounter: 
	addi $t0, $t0, 1
	addi $s6, $s6, 1 
	j LP1
			
printNumberofLines:  
	subi $t0, $t0, 1 	# print intger:
	move $a0, $t0
	li $v0, 1 
	syscall 
	
	li $v0, 11		# print space 
  	li $a0, '\n'  		# newline character
	syscall

# change the name of it, to decompression operation.		
printThevalueOfCompress: 
	lb $t6, value 
	la $t7, compress_buffer 
	la $t5,newInt 			# to print the value in integer
	sb, $t6, 500($t7) 		# appened | dilmiter to the end of the file, to do the termination
	LP2:
		lbu $t9, ($t7)   	# load the current byte into $t8	
		beq $t9, $t6, QuitProgram	
		beq $t9,0x20 , jumphere
		beqz $t9 jumphere
		j dosomemagic		# convert from string to intger 		 				
jumphere:		
		addi $t7, $t7, 1
		j LP2 
	
dosomemagic:
	beq $t9,0x0A , printVlaue	# when it reaches the new line, it's the end of the world
	sb $t9,($t5)			# store the number in $t5 
	addi $t5, $t5, 1 
	j jumphere
			
printVlaue:
	jal str2int 
	move $t2, $v0 
	move $a0, $t2 			# print intger:
	li $v0, 1
	syscall	
	
# check for error message 
	bgt $t2, $t0, ErrorMessage
		 
	li $v0, 11			# print space
  	li $a0, '\n'  			# newline character
	syscall
	
# start the decompression part: 
	beqz $t2, startwrittingToDfile  # start writting to decomprsed file 
	j  contiueWrittingTOfile	# continue writting to  decomprsed file 

		
#to read the new value of the compressed file 
backHere: 

    	sw $zero, newInt	# clear the content at the address      
    	la $t5,newInt 		# reload the pointer to save the next char  
	j jumphere		#go back to get the next char
	
	
startwrittingToDfile:
	la $a3, hash_table
	la $t4, recovered_str
	li $t8, 0 
	
	LP3:
		lb  $t3, ($a3)
		beq $t3 , 0x7C, writeTofile 
		sb  $t3, ($t4) 
		addi $a3, $a3, 1 
		addi $t4, $t4, 1
		addi $t8, $t8, 1
	j LP3 

# Write the buffer to the file	
writeTofile: 
		
	li $v0, 15     			# system call for writing to a file
	move $a0, $s7  			# move the file descriptor to $a0
	la $a1, recovered_str  		# load the address of the buffer into $a1
	move $a2, $t8     		# number of bytes to write (12 for a single integer)
	syscall        			# execute the system call
           
    	sw $zero, recovered_str  	# clear the content at the address      
	j backHere
		

contiueWrittingTOfile: 
	la $a3, hash_table
	la $t4, recovered_str
	li $t8, 0 
	LP4:
		lb  $t3, ($a3)
		beq $t3 , 0x0A, trackTheWord
		addi $a3, $a3, 1 		
	j LP4 
	
trackTheWord: 
	subiu $t2, $t2, 1 
	beqz $t2, foundTheWord
	addi $a3, $a3, 1
	j LP4
	
foundTheWord:
		addi $a3, $a3, 1
startHere: 
		lb  $t3, ($a3)
		beq $t3 , 0x7C, cwriteTofile
		sb  $t3, ($t4) 		# save the current value to the buffer
		addi $a3, $a3, 1 
		addi $t4, $t4, 1
		addi $t8, $t8, 1
		
		j startHere

# Write the buffer to the file				
cwriteTofile: 
		
	li $v0, 15     			# system call for writing to a file
	move $a0, $s7  			# move the file descriptor to $a0
	la $a1, recovered_str  		# load the address of the buffer into $a1
	move $a2, $t8     		# number of bytes to write (12 for a single integer)
	syscall        			# execute the system call     
    	sw $zero, recovered_str   	# clear the content at the address
    	j backHere
		
				
str2int:
	li $v0, 0 				# Initialize: $v0 = sum = 0
	li $t3, 10 				# Initialize: $t0 = 10
	la $t5,newInt 
	L1: 
		lb $t1, 0($t5)			# load $t1 = str[i]
		beqz $t1, done
		blt $t1, '0', done 		# exit loop if ($t1 < '0') 
		bgt $t1, '9', done 		# exit loop if ($t1 > '9')
		addiu $t1, $t1, -48 		# Convert character to digit
		mul $v0, $v0, $t3 		# $v0 = sum * 10
		addu $v0, $v0, $t1 		# $v0 = sum * 10 + digit
		addiu $t5, $t5, 1 		# $a0 = address of next char
		j L1 				# loop back
	done: 
	
	jr $ra 					# return to caller	
	
ErrorMessage:
 	la $a0, error_msg   			# load the address of the error option to $a0 reg
        li $v0,4	       			# $v0 -> 4 to print string
        syscall
	j QuitProgram			
						
# reset the processer registers 
resetRegisters:
    move $t0, $zero
    move $t1, $zero
    move $t2, $zero
    move $t3, $zero
    move $t4, $zero
    move $t5, $zero
    move $t6, $zero
    move $t7, $zero
    move $t8, $zero
    move $t9, $zero
    move $s0, $zero
    move $s1, $zero
    move $s2, $zero
    move $s3, $zero
    move $s4, $zero
    move $s5, $zero
    move $s6, $zero
    move $s7, $zero
    move $v0, $zero
    move $v1, $zero
    move $a0, $zero
    move $a1, $zero
    move $a2, $zero
    move $a3, $zero   
    jr $ra
    
# print the ratio of the compressed and uncompressed files        
printRatioandQuit:

	jal calculateTheRation	
	j QuitProgram 
	               
calculateTheRation: 

        la $a0, uncompressed_file_size  	# print the uncompressed file size
        li $v0,4	      
        syscall
        
# calculate the size  of uncompressed file        
        mul $t3, $t3, 16  
        move $a0, $t3
        li $v0, 1
        syscall 
        
        la $a0, compressed_file_size  		# print the compressed file size
        li $v0,4	      
        syscall       
# calculate the size  of compressed file         
        mul $t4, $t4, 16
        move $a0, $t4
        li $v0, 1
        syscall 

# calculate the ration: 
# 1) int to float    
    mtc1 $t3, $f0
    cvt.d.w $f0, $f0 # 2560.0
   
# 2) int to float     
     mtc1 $t4, $f2
     cvt.d.w $f2, $f2 # 784.0
     
# 3) print the message 
     la $a0, files_Ratio  	# print the compressed file size
     li $v0,4	      
     syscall  
# 4) calcualte the ration   
     div.d $f4, $f0, $f2     	# Divide dividend by divisor and store the result in $f4

# 5) print the ration     
     mov.d $f12, $f4         	# Move the quotient value to $f12
     li $v0, 3               	# System call code for printing a double (floating-point number)
     syscall                 	# Print the quotient 
    
     # when finsh quit                          
     jr $ra 
        	    
    		
QuitProgram: 	

 	# close the Decompressed file
	li $v0, 16         		# close_file syscall code
    	move $a0,$s7     		# file descriptor to close
    	syscall  			 	 	
    			
	#Close the input file
    	li $v0, 16         		# close_file syscall code
    	move $a0,$s0      		# file descriptor to close
    	syscall
    	
    	# close the compresed file	
	li $v0, 16         		# close_file syscall code
    	move $a0,$s5      		# file descriptor to close
    	syscall	
    	j Copress_Or_Decompress

exitTheProgram: 
  	   	    	 		   	   	    	 		   	   	    	 		   	   	    	 		
	li $v0, 10 			# Finish the Program
	syscall
 	
.data
	fileWords: .space 1024 			# the string that contains the value of the file
	hash_table: .space 1024 		# array for words
	fileName: .asciiz "input.txt"  		# original.txt, input.txt
	fileOut: .asciiz "dictionary.txt"
	fileCompres: .asciiz "comp.txt"
	fileDecompressed: .asciiz "decomp.txt"
	delimiters: .asciiz " !.?," 
	error_msg: .asciiz "\n//Error// Unvalid code, error in decompression //"
	uncompressed_file_size : .asciiz "\n The uncompressed file size = "
	compressed_file_size: .asciiz "\n The compressed file size = "
	files_Ratio: .asciiz "\n File Compression Ratio = "
	value: .word 0x7C    			# the value | to be written to file
	space: .word 0x0A    			# newline value to be written to file

.align 2

     word_buffer: .space 256 			# array for words ( save the words) 
     spcialchar_buffer: .space 128   		# array for special chars.
     char_buffer: .space 1 			# to save the char and print into the outfile
     compress_buffer: .space 512 		# to save the compressed data 
     counter_buffer:  .space 12 		# to save the number in compressed file
     
.align 4
	dict_existion: .asciiz "\n Does the dictionary.txt file is exist(yes) or not (no):"
	error_option: .asciiz "\n Invalid Option.Please try again."
	file_path_sentence: .asciiz "\n Please Enter file path:"
	compress_decompress: .asciiz "\n Choose (c) for compression or (d) decompression and (q) for Quit:"
	error_file_path: .asciiz "\n Invalid file path."
	dict_answer: .space 256   		# Buffer to store the answer if the dict file is exist or not
	file_path: .space 256    		# buffer to save the entered path value from the user
	yes_answer: .asciiz "yes"  
	no_answer:  .asciiz "no"
	newline: .asciiz "\n"
	dict_word_buffer: .space 256 		# array for words
	create_dict_file: .asciiz "dictionary.txt"
	
.align  16
 	 newInt:  .space 128 		
 	 recovered_str : .space 20 		# to save the recovered string from the dictionary  
