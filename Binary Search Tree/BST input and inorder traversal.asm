.data
p2: .asciiz "Enter a number: "
space: .asciiz " "
ht: .asciiz "\nHeight: "
nl: .asciiz "\n"

.text
main:
li $s0, 0	#$s0 always points to the root node of binary tree, initiallyNULL

get_input: 	#infinite loop for getting number to be inserted in tree, 0 terminates the loop
la $a0, p2
li $v0, 4
syscall

li $v0, 5
syscall
beq $v0, $zero, break_of_loop

move $a0, $v0	#$a0 = number to be inserted
move $a1, $s0 	#$a1 = ptr to the root (holds address of root node), initiallyNULL
jal insert_in_tree
move $s0, $v0 	#v0 adress to the root, storing it in$s0
j get_input

break_of_loop:	#exit from loop above for entry value as0
move $a0, $s0
move $t7, $s0
move $a1, $zero
jal inorder_traversal 	#inorder traversal, $a0 is argument, holds address of theroot
move $a0, $t7
move $a1, $zero
jal findht

la $a0, ht
li $v0, 4
syscall

move $a0, $a1
li $v0, 1
syscall

li $v0, 10 	#exit from main
syscall

insert_in_tree:
bne $a1, $zero, not_base_case 	#check for base case if(pointer == NULL),#then dynamically allocate memory for the newnode)
move $t0, $a0 	# for base case, you can avoid stack pointer anduse#temporary registers for restoringpurposes#In next few lines, do dynamic memory allocation, $a0 = size(in bytes), $v0 = pointer to the  new memory,  insert  the  input  value  into  the  created  structure,  and  set  left  and  right child pointers as NULL ($zero), restore value of $a0,then return.

li $a0, 12
li $v0, 9
syscall

sw $t0, ($v0)
sw $zero, 4($v0)
sw $zero, 8($v0)
jr $ra 		#return only for base case –not forrest

not_base_case: 	#Taking hint from returnNonBase label, store the required values in stack

addi $sp, $sp, -12 #create a stack frame
sw $ra,0($sp)
sw $a1,4($sp) #ptr to root
sw $s0,8($sp) 

lw $t7, ($a1)
ble $t7, $a0, right

#compare number in current node with the number to be inserted, accordingly traverse left or right
left:
addi $a1, $a1, 4			 	#left node pointer at 4($a1) : after this it’s at 0($a1)
move $s0, $a1
lw $a1, ($a1)				 	# now we have the pointer value –may be null
jal insert_in_tree 				#return value of this function is in $v0, which holds the address of the newly created child (left or right acc. to value of $s0)
j returnNonBase

right:		#traverse right, changevalue of $a1 accordingly
addi $a1, $a1, 8
move $s0, $a1
lw $a1, ($a1)
jal insert_in_tree
j returnNonBase

returnNonBase:
sw $v0,($s0) 	#NOTE –null value is being updated with the address returned
lw $ra, ($sp)
lw $a1, 4($sp)
lw $s0, 8($sp)
addi $sp, $sp, 12
move $v0, $a1	#NOTE 
jr $ra

inorder_traversal: 	#a0 is argument, holds address of the root initially
beq $a0, $zero, return_inorder

addi $sp, $sp, -8
sw $ra, ($sp)
sw $a0, 4($sp)

#traverse left, then print the middle element, then traverse right#restore the register values
addi $a0, $a0, 4
lw $a0, ($a0)
jal inorder_traversal

lw $a0, 4($sp)
lw $a0, ($a0)
li $v0, 1
syscall

la $a0, space
li $v0, 4
syscall

lw $a0, 4($sp)
addi $a0, $a0, 8
lw $a0, ($a0)
jal inorder_traversal

#restore
lw $a0, 4($sp)
lw $ra,($sp)
addi $sp, $sp, 8

return_inorder:
jr $ra

findht:
beq $a0, $zero, ret0

addi $sp, $sp, -12
sw $a0, ($sp)
sw $ra, 4($sp)
sw $a1, 8($sp)


lw $t5, ($a0)
la $a0, nl
li $v0, 4
syscall
move $a0, $t5
li $v0, 1
syscall
la $a0, space
li $v0, 4
syscall
lw $a0, ($sp)
addi $a0, $a0, 4
lw $a0, ($a0)
jal findht

sw $a1, 8($sp)

la $a0, nl
li $v0, 4
syscall
move $a0, $t5
li $v0, 1
syscall
la $a0, space
li $v0, 4
syscall
move $a0, $a1
li $v0, 1
syscall
la $a0, space
li $v0, 4
syscall
addi $a0, $zero, 1
li $v0, 1
syscall

lw $a0, ($sp)
lw $t5, ($a0)
addi $a0, $a0, 8
lw $a0, ($a0)
jal findht

move $a2, $a1

la $a0, nl
li $v0, 4
syscall
move $a0, $t5
li $v0, 1
syscall
la $a0, space
li $v0, 4
syscall
move $a0, $a2
li $v0, 1
syscall
la $a0, space
li $v0, 4
syscall
addi $a0, $zero, 2
li $v0, 1
syscall

lw $a1, 8($sp)

ble $a2, $a1, sk
move $a1, $a2
sk:
addi $a1, $a1, 1

lw $a0, ($sp)
lw $ra, 4($sp)
addi $sp, $sp, 12

ret0:
jr $ra