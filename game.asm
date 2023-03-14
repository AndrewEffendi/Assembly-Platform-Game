# Bitmap display starter code 
# 
# Bitmap Display Configuration: 
# - Unit width in pixels: 8           
# - Unit height in pixels: 8 
# - Display width in pixels: 512 
# - Display height in pixels: 512 
# - Base Address for Display: 0x10008000 ($gp) 
# 
.eqv  	BASE_ADDRESS	0x10008000 
.eqv	COLOR_SPIKE	0xaaa9ad
.eqv	COLOR_MONSTER	0xa64320
.eqv	COLOR_RED	0xff0000
.eqv	COLOR_BLUE	0x0000ff
.eqv	COLOR_GROUND	0x4cbb17
.eqv	COLOR_PLATFORM	0x4cbb17
.eqv	COLOR_FINISH	0xf5da0f

.eqv	MONSTER_2_1	364
.eqv	MONSTER_2_2	400
.eqv	MONSTER_3_1	500
.eqv	MONSTER_3_2	500
.eqv	MONSTER_3_3	500
.eqv	SPIKE_1_1	272
.eqv	SPIKE_1_2	300
.eqv	SPIKE_1_3	700
.eqv	SPIKE_2_1	272
.eqv	SPIKE_2_2	300
.eqv	SPIKE_3_1	300
.eqv	SPIKE_3_2	300
.eqv	PLATFORM_1_1	600
.eqv	PLATFORM_1_2	600
.eqv	PLATFORM_2_1	700
.eqv	PLATFORM_2_2	700
.eqv	PLATFORM_3_1	900
.eqv	PLATFORM_3_2	900
.eqv	PLATFORM_3_3	600
.eqv	GROUND		3968
.eqv	FINISH_1	4000
.eqv	FINISH_2	4020
.eqv	FINISH_3	4040

 
.text 
	li $t0, BASE_ADDRESS # $t0 stores the base address for display 
 	
reset:	li $s0, 100 # health
	li $s7, 1 # level

next_level:
 	li $s1, 0 # player's x-coordinate
 	li $s2, 108 # player's y-coordinate

 	li $s4, 0 # enemy 1
 	li $s5, 0 # enemy 2
 	li $s6, 0 # spike 3

# ground function
ground:	la $a1, COLOR_GROUND
	la $a0, GROUND
 	j paint_ground
paint_ground:
	# $a0: position
	# $a1: colour
	add $a0, $t0, $a0 # a0 = base + coordinate
    	li $t7, 0
loop_ground:
	bge $t7, 32, spike
	li $t5, 4 	  # 4 bytes
	mul $t5, $t5, $t7 # offset = 4 bytes * index
	add $t5, $t5, $a0 # t5 = address + offset
	sw $a1, ($t5)
    	addi $t7, $t7, 1
    	j loop_ground
 
# spike function
spike:	la $a1, COLOR_SPIKE
	beq $s7, 2, spike_lvl_2
	beq $s7, 3, spike_lvl_3
spike_lvl_1:
	la $a0, SPIKE_1_1
	j paint_spike
	la $a0, SPIKE_1_2
	j paint_spike
	la $a0, SPIKE_1_3
	j paint_spike
spike_lvl_2:
	la $a0, SPIKE_2_1
	j paint_spike
	la $a0, SPIKE_2_2
	j paint_spike
spike_lvl_3:
	la $a0, SPIKE_3_1
	j paint_spike
	la $a0, SPIKE_3_2
	j paint_spike
paint_spike:
	# $a0: position
	# $a1: colour
	add $a0, $t0, $a0 # a0 = base + coordinate
	sw $a1, 4($a0)
	sw $a1, 128($a0)
	sw $a1, 132($a0)
	j platform
	
# platform function
platform: 
	la $a1, COLOR_PLATFORM
	beq $s7, 2, platform_lvl_2
	beq $s7, 3, platform_lvl_3
platform_lvl_1:
	la $a0, PLATFORM_1_1
	j paint_platform
	la $a0, PLATFORM_1_2
	j paint_platform
platform_lvl_2:
	la $a0, PLATFORM_2_1
	j paint_platform
	la $a0, PLATFORM_2_2
	j paint_platform
platform_lvl_3:
	la $a0, PLATFORM_3_1
	j paint_platform
	la $a0, PLATFORM_3_2
	j paint_platform
paint_platform:
	# $a0: position
	# $a1: colour
	add $a0, $t0, $a0 # a0 = base + coordinate
    	li $t7, 0 # init t7 = 0
loop_platform:
	bge $t7, 9, monster
	li $t5, 4 	  # 4 bytes
	mul $t5, $t5, $t7 # offset = 4 bytes * index
	add $t5, $t5, $a0 # t5 = address + offset
	sw $a1, ($t5)
    	addi $t7, $t7, 1
    	j loop_platform

# monster function
monster:la $a1, COLOR_MONSTER
	beq $s7, 2, monster_lvl_2
	beq $s7, 3, monster_lvl_3
monster_lvl_1:
	j finish # no monster for level 1
monster_lvl_2:
	la $a0, MONSTER_2_1
	j paint_monster
	la $a0, MONSTER_2_2
	j paint_monster
monster_lvl_3:
	la $a0, MONSTER_3_1
	j paint_monster
	la $a0, MONSTER_3_2
	j paint_monster
	la $a0, MONSTER_3_3
	j paint_monster
paint_monster:
	# $a0: position
	# $a1: colour
	add $a0, $t0, $a0 # a0 = base + coordinate
	sw $a1, ($a0)
	sw $a1, 4($a0)
	sw $a1, 128($a0)
	sw $a1, 132($a0)
	j finish

# finish line function
finish:	la $a1, COLOR_FINISH
	beq $s7, 2, finish_lvl_2
	beq $s7, 3, finish_lvl_3
finish_lvl_1:
	la $a0, FINISH_1
	j paint_finish
finish_lvl_2:
	la $a0, FINISH_2
	j paint_finish
finish_lvl_3:
	la $a0, FINISH_3
	j paint_finish
paint_finish:
	# $a0: position
	# $a1: colour
	add $a0, $t0, $a0 # a0 = base + coordinate
	sw $a1, ($a0)
	sw $a1, 4($a0)
	j player
	
# player function	
player:
	j paint_player
 
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
	beq $t8, 0x31, respond_to_1   # ASCII code of '31' is 0x64
	beq $t8, 0x32, respond_to_2   # ASCII code of '32' is 0x64
	beq $t8, 0x33, respond_to_3   # ASCII code of '33' is 0x64
	j wait

respond_to_w:
	blez $s2, wait
	j remove_player
jump:	addi $s2, $s2, -4 # y-1
	j paint_player
	
respond_to_a:
	blez $s1, wait
	j remove_player
left:	addi $s1, $s1, -4 # x-4
	j paint_player
	
respond_to_s:
	bge $s2, 108, wait
	j remove_player
gravity:	
	addi $s2, $s2, 4 # y+1
	j paint_player

respond_to_d:
	bge $s1, 120, wait
	j remove_player
right: 	addi $s1, $s1, 4 # x+4
	j paint_player
	
respond_to_1:
	li $s7, 1
	j remove_player
respond_to_2:
	li $s7, 2
	j remove_player
respond_to_3:
	li $s7, 3
	j remove_player

remove_player:
	li $t7, 32 	  #t7 = 32
	mul $t7, $t7, $s2 #t7 = 32*y
	add $t7, $s1, $t7 #t7 = x + 32*y
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
	beq $t8, 0x77, jump   	# ASCII code of 'w' is 0x77 
	beq $t8, 0x61, left   	# ASCII code of 'a' is 0x61
	beq $t8, 0x73, gravity  # ASCII code of 's' is 0x73 
	beq $t8, 0x64, right   	# ASCII code of 'd' is 0x64
	beq $t8, 0x31, next_level   # ASCII code of '31' is 0x64
	beq $t8, 0x32, next_level   # ASCII code of '32' is 0x64
	beq $t8, 0x33, next_level   # ASCII code of '33' is 0x64

paint_player:
	li $t7, 32 	  #t7 = 64
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
	
Exit:
 	li $v0, 10 # terminate the program gracefully 
 	syscall 
