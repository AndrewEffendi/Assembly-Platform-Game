# Bitmap display starter code 
# 
# Bitmap Display Configuration: 
# - Unit width in pixels: 8           
# - Unit height in pixels: 8 
# - Display width in pixels: 256 
# - Display height in pixels: 256 
# - Base Address for Display: 0x10008000 ($gp) 
# 
.eqv  BASE_ADDRESS  0x10008000 
 
.text 
	li $t0, BASE_ADDRESS # $t0 stores the base address for display 
 	
 	li $s0, 100 # health
 	li $s1, 0 # player's x-coordinate
 	li $s2, 108 # player's y-coordinate
 	
 	li $s3, 0 # platform 1
 	li $s3, 0 # platform 2
 	li $s4, 0 # platform 3
 	
 	li $s5, 0 # spike 1
 	li $s6, 0 # spike 2
 	li $s7, 0 # enemy
 	
 	 j paint_ground 
ground_painted: 
	j paint_spike
spike_painted:	 
	j paint_player
platform_painted:
 
 wait:
 	li $t9, 0xffff0000  
	lw $t8, 0($t9) 
	beq $t8, 1, keypress_happened 
	j wait

keypress_happened :	
	lw $t8, 4($t9) # this assumes $t9 is set to 0xfff0000 from before 
	beq $t8, 0x77, respond_to_w   # ASCII code of 'w' is 0x77 
	beq $t8, 0x61, respond_to_a   # ASCII code of 'a' is 0x61
	beq $t8, 0x73, respond_to_s   # ASCII code of 's' is 0x73 
	beq $t8, 0x64, respond_to_d   # ASCII code of 'd' is 0x64
	j wait

respond_to_w:
	blez $s2, wait
	j remove_player
w_add:	addi $s2, $s2, -4 # y-1
	j paint_player
	
respond_to_a:
	blez $s1, wait
	j remove_player
a_add:	addi $s1, $s1, -4 # x-4
	j paint_player
	
respond_to_s:
	bge $s2, 108, wait
	j remove_player
s_add:	addi $s2, $s2, 4 # y+1
	j paint_player

respond_to_d:
	bge $s1, 120, wait
	j remove_player
d_add: 	addi $s1, $s1, 4 # x+4
	j paint_player
	
remove_player:
	li $t7, 32 #t7 = 64
	mul $t7, $t7, $s2 #t7 = 256/64*y = 64*y
	add $t7, $s1, $t7 #t7 = x + 64*y
	add $t7, $t7, $t0
	li $t6, 0x000000
	sw $t6, ($t7)
	sw $t6, 4($t7)
	sw $t6, 8($t7)
	sw $t6, 128($t7)
	sw $t6, 132($t7)
	sw $t6, 256($t7)
	sw $t6, 260($t7)
	sw $t6, 384($t7)
	sw $t6, 388($t7)
	beq $t8, 0x77, w_add   # ASCII code of 'w' is 0x77 
	beq $t8, 0x61, a_add   # ASCII code of 'a' is 0x61
	beq $t8, 0x73, s_add   # ASCII code of 's' is 0x73 
	beq $t8, 0x64, d_add   # ASCII code of 'd' is 0x64

paint_player:
	li $t7, 32 #t7 = 64
	mul $t7, $t7, $s2 #t7 = 256/64*y = 64*y
	add $t7, $s1, $t7 #t7 = x + 64*y
	add $t7, $t7, $t0
	li $t6, 0x0000ff
	sw $t6, ($t7)
	sw $t6, 4($t7)
	li $t6, 0xff0000
	sw $t6, 384($t7)
	sw $t6, 388($t7)
	sw $t6, 256($t7)
	sw $t6, 260($t7)
	li $t6, 0xf1C27D
	sw $t6, 128($t7)
	sw $t6, 132($t7)
	j wait

paint_platform:
	li $t6, 0xA64320
    	li $t7, 0 # init t7 = spike
loop_platform:
	bge $t7, 5, platform_painted
	li $t5, 4
	mul $t5, $t5, $t7
	add $t5, $t0 $t5
	addi $t5, $t5, 3968
	sw $t6, ($t5)
    	addi $t7, $t7, 1
    	j loop_platform
	
paint_ground:
	li $t6, 0x00ff00
    	li $t7, 0
loop_ground:
	bge $t7, 32, ground_painted
	li $t5, 4
	mul $t5, $t5, $t7
	add $t5, $t0 $t5
	addi $t5, $t5, 3968
	sw $t6, ($t5)
    	addi $t7, $t7, 1
    	j loop_ground
    	
    	
    	
paint_spike:
	li $t6, 0xaaa9ad
	addi $t5, $t0, 272
	sw $t6, 4($t5)
	sw $t6, 128($t5)
	sw $t6, 132($t5)
	j spike_painted
	
Exit:
 
 	li $v0, 10 # terminate the program gracefully 
 	syscall 