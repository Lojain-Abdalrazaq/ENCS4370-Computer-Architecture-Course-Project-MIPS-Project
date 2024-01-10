# Title: Starting with MIPS, running examples
# Author: Lojain Abdalrazaq
# Description:
# Input:
# Outpout:

######################################### Data Segment ######################################### 
.data

######################################### Code Segment ######################################### 
.text
.globl main
main:					# the main program starts from here
li $v0, 5				# loading the 5 value in v0 --> reading integer form the promt
syscall

move $a0,$v0				# loading the value saved in the 
li   $v0, 1
syscall

li $v0, 10 				# 10 --> quit or exit the program 
syscall					# the equivelant of the calling the fucntion


