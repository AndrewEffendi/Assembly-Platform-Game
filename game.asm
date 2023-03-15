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
.eqv	COLOR_BLACK	0x000000
.eqv	COLOR_CREAM	0xf1C27D
.eqv	COLOR_GROUND	0x4cbb17
.eqv	COLOR_PLATFORM	0x4cbb17
.eqv	COLOR_FINISH	0xf5da0f
.eqv	COLOR_HEALTH	0xff0000

.eqv	MONSTER_2_1	14108
.eqv	MONSTER_2_2	12592
.eqv	MONSTER_3_1	14108
.eqv	MONSTER_3_2	12612
.eqv	MONSTER_3_3	9920

.eqv	SPIKE_1_1	14188
.eqv	SPIKE_1_2	14204
.eqv	SPIKE_1_3	14220
.eqv	SPIKE_2_1	11176
.eqv	SPIKE_2_2	300
.eqv	SPIKE_3_1	7964
.eqv	SPIKE_3_2	8060

.eqv	PLATFORM_1_1	14128
.eqv	PLATFORM_1_2	13212
.eqv	PLATFORM_2_1	13872
.eqv	PLATFORM_2_2	12432
.eqv	PLATFORM_3_1	13892
.eqv	PLATFORM_3_2	12452
.eqv	PLATFORM_3_3	11200
.eqv	PLATFORM_3_4	9320
.eqv	PLATFORM_3_5	9220

.eqv	GROUND		15360
.eqv	FINISH_1	15592
.eqv	FINISH_2	12432
.eqv	FINISH_3	9220

.eqv	HEALTH_1	520
.eqv	HEALTH_2	548
.eqv	HEALTH_3	576
 
.text 
	li $t0, BASE_ADDRESS # $t0 stores the base address for display 
 	
reset:	li $s0, 5 # health
	li $s7, 2 # level

next_level:
	
 	li $s1, 0 # player's x-coordinate
 	li $s2, 212 # player's y-coordinate
 	
 	li $s3, 1 # double jump

 	li $s4, 0 # enemy 1
 	li $s5, 0 # enemy 2
 	li $s6, 0 # enemy 3

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
	bge $t7, 256, spike
	li $t5, 4	  # 4 bytes
	mul $t5, $t5, $t7 # offset = 4 bytes * index
	add $t5, $t5, $a0 # t5 = address + offset
	sw $a1, ($t5)
    	addi $t7, $t7, 1
    	j loop_ground
 
# spike function
spike:	li $a3,0
	la $a1, COLOR_SPIKE
	j s_skip
remove_spike:
	la $a1, COLOR_BLACK
s_skip: beq $s7, 2, spike_lvl_2
	beq $s7, 3, spike_lvl_3
spike_lvl_1:
	li $a2, 12 
	la $a0, SPIKE_1_1
	j paint_spike
s_1_2:	li $a2, 13
	la $a0, SPIKE_1_2
	j paint_spike
s_1_3:	li $a2, 0
	la $a0, SPIKE_1_3
	j paint_spike
spike_lvl_2:
	li $a2, 22
	la $a0, SPIKE_2_1
	j paint_spike
s_2_2:	li $a2, 0
	la $a0, SPIKE_2_2
	j paint_spike
spike_lvl_3:
	li $a2, 32
	la $a0, SPIKE_3_1
	j paint_spike
s_3_2:	li $a2, 0
	la $a0, SPIKE_3_2
	j paint_spike
paint_spike:
	# $a0: position
	# $a1: colour
	# $a2: next label
	# $a3 remove calling level
	add $a0, $t0, $a0 # a0 = base + coordinate
	sw $a1, 8($a0)
	sw $a1, 256($a0)
	sw $a1, 264($a0)
	sw $a1, 272($a0)
	sw $a1, 512($a0)
	sw $a1, 520($a0)
	sw $a1, 528($a0)
	sw $a1, 772($a0)
	sw $a1, 776($a0)
	sw $a1, 780($a0)
	sw $a1, 1024($a0)
	sw $a1, 1028($a0)
	sw $a1, 1032($a0)
	sw $a1, 1036($a0)
	sw $a1, 1040($a0)
	
	#sw $a1, 4($a0)
	#sw $a1, 260($a0)
	#sw $a1, 512($a0)
	#sw $a1, 516($a0)
	#sw $a1, 520($a0)
	beq $a2, 12, s_1_2
	beq $a2, 13, s_1_3
	beq $a2, 22, s_2_2
	beq $a2, 32, s_3_2
	bnez $a3, remove_platform
	j platform
	
# platform function
platform: 
	li $a3,0
	la $a1, COLOR_PLATFORM
	j p_skip
remove_platform:
	la $a1, COLOR_BLACK
p_skip:	beq $s7, 2, platform_lvl_2
	beq $s7, 3, platform_lvl_3
platform_lvl_1:
	li $a2, 12
	la $a0, PLATFORM_1_1
	j paint_platform
p_1_2:	li $a2, 0
	la $a0, PLATFORM_1_2
	j paint_platform
platform_lvl_2:
	li $a2, 22
	la $a0, PLATFORM_2_1
	j paint_platform
p_2_2:	li $a2, 0
	la $a0, PLATFORM_2_2
	j paint_platform
platform_lvl_3:
	li $a2, 32
	la $a0, PLATFORM_3_1
	j paint_platform
p_3_2:	li $a2, 33
	la $a0, PLATFORM_3_2
	j paint_platform
p_3_3:	li $a2, 34
	la $a0, PLATFORM_3_3
	j paint_platform
p_3_4:	li $a2, 35
	la $a0, PLATFORM_3_4
	j paint_platform
p_3_5:	li $a2, 0
	la $a0, PLATFORM_3_5
	j paint_platform
paint_platform:
	# $a0: position
	# $a1: colour
	# $a2: next label
	# $a3 remove calling level
	add $a0, $t0, $a0 # a0 = base + coordinate
    	li $t7, 0 # init t7 = 0
loop_platform:
	bge $t7, 15, end_loop_p
	li $t5, 4 	  # 4 bytes
	mul $t5, $t5, $t7 # offset = 4 bytes * index
	add $t5, $t5, $a0 # t5 = address + offset
	sw $a1, ($t5)
    	addi $t7, $t7, 1
    	j loop_platform
end_loop_p:
	beq $a2, 12, p_1_2
	beq $a2, 22, p_2_2
	beq $a2, 32, p_3_2
	beq $a2, 33, p_3_3
	beq $a2, 34, p_3_4
	beq $a2, 35, p_3_5
	bnez $a3, remove_monster
	j monster
	
# monster function
monster:
	li $a3,0
	la $a1, COLOR_MONSTER
	j m_skip
remove_monster:
	la $a1, COLOR_BLACK
m_skip:	beq $s7, 2, monster_lvl_2
	beq $s7, 3, monster_lvl_3
monster_lvl_1:
	j skip_paint_monster # no monster for level 1
monster_lvl_2:
	la $a2, 22
	la $a0, MONSTER_2_1
	j paint_monster
m_2_2:	li $a2, 0
	la $a0, MONSTER_2_2
	j paint_monster
monster_lvl_3:
	li $a2, 32
	la $a0, MONSTER_3_1
	j paint_monster
m_3_2:	li $a2, 33
	la $a0, MONSTER_3_2
	j paint_monster
m_3_3:	li $a2, 0
	la $a0, MONSTER_3_3
	j paint_monster
paint_monster:
	# $a0: position
	# $a1: colour
	# $a3 remove calling level
	add $a0, $t0, $a0 # a0 = base + coordinate
	sw $a1, ($a0)
	sw $a1, 4($a0)
	sw $a1, 8($a0)
	sw $a1, 12($a0)
	sw $a1, 16($a0)
	sw $a1, 256($a0)
	sw $a1, 260($a0)
	sw $a1, 264($a0)
	sw $a1, 268($a0)
	sw $a1, 272($a0)
	
	sw $a1, 512($a0)
	sw $a1, 516($a0)
	sw $a1, 520($a0)
	sw $a1, 524($a0)
	sw $a1, 528($a0)
	sw $a1, 768($a0)
	sw $a1, 772($a0)
	sw $a1, 776($a0)
	sw $a1, 780($a0)
	sw $a1, 784($a0)
	sw $a1, 1024($a0)
	sw $a1, 1040($a0)
	
	beq $a2, 22, m_2_2
	beq $a2, 32, m_3_2
	beq $a2, 33, m_3_3
skip_paint_monster:
	beq $a3, 1, end_r_p_1
	beq $a3, 2, end_r_p_2
	beq $a3, 3, end_r_p_3
	beq $a3, 4, end_r_p_4
	beq $a3, 5, end_r_p_5
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
	sw $a1, 8($a0)
	sw $a1, 12($a0)
	sw $a1, 16($a0)
	sw $a1, 20($a0)
	j health

# health function
health:	la, $a1, COLOR_HEALTH
	li $a2, 2
	la, $a0, HEALTH_1
	j paint_health
h_2:	li $a2, 3
	la, $a0, HEALTH_2
	j paint_health
h_3:	li $a2, 0
	la, $a0, HEALTH_3
	j paint_health
paint_health:
	# $a0: position
	# $a1: colour
	# $s2: next label
	add $a0, $t0, $a0 # a0 = base + coordinate
	sw $a1, ($a0)
	sw $a1, 4($a0)
	sw $a1, 12($a0)
	sw $a1, 16($a0)
	sw $a1, 256($a0)
	sw $a1, 260($a0)
	sw $a1, 264($a0)
	sw $a1, 268($a0)
	sw $a1, 272($a0)
	sw $a1, 516($a0)
	sw $a1, 520($a0)
	sw $a1, 524($a0)
	sw $a1, 776($a0)
	beq $a2, 2, h_2
	beq $a2, 3, h_3
	j player
	
# player function	
player:
	j paint_player
paint_player:
	li $t7, 64 	  #t7 = 64
	mul $t7, $t7, $s2 #t7 = 256/64*y = 64*y
	add $t7, $s1, $t7 #t7 = x + 64*y
	add $t7, $t7, $t0
	la $a1, COLOR_BLUE
	sw $a1, 4($t7)
	sw $a1, 8($t7)
	sw $a1, 256($t7)
	sw $a1, 260($t7)
	sw $a1, 264($t7)
	sw $a1, 268($t7)
	la $a1, COLOR_CREAM
	sw $a1, 516($t7)
	sw $a1, 520($t7)
	sw $a1, 768($t7)
	sw $a1, 780($t7)
	sw $a1, 1540($t7)
	sw $a1, 1544($t7)
	la $a1, COLOR_RED
	sw $a1, 772($t7)
	sw $a1, 776($t7)
	sw $a1, 1028($t7)
	sw $a1, 1032($t7)
	sw $a1, 1284($t7)
	sw $a1, 1288($t7)
	j wait
	
remove_player:
	li $t7, 64 	  #t7 = 64
	mul $t7, $t7, $s2 #t7 = 32*y
	add $t7, $s1, $t7 #t7 = x + 32*y
	add $t7, $t7, $t0 # t7 = base + offset
	la $a1, COLOR_BLACK
	sw $a1, 4($t7)
	sw $a1, 8($t7)
	sw $a1, 256($t7)
	sw $a1, 260($t7)
	sw $a1, 264($t7)
	sw $a1, 268($t7)
	sw $a1, 516($t7)
	sw $a1, 520($t7)
	sw $a1, 768($t7)
	sw $a1, 780($t7)
	sw $a1, 1540($t7)
	sw $a1, 1544($t7)
	sw $a1, 772($t7)
	sw $a1, 776($t7)
	sw $a1, 1028($t7)
	sw $a1, 1032($t7)
	sw $a1, 1284($t7)
	sw $a1, 1288($t7)
	beq $t8, 0x77, jump   	# ASCII code of 'w' is 0x77 
	beq $t8, 0x61, left   	# ASCII code of 'a' is 0x61
	beq $t8, 0x73, gravity  # ASCII code of 's' is 0x73 
	beq $t8, 0x64, right   	# ASCII code of 'd' is 0x64
	beq $t8, 0x31, next_level   # ASCII code of '31' is 0x64
	beq $t8, 0x32, next_level   # ASCII code of '32' is 0x64
	beq $t8, 0x33, next_level   # ASCII code of '33' is 0x64
	beq $t8, 0x6b, win   # ASCII code of 'k' is 0x6b
	beq $t8, 0x6c, lose   # ASCII code of 'l' is 0x6c
 
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
	beq $t8, 0x31, respond_to_1   # ASCII code of '1' is 0x31
	beq $t8, 0x32, respond_to_2   # ASCII code of '2' is 0x32
	beq $t8, 0x33, respond_to_3   # ASCII code of '3' is 0x32
	beq $t8, 0x6b, respond_to_k   # ASCII code of 'k' is 0x6b
	beq $t8, 0x6c, respond_to_l   # ASCII code of 'l' is 0x6c
	beq $t8, 0x70, respond_to_p   # ASCII code of 'p' is 0x70
	j wait

respond_to_w:
	ble $s2, 40, wait
	blez $s2, wait
	j remove_player
jump:	addi $s2, $s2, -16 # y-1
	j paint_player
	
respond_to_a:
	blez $s1, wait
	j remove_player
left:	addi $s1, $s1, -8 # x-4
	j paint_player
	
respond_to_s:
	bge $s2, 212, wait
	j remove_player
gravity:	
	addi $s2, $s2, 4 # y+1
	j paint_player

respond_to_d:
	bge $s1, 240, wait
	j remove_player
right: 	addi $s1, $s1, 8 # x+4
	j paint_player
	
respond_to_1:
	li $a3, 1
	j remove_spike
end_r_p_1:
	li $s7, 1
	j remove_player
	
respond_to_2:
	li $a3, 2
	j remove_spike
end_r_p_2:
	li $s7, 2
	j remove_player
	
respond_to_3:
	li $a3, 3
	j remove_spike
end_r_p_3:
	li $s7, 3
	j remove_player	
	
#p
respond_to_p:
	li $t8, 0x31 
	j respond_to_1

Exit:
 	li $v0, 10 # terminate the program gracefully 
 	syscall 

#win screen
respond_to_k:
	li $a3, 4
	j remove_spike
end_r_p_4:
	li $s7, 3
	j remove_player	

#lose screen
respond_to_l:
	li $a3, 5
	j remove_spike
end_r_p_5:
	li $s7, 3
	j remove_player

#win
win:	la $a1, COLOR_FINISH
	li $a2, 1
	addi $t7, $t0, 3920
	j paint_you

#lose screen
lose:	la $a1, COLOR_RED
	li $a2, 0
	addi $t7, $t0, 3920
	j paint_you
 	
paint_lose:
	# L
	addi $t7, $t7, 2480
	sw $a1,($t7)
	sw $a1, 4($t7)
	
	sw $a1, 256($t7)
	sw $a1, 260($t7)
	
	sw $a1, 512($t7)
	sw $a1, 516($t7)
	
	sw $a1, 768($t7)
	sw $a1, 772($t7)
	
	sw $a1, 1024($t7)
	sw $a1, 1028($t7)
	
	sw $a1, 1280($t7)
	sw $a1, 1284($t7)
	
	sw $a1, 1536($t7)
	sw $a1, 1540($t7)
	sw $a1, 1544($t7)
	sw $a1, 1548($t7)
	sw $a1, 1552($t7)
	sw $a1, 1556($t7)
	
	sw $a1, 1792($t7)
	sw $a1, 1796($t7)
	sw $a1, 1800($t7)
	sw $a1, 1804($t7)
	sw $a1, 1808($t7)
	sw $a1, 1812($t7)
	
	#paint O
	addi $t7, $t7, 32
	sw $a1,($t7)
	sw $a1, 4($t7)
	sw $a1, 8($t7)
	sw $a1, 12($t7)
	sw $a1, 16($t7)
	sw $a1, 20($t7)
	
	sw $a1, 256($t7)
	sw $a1, 260($t7)
	sw $a1, 264($t7)
	sw $a1, 268($t7)
	sw $a1, 272($t7)
	sw $a1, 276($t7)
	
	sw $a1, 512($t7)
	sw $a1, 516($t7)
	sw $a1, 528($t7)
	sw $a1, 532($t7)
	
	sw $a1, 768($t7)
	sw $a1, 772($t7)
	sw $a1, 784($t7)
	sw $a1, 788($t7)
	
	sw $a1, 1024($t7)
	sw $a1, 1028($t7)
	sw $a1, 1040($t7)
	sw $a1, 1044($t7)
	
	sw $a1, 1280($t7)
	sw $a1, 1284($t7)
	sw $a1, 1296($t7)
	sw $a1, 1300($t7)
	
	sw $a1, 1536($t7)
	sw $a1, 1540($t7)
	sw $a1, 1544($t7)
	sw $a1, 1548($t7)
	sw $a1, 1552($t7)
	sw $a1, 1556($t7)
	
	sw $a1, 1792($t7)
	sw $a1, 1796($t7)
	sw $a1, 1800($t7)
	sw $a1, 1804($t7)
	sw $a1, 1808($t7)
	sw $a1, 1812($t7)
	
	#place holder
	addi $t7, $t7, 32
	sw $a1,($t7)
	sw $a1, 4($t7)
	sw $a1, 8($t7)
	sw $a1, 12($t7)
	sw $a1, 16($t7)
	sw $a1, 20($t7)
	
	sw $a1, 256($t7)
	sw $a1, 260($t7)
	sw $a1, 264($t7)
	sw $a1, 268($t7)
	sw $a1, 272($t7)
	sw $a1, 276($t7)
	
	sw $a1, 512($t7)
	sw $a1, 516($t7)
	
	sw $a1, 768($t7)
	sw $a1, 772($t7)
	sw $a1, 776($t7)
	sw $a1, 780($t7)
	sw $a1, 784($t7)
	
	sw $a1, 1028($t7)
	sw $a1, 1032($t7)
	sw $a1, 1036($t7)
	sw $a1, 1040($t7)
	sw $a1, 1044($t7)
	
	sw $a1, 1296($t7)
	sw $a1, 1300($t7)
	
	sw $a1, 1536($t7)
	sw $a1, 1540($t7)
	sw $a1, 1544($t7)
	sw $a1, 1548($t7)
	sw $a1, 1552($t7)
	sw $a1, 1556($t7)
	
	sw $a1, 1792($t7)
	sw $a1, 1796($t7)
	sw $a1, 1800($t7)
	sw $a1, 1804($t7)
	sw $a1, 1808($t7)
	sw $a1, 1812($t7)
	
	# E
	addi $t7, $t7, 32
	sw $a1,($t7)
	sw $a1, 4($t7)
	sw $a1, 8($t7)
	sw $a1, 12($t7)
	sw $a1, 16($t7)
	sw $a1, 20($t7)
	
	sw $a1, 256($t7)
	sw $a1, 260($t7)
	sw $a1, 264($t7)
	sw $a1, 268($t7)
	sw $a1, 272($t7)
	sw $a1, 276($t7)
	
	sw $a1, 512($t7)
	sw $a1, 516($t7)
	
	sw $a1, 768($t7)
	sw $a1, 772($t7)
	sw $a1, 776($t7)
	sw $a1, 780($t7)
	sw $a1, 784($t7)
	sw $a1, 788($t7)
	
	sw $a1, 1024($t7)
	sw $a1, 1028($t7)
	sw $a1, 1032($t7)
	sw $a1, 1036($t7)
	sw $a1, 1040($t7)
	sw $a1, 1044($t7)
	
	sw $a1, 1280($t7)
	sw $a1, 1284($t7)
	
	sw $a1, 1536($t7)
	sw $a1, 1540($t7)
	sw $a1, 1544($t7)
	sw $a1, 1548($t7)
	sw $a1, 1552($t7)
	sw $a1, 1556($t7)
	
	sw $a1, 1792($t7)
	sw $a1, 1796($t7)
	sw $a1, 1800($t7)
	sw $a1, 1804($t7)
	sw $a1, 1808($t7)
	sw $a1, 1812($t7)
	j Exit
	
paint_win:
	#W
	addi $t7, $t7, 2492
	sw $a1,($t7)
	sw $a1, 4($t7)
	sw $a1, 32($t7)
	sw $a1, 36($t7)
	
	
	sw $a1, 256($t7)
	sw $a1, 260($t7)
	sw $a1, 288($t7)
	sw $a1, 292($t7)

	
	sw $a1, 512($t7)
	sw $a1, 516($t7)
	sw $a1, 544($t7)
	sw $a1, 548($t7)
	
	sw $a1, 768($t7)
	sw $a1, 772($t7)
	sw $a1, 784($t7)
	sw $a1, 788($t7)	
	sw $a1, 800($t7)
	sw $a1, 804($t7)
	
	sw $a1, 1024($t7)
	sw $a1, 1028($t7)
	sw $a1, 1040($t7)
	sw $a1, 1044($t7)
	sw $a1, 1056($t7)
	sw $a1, 1060($t7)
	
	sw $a1, 1280($t7)
	sw $a1, 1284($t7)
	sw $a1, 1296($t7)
	sw $a1, 1300($t7)
	sw $a1, 1312($t7)
	sw $a1, 1316($t7)
	
	sw $a1, 1536($t7)
	sw $a1, 1540($t7)
	sw $a1, 1544($t7)
	sw $a1, 1548($t7)
	sw $a1, 1552($t7)
	sw $a1, 1556($t7)
	sw $a1, 1560($t7)
	sw $a1, 1564($t7)
	sw $a1, 1568($t7)
	sw $a1, 1572($t7)
	
	sw $a1, 1792($t7)
	sw $a1, 1796($t7)
	sw $a1, 1800($t7)
	sw $a1, 1804($t7)
	sw $a1, 1808($t7)
	sw $a1, 1812($t7)
	sw $a1, 1816($t7)
	sw $a1, 1820($t7)
	sw $a1, 1824($t7)
	sw $a1, 1828($t7)
	
	#place I
	addi $t7, $t7, 48
	sw $a1,($t7)
	sw $a1, 4($t7)
	
	sw $a1, 256($t7)
	sw $a1, 260($t7)
	
	sw $a1, 512($t7)
	sw $a1, 516($t7)
	
	sw $a1, 768($t7)
	sw $a1, 772($t7)
	
	sw $a1, 1024($t7)
	sw $a1, 1028($t7)
	
	sw $a1, 1280($t7)
	sw $a1, 1284($t7)
	
	sw $a1, 1536($t7)
	sw $a1, 1540($t7)
	
	sw $a1, 1792($t7)
	sw $a1, 1796($t7)
	
	#N
	addi $t7, $t7, 16
	sw $a1,($t7)
	sw $a1, 4($t7)
	sw $a1, 4($t7)
	sw $a1, 24($t7)
	sw $a1, 28($t7)
	
	sw $a1, 256($t7)
	sw $a1, 260($t7)
	sw $a1, 264($t7)
	sw $a1, 280($t7)
	sw $a1, 284($t7)
	
	sw $a1, 512($t7)
	sw $a1, 516($t7)
	sw $a1, 520($t7)
	sw $a1, 524($t7)
	sw $a1, 536($t7)
	sw $a1, 540($t7)
	
	sw $a1, 768($t7)
	sw $a1, 772($t7)
	sw $a1, 776($t7)
	sw $a1, 780($t7)
	sw $a1, 784($t7)
	sw $a1, 792($t7)
	sw $a1, 796($t7)
	
	sw $a1, 1024($t7)
	sw $a1, 1028($t7)
	sw $a1, 1036($t7)
	sw $a1, 1040($t7)
	sw $a1, 1044($t7)
	sw $a1, 1048($t7)
	sw $a1, 1052($t7)
	
	
	sw $a1, 1280($t7)
	sw $a1, 1284($t7)
	sw $a1, 1296($t7)
	sw $a1, 1300($t7)
	sw $a1, 1304($t7)
	sw $a1, 1308($t7)
	
	sw $a1, 1536($t7)
	sw $a1, 1540($t7)
	sw $a1, 1556($t7)
	sw $a1, 1560($t7)
	sw $a1, 1564($t7)
	
	sw $a1, 1792($t7)
	sw $a1, 1796($t7)
	sw $a1, 1816($t7)
	sw $a1, 1820($t7)
	j Exit
	
paint_you:
	# paint Y
	sw $a1, 0($t7)
	sw $a1, 4($t7)
	sw $a1, 16($t7)
	sw $a1, 20($t7)
	sw $a1, 256($t7)
	sw $a1, 260($t7)
	sw $a1, 272($t7)
	sw $a1, 276($t7)
	sw $a1, 512($t7)
	sw $a1, 516($t7)
	sw $a1, 520($t7)
	sw $a1, 524($t7)
	sw $a1, 528($t7)
	sw $a1, 532($t7)
	sw $a1, 768($t7)
	sw $a1, 772($t7)
	sw $a1, 776($t7)
	sw $a1, 780($t7)
	sw $a1, 784($t7)
	sw $a1, 788($t7)
	sw $a1, 1032($t7)
	sw $a1, 1036($t7)
	sw $a1, 1288($t7)
	sw $a1, 1292($t7)
	sw $a1, 1544($t7)
	sw $a1, 1548($t7)
	sw $a1, 1800($t7)
	sw $a1, 1804($t7)
	
	
	#paint O
	addi $t7, $t7, 32
	sw $a1,($t7)
	sw $a1, 4($t7)
	sw $a1, 8($t7)
	sw $a1, 12($t7)
	sw $a1, 16($t7)
	sw $a1, 20($t7)
	
	sw $a1, 256($t7)
	sw $a1, 260($t7)
	sw $a1, 264($t7)
	sw $a1, 268($t7)
	sw $a1, 272($t7)
	sw $a1, 276($t7)
	
	sw $a1, 512($t7)
	sw $a1, 516($t7)
	sw $a1, 528($t7)
	sw $a1, 532($t7)
	
	sw $a1, 768($t7)
	sw $a1, 772($t7)
	sw $a1, 784($t7)
	sw $a1, 788($t7)
	
	sw $a1, 1024($t7)
	sw $a1, 1028($t7)
	sw $a1, 1040($t7)
	sw $a1, 1044($t7)
	
	sw $a1, 1280($t7)
	sw $a1, 1284($t7)
	sw $a1, 1296($t7)
	sw $a1, 1300($t7)
	
	sw $a1, 1536($t7)
	sw $a1, 1540($t7)
	sw $a1, 1544($t7)
	sw $a1, 1548($t7)
	sw $a1, 1552($t7)
	sw $a1, 1556($t7)
	
	sw $a1, 1792($t7)
	sw $a1, 1796($t7)
	sw $a1, 1800($t7)
	sw $a1, 1804($t7)
	sw $a1, 1808($t7)
	sw $a1, 1812($t7)
	
	#paint U
	addi $t7, $t7, 32
	sw $a1,($t7)
	sw $a1, 4($t7)
	sw $a1, 16($t7)
	sw $a1, 20($t7)
	
	sw $a1, 256($t7)
	sw $a1, 260($t7)
	sw $a1, 272($t7)
	sw $a1, 276($t7)
	
	sw $a1, 512($t7)
	sw $a1, 516($t7)
	sw $a1, 528($t7)
	sw $a1, 532($t7)
	
	sw $a1, 768($t7)
	sw $a1, 772($t7)
	sw $a1, 784($t7)
	sw $a1, 788($t7)
	
	sw $a1, 1024($t7)
	sw $a1, 1028($t7)
	sw $a1, 1040($t7)
	sw $a1, 1044($t7)
	
	sw $a1, 1280($t7)
	sw $a1, 1284($t7)
	sw $a1, 1296($t7)
	sw $a1, 1300($t7)
	
	sw $a1, 1536($t7)
	sw $a1, 1540($t7)
	sw $a1, 1544($t7)
	sw $a1, 1548($t7)
	sw $a1, 1552($t7)
	sw $a1, 1556($t7)
	
	sw $a1, 1792($t7)
	sw $a1, 1796($t7)
	sw $a1, 1800($t7)
	sw $a1, 1804($t7)
	sw $a1, 1808($t7)
	sw $a1, 1812($t7)

	beqz $a2, paint_lose
	j paint_win
