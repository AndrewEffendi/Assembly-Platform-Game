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
.eqv	MONSTER_3_3	9408

.eqv	SPIKE_1_1	14188
.eqv	SPIKE_1_2	14204
.eqv	SPIKE_1_3	14220
.eqv	SPIKE_2_1	11176
.eqv	SPIKE_2_2	300
.eqv	SPIKE_3_1	7964
.eqv	SPIKE_3_2	7540

.eqv	PLATFORM_1_1	13868
.eqv	PLATFORM_1_2	13212
.eqv	PLATFORM_2_1	13872
.eqv	PLATFORM_2_2	12432
.eqv	PLATFORM_3_1	13892
.eqv	PLATFORM_3_2	12452
.eqv	PLATFORM_3_3	10688
.eqv	PLATFORM_3_4	8800
.eqv	PLATFORM_3_5	9220

.eqv	GROUND		15360
.eqv	FINISH_1	15592
.eqv	FINISH_2	12432
.eqv	FINISH_3	9220

.eqv	HEALTH_1	520
.eqv	HEALTH_2	548
.eqv	HEALTH_3	576
 
.text

  # s0: health
  # s1: x coordinate
  # s2: y coordinate
  # s3: double jump  
  # s4: enemy location
  # s5: enemy direction
  # s6: clock counter
  # s7: level
  # t0: jump counter
  # t8: previouse pressed key
 	
reset:	li $s0, 3 # health
	li $s7, 1 # level

next_level:
	
 	li $s1, 0 # player's x-coordinate
 	li $s2, 204 # player's y-coordinate
 	li $s3, 2 # double jump
 	li $s4, 0 #0 to 40 range
 	li $s5, 0
 	li $s6, 1 # reset clock to 0
 	li $t0, 0 # jump counter

# ground function
ground:	la $a1, COLOR_GROUND
	la $a0, GROUND
 	j paint_ground
paint_ground:
	# $a0: position
	# $a1: colour
	addi $a0, $a0, BASE_ADDRESS
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
	addi $a0, $a0, BASE_ADDRESS
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
	addi $a0, $a0, BASE_ADDRESS
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
	li $a3,0 # $s3: remove calling function, monster not remove
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
	add $a0, $a0, $s4
	j paint_monster
m_2_2:	li $a2, 0
	la $a0, MONSTER_2_2
	add $a0, $a0, $s4
	j paint_monster
monster_lvl_3:
	li $a2, 32
	la $a0, MONSTER_3_1
	add $a0, $a0, $s4
	j paint_monster
m_3_2:	li $a2, 33
	la $a0, MONSTER_3_2
	add $a0, $a0, $s4
	j paint_monster
m_3_3:	li $a2, 0
	la $a0, MONSTER_3_3
	add $a0, $a0, $s4
	j paint_monster
paint_monster:
	# $a0: position
	# $a1: colour
	# $a3 remove calling level
	addi $a0, $a0, BASE_ADDRESS
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
	# move monster
	beqz $s6, move_monster_next
	j finish
move_monster_next:	
	la $t7, COLOR_BLACK	
	beq $a1, $t7 , remove_monster_done	
	j move_monster_done

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
	addi $a0, $a0, BASE_ADDRESS
	sw $a1, ($a0)
	sw $a1, 4($a0)
	sw $a1, 8($a0)
	sw $a1, 12($a0)
	sw $a1, 16($a0)
	sw $a1, 20($a0)
	j health

# health function
remove_health:
	la, $a1, COLOR_BLACK
	li $a2, 4
	beq $s0, 3, rh_3
	beq $s0, 2, rh_2
	beq $s0, 1, rh_1
	#remove
	j respond_to_l
rh_3:	la, $a0, HEALTH_3
	j paint_health
rh_2:	la, $a0, HEALTH_2
	j paint_health
rh_1:	la, $a0, HEALTH_1
	j paint_health
removed_health:
	j damage_player
player_damaged:
	addi $s0, $s0, -1 #ewduced health by 1
	beqz $s0, respond_to_l # if no heart lose
	beqz $s6, move_monster_done
	j wait

health:	la, $a1, COLOR_HEALTH
	li $a2, 2
	la, $a0, HEALTH_1
	j paint_health
h_2:	blt $s0, 2, player #if health less than 2 don't paint
	li $a2, 3
	la, $a0, HEALTH_2
	j paint_health
h_3:	blt $s0, 3, player #if health less than 3 don't paint
	li $a2, 0
	la, $a0, HEALTH_3
	j paint_health
paint_health:
	# $a0: position
	# $a1: colour
	# $s2: next label
	addi $a0, $a0, BASE_ADDRESS
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
	beq $a2, 4, removed_health
	j player
	
# player function
# $a1 color 	
player:
	j paint_player
paint_player:
	li $t7, 64 	  	#t7 = 64
	mul $t7, $t7, $s2 	#t7 = 256/64*y = 64*y
	add $t7, $s1, $t7 	#t7 = x + 64*y
	addi $t7, $t7, BASE_ADDRESS
	la $a1, COLOR_RED
	sw $a1, 4($t7)
	sw $a1, 8($t7)
	sw $a1, 12($t7)
	sw $a1, 260($t7)
	sw $a1, 264($t7)
	sw $a1, 268($t7)
	sw $a1, 272($t7)
	sw $a1, 1028($t7)
	sw $a1, 1036($t7)
	la $a1, COLOR_CREAM
	sw $a1, 516($t7)
	sw $a1, 520($t7)
	sw $a1, 524($t7)
	sw $a1, 772($t7)
	sw $a1, 776($t7)
	sw $a1, 780($t7)
	sw $a1, 1024($t7)
	sw $a1, 1040($t7)
	sw $a1, 2052($t7)
	sw $a1, 2060($t7)
	la $a1, COLOR_BLUE
	sw $a1, 1032($t7)
	sw $a1, 1284($t7)
	sw $a1, 1288($t7)
	sw $a1, 1292($t7)
	sw $a1, 1540($t7)
	sw $a1, 1544($t7)
	sw $a1, 1548($t7)
	sw $a1, 1796($t7)
	sw $a1, 1800($t7)
	sw $a1, 1804($t7)
jump_count:
	beq $t0, 1, jump_2
	beq $t0, 2, jump_3
	beq $t0, 3, jump_4
	beq $t0, 4, jump_5
	j finish_check
finished_check:
	bne $t8 0x77, jump_check # w
jump_checked:
	j wait
	
remove_player:
	li $t7, 64 	  	#t7 = 64
	mul $t7, $t7, $s2 	#t7 = 32*y
	add $t7, $s1, $t7 	#t7 = x + 32*y
	addi $t7, $t7, BASE_ADDRESS
	la $a1, COLOR_BLACK
	sw $a1, 4($t7)
	sw $a1, 8($t7)
	sw $a1, 12($t7)
	sw $a1, 260($t7)
	sw $a1, 264($t7)
	sw $a1, 268($t7)
	sw $a1, 272($t7)
	sw $a1, 516($t7)
	sw $a1, 520($t7)
	sw $a1, 524($t7)
	sw $a1, 772($t7)
	sw $a1, 776($t7)
	sw $a1, 780($t7)
	sw $a1, 1024($t7)
	sw $a1, 1040($t7)
	sw $a1, 2052($t7)
	sw $a1, 2060($t7)
	sw $a1, 1028($t7)
	sw $a1, 1032($t7)
	sw $a1, 1036($t7)
	sw $a1, 1284($t7)
	sw $a1, 1288($t7)
	sw $a1, 1292($t7)
	sw $a1, 1540($t7)
	sw $a1, 1544($t7)
	sw $a1, 1548($t7)
	sw $a1, 1796($t7)
	sw $a1, 1800($t7)
	sw $a1, 1804($t7)
	beq $t8, 0x77, jump   		# ASCII code of 'w' is 0x77 
	beq $t8, 0x61, left   		# ASCII code of 'a' is 0x61
	beq $t8, 0x73, gravity  	# ASCII code of 's' is 0x73 
	beq $t8, 0x64, right   		# ASCII code of 'd' is 0x64
	beq $t8, 0x31, next_level   	# ASCII code of '31' is 0x64
	beq $t8, 0x32, next_level  	# ASCII code of '32' is 0x64
	beq $t8, 0x33, next_level   	# ASCII code of '33' is 0x64
	beq $t8, 0x6b, win   		# ASCII code of 'k' is 0x6b
	beq $t8, 0x6c, lose   		# ASCII code of 'l' is 0x6c

damage_player:
	li $t7, 64 	  	#t7 = 64
	mul $t7, $t7, $s2 	#t7 = 256/64*y = 64*y
	add $t7, $s1, $t7 	#t7 = x + 64*y
	addi $t7, $t7, BASE_ADDRESS
	la $a1, COLOR_RED
	sw $a1, 4($t7)
	sw $a1, 8($t7)
	sw $a1, 12($t7)
	sw $a1, 260($t7)
	sw $a1, 264($t7)
	sw $a1, 268($t7)
	sw $a1, 272($t7)
	sw $a1, 1028($t7)
	sw $a1, 1036($t7)
	sw $a1, 516($t7)
	sw $a1, 520($t7)
	sw $a1, 524($t7)
	sw $a1, 772($t7)
	sw $a1, 776($t7)
	sw $a1, 780($t7)
	sw $a1, 1024($t7)
	sw $a1, 1040($t7)
	sw $a1, 2052($t7)
	sw $a1, 2060($t7)
	sw $a1, 1032($t7)
	sw $a1, 1284($t7)
	sw $a1, 1288($t7)
	sw $a1, 1292($t7)
	sw $a1, 1540($t7)
	sw $a1, 1544($t7)
	sw $a1, 1548($t7)
	sw $a1, 1796($t7)
	sw $a1, 1800($t7)
	sw $a1, 1804($t7)
	li $v0, 32 
	li $a0, 100   # Wait 100 milliseconds 
	syscall 
	la $a1, COLOR_RED
	sw $a1, 4($t7)
	sw $a1, 8($t7)
	sw $a1, 12($t7)
	sw $a1, 260($t7)
	sw $a1, 264($t7)
	sw $a1, 268($t7)
	sw $a1, 272($t7)
	sw $a1, 1028($t7)
	sw $a1, 1036($t7)
	la $a1, COLOR_CREAM
	sw $a1, 516($t7)
	sw $a1, 520($t7)
	sw $a1, 524($t7)
	sw $a1, 772($t7)
	sw $a1, 776($t7)
	sw $a1, 780($t7)
	sw $a1, 1024($t7)
	sw $a1, 1040($t7)
	sw $a1, 2052($t7)
	sw $a1, 2060($t7)
	la $a1, COLOR_BLUE
	sw $a1, 1032($t7)
	sw $a1, 1284($t7)
	sw $a1, 1288($t7)
	sw $a1, 1292($t7)
	sw $a1, 1540($t7)
	sw $a1, 1544($t7)
	sw $a1, 1548($t7)
	sw $a1, 1796($t7)
	sw $a1, 1800($t7)
	sw $a1, 1804($t7) 
	j player_damaged
	
 
wait:
 	li $t9, 0xffff0000  
	lw $t8, 0($t9) 
	beq $t8, 1, keypress_happened 
	
	addi $s6, $s6, 1
	beq $s6, 50, one_second #0.5 second
	li $v0, 32 
	li $a0, 10   # Wait 10 milliseconds 
	syscall 
	j wait

one_second:
	li $s6, 0 # reset clock to 0
	beqz $s4, set_monster_right
	beq $s4, 40, set_monster_left
	j set_monster_done
set_monster_right:
	li $s5, 0
	j set_monster_done
set_monster_left:
	li $s5, 1
	j set_monster_done
set_monster_done:
	beqz $s5, check_move_monster_right
	j check_move_monster_left
update_monster:
	li $a3, 0 # not type end_r_p
	j remove_monster
remove_monster_done:
	beqz $s5, move_monster_right
	j move_monster_left 
move_monster_left:
	addi $s4, $s4, -4 #move monster left
	j monster
move_monster_right:
	addi $s4, $s4, 4 #move monster right
	j monster
move_monster_done:
	li $s6, 1 # reset clock to 1
	li $t8, 0x73
	j respond_to_s #go down once

check_move_monster_left:
	# player location
	li $a0, 64 	  	#t7 = 64
	mul $a0, $a0, $s2 	#t7 = 32*y
	add $a0, $s1, $a0 	#t7 = x + 32*y
	addi $a0, $a0, 1040 	# 4 row down + 4 cell right
	beq $s7, 2, monster_left_check_2
	#beq $s7, 3, monster_left_check_3
	j update_monster
monster_left_check_2:
ml21:	li $a3, 22
	la $a1, MONSTER_2_1
	j check_ml
ml22:	li $a3, 0
	la $a1, MONSTER_2_2
	j check_ml
monster_left_check_3:

check_ml:
	add $a1, $a1, $s4
	addi $a1, $a1, -4 #move monster left
	beq $a0, $a1, remove_health
	j update_monster
	
check_move_monster_right:
	j update_monster
	
	
	
	
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
	beq $s3, 0, wait # jump not available
	addi $s3, $s3, -1 #reduce jump
	li $t0, 1
	j jump_loop
jump_2: li $t0, 2
	j jump_loop
jump_3: li $t0, 3
	j jump_loop
jump_4: li $t0, 4
	j jump_loop
jump_5: li $t0, 0
	j jump_loop
jump_loop:
	j collision_check
jump:	addi $s2, $s2, -4 	# y-1
	bge $s2, 40, paint_player
	li $s2, 40 		# cap y >= 40
	j paint_player
	
respond_to_a:
	j collision_check
left:	addi $s1, $s1, -4 	# x-4
	bgez $s1, paint_player
	li $s1, 0 		# cap x >= 0
	j paint_player
	
respond_to_s:
	j collision_check
gravity:	
	addi $s2, $s2, 4 	# y+1
	ble $s2, 204, paint_player
	li $s2, 204 		# cap y <= 204
	j paint_player

respond_to_d:
	j collision_check
right: 	addi $s1, $s1, 4 	# x+4
	ble $s1, 236, paint_player
	li $s1, 236 		# cap x >= 0
	j paint_player
	
jump_check:
	# player location
	li $a0, 64 	  	#t7 = 64
	mul $a0, $a0, $s2 	#t7 = 32*y
	add $a0, $s1, $a0 	#t7 = x + 32*y
	addi $a0, $a0, 2308 	# 10 row down + 1 cell right
jump_check_ground:
	la $t6, GROUND
    	li $t7, 0
loop_jcg:
	bge $t7, 64, end_loop_jcg
	li $t5, 4	  # 4 bytes
	mul $t5, $t5, $t7 # offset = 4 bytes * index
	add $t5, $t5, $t6 # t5 = address + offset
	beq $t5, $a0 double_jump_reset
    	addi $t7, $t7, 1
    	j loop_jcg
end_loop_jcg:
	beq $s7, 1, jump_check_1
	beq $s7, 2, jump_check_2
	j jump_check_3
jump_check_1:
jc11:	li $a3, 12
	la $a1, PLATFORM_1_1
	j jump_check_patform
jc12:	li $a3, 0
	la $a1, PLATFORM_1_2
	j jump_check_patform
jump_check_2:
jc21:	li $a3, 22
	la $a1, PLATFORM_2_1 
	j jump_check_patform
jc22:	li $a3, 0
	la $a1, PLATFORM_2_2
	j jump_check_patform
jump_check_3:
jc31:	li $a3, 32
	la $a1, PLATFORM_3_1 
	j jump_check_patform
jc32:	li $a3, 33
	la $a1, PLATFORM_3_2
	j jump_check_patform
jc33:	li $a3, 34
	la $a1, PLATFORM_3_3 
	j jump_check_patform
jc34:	li $a3, 35
	la $a1, PLATFORM_3_4
	j jump_check_patform
jc35:	li $a3, 0
	la $a1, PLATFORM_3_5 
	j jump_check_patform
jump_check_patform:
	li $t7, -2 # init t7 = 0
loop_jcp:
	bge $t7, 15, end_loop_jcp
	li $t5, 4	  # 4 bytes
	mul $t5, $t5, $t7 # offset = 4 bytes * index
	add $t5, $t5, $a1 # t5 = address + offset
	beq $t5, $a0 double_jump_reset
    	addi $t7, $t7, 1
    	j loop_jcp
end_loop_jcp:
	beq $a3, 12, jc12
	beq $a3, 22, jc22
	beq $a3, 32, jc32
	beq $a3, 33, jc33
	beq $a3, 34, jc34
	beq $a3, 35, jc35
	j jump_checked
double_jump_reset:
	li $s3, 2
	j jump_checked


finish_check:
	# player location
	li $a0, 64 	  	#t7 = 64
	mul $a0, $a0, $s2 	#t7 = 32*y
	add $a0, $s1, $a0 	#t7 = x + 32*y
	addi $a0, $a0, 2308 	# 10 row down + 1 cell right
	beq $s7, 1, finish_check_1
	beq $s7, 2, finish_check_2
	j finish_check_3
	j finished_check
finish_check_1:
	li $t6, FINISH_1
	beq $a0, $t6, respond_to_2
	addi $t6, $t6, 4
	beq $a0, $t6, respond_to_2
	addi $t6, $t6, 4
	beq $a0, $t6, respond_to_2
	addi $t6, $t6, 4
	beq $a0, $t6, respond_to_2
	j finished_check
finish_check_2:
	li $t6, FINISH_2
	beq $a0, $t6, respond_to_3
	addi $t6, $t6, 4
	beq $a0, $t6, respond_to_3
	addi $t6, $t6, 4
	beq $a0, $t6, respond_to_3
	addi $t6, $t6, 4
	beq $a0, $t6, respond_to_3
	j finished_check
finish_check_3:
	li $t6, FINISH_3
	beq $a0, $t6, respond_to_k
	addi $t6, $t6, 4
	beq $a0, $t6, respond_to_k
	addi $t6, $t6, 4
	beq $a0, $t6, respond_to_k
	addi $t6, $t6, 4
	beq $a0, $t6, respond_to_k
	j finished_check



platform_check:
	beq $s7, 1, platform_check_1
	beq $s7, 2, platform_check_2
	j platform_check_3
#$a3, next label
platform_check_1:
p11:	li $a3, 12
	la $a1, PLATFORM_1_1 
	j check_mtp
p12:	li $a3, 0
	la $a1, PLATFORM_1_2
	j check_mtp
platform_check_2:
p21:	li $a3, 22
	la $a1, PLATFORM_2_1 
	j check_mtp
p22:	li $a3, 0
	la $a1, PLATFORM_2_2
	j check_mtp
platform_check_3:
p31:	li $a3, 32
	la $a1, PLATFORM_3_1 
	j check_mtp
p32:	li $a3, 33
	la $a1, PLATFORM_3_2
	j check_mtp
p33:	li $a3, 34
	la $a1, PLATFORM_3_3 
	j check_mtp
p34:	li $a3, 35
	la $a1, PLATFORM_3_4
	j check_mtp
p35:	li $a3, 0
	la $a1, PLATFORM_3_5 
	j check_mtp

check_mtp:
	li $a0, 64 	  	#t7 = 64
	mul $a0, $a0, $s2 	#t7 = 32*y
	add $a0, $s1, $a0 	#t7 = x + 32*y
	addi $a0, $a0, BASE_ADDRESS 	# t7 = base + offset
	beq $t8, 0x77, wp_offset   # ASCII code of 'w' is 0x77
	beq $t8, 0x61, ap_offset   # ASCII code of 'a' is 0x61
	beq $t8, 0x73, sp_offset   # ASCII code of 's' is 0x73 
	j dp_offset
wp_offset:
	addi $a0, $a0, -244  	#t7 + 8 row below + 5 cell righ
	j sp_check

ap_offset:
	addi $a0, $a0, 1988  	#t7 + 8 row below + 5 cell left
	j vertical_p_check
dp_offset:
	addi $a0, $a0, 2068  	#t7 + 8 row below + 5 cell right
	j vertical_p_check
sp_offset:
	addi $a0, $a0, 2316  	#t7 + 8 row below + 5 cell righ
	j sp_check
	
vertical_p_check:
#$a0 player location + offset
	addi $a1, $a1, BASE_ADDRESS
	li $t5, 0
loop_vpc:
	bge $t5, 9, end_loop_vpc
	beq $a1, $a0, wait
	addi $a1, $a1, 256
    	addi $t5, $t5, 1
    	j loop_vpc
end_loop_vpc:
	j platform_checked

sp_check:
#$a0 player location + offset
	addi $a1, $a1,-4 #shift left once
	addi $a1, $a1, BASE_ADDRESS
	bge $a0, $a1, csp
	j sp_check_next
csp: 	addi $a1, $a1, 72
	ble $a0, $a1, wait
sp_check_next:
	j platform_checked
	
platform_checked:
	# a3 next label
	beq $a3, 12, p12
	beq $a3, 22, p22
	beq $a3, 32, p32
	beq $a3, 33, p33
	beq $a3, 34, p34
	beq $a3, 35, p35
	j remove_player
	
	
	
	
collision_check:
	beq $s7, 1, collision_check_1
	beq $s7, 2, collision_check_2
	j collision_check_3
#$a3, next label
# check collission for lvl 1
collision_check_1:
c11:	li $a3, 12
	la $a1, SPIKE_1_1 
	j check_mt
c12:	li $a3, 13
	la $a1, SPIKE_1_2
	j check_mt
c13:	li $a3, 0
	la $a1, SPIKE_1_3
	j check_mt
#check collision for level 2
collision_check_2:
c21:	li $a3, 22
	la $a1, SPIKE_2_1 
	j check_mt
c22:	li $a3, 23
	la $a1, SPIKE_2_2
	j check_mt
c23:	li $a3, 24
	la $a1, MONSTER_2_1
	add $a1, $a1, $s4
	j check_mt
c24:	li $a3, 0
	la $a1, MONSTER_2_2
	add $a1, $a1, $s4
	j check_mt
#check collision for level 3
collision_check_3:
c31:	li $a3, 32
	la $a1, SPIKE_3_1 
	j check_mt
c32:	li $a3, 33
	la $a1, SPIKE_3_2
	j check_mt
c33:	li $a3, 34
	la $a1, MONSTER_3_1
	add $a1, $a1, $s4
	j check_mt
c34:	li $a3, 35
	la $a1, MONSTER_3_2
	add $a1, $a1, $s4
	j check_mt
c35:	li $a3, 0
	la $a1, MONSTER_3_3
	add $a1, $a1, $s4
	j check_mt

#check movement type
check_mt:
	li $a0, 64 	  	#t7 = 64
	mul $a0, $a0, $s2 	#t7 = 64*y
	add $a0, $s1, $a0 	#t7 = x + 32*y
	addi $a0, $a0, BASE_ADDRESS 	# t7 = base + offset
	beq $t8, 0x61, a_offset   # ASCII code of 'a' is 0x61
	beq $t8, 0x73, s_offset   # ASCII code of 's' is 0x7
	beq $t8, 0x64, d_offset   # ASCII code of 'd' is 0x643 
	j platform_check
a_offset:
	addi $a0, $a0, 2028  	#t7 + 8 row below + 5 cell left
	j vertical_check
d_offset:
	addi $a0, $a0, 2068  	#t7 + 8 row below + 5 cell right
	j vertical_check
s_offset:
	addi $a0, $a0, 2316  	#t7 + 8 row below + 5 cell righ
	j s_check
	
vertical_check:
#$a0 player location + offset
	addi $a1, $a1, BASE_ADDRESS
	li $t5, 0
loop_vc:
	bge $t5, 5, end_loop_vc
	# here damage
	beq $a1, $a0, damaged
	addi $a1, $a1, 256
    	addi $t5, $t5, 1
    	j loop_vc
end_loop_vc:
	j collision_checked
	
s_check:
#$a0 player location + offset
	addi $a1, $a1,-4 #shift left once
	add $a1, $a1, BASE_ADDRESS
	bge $a0, $a1, cs
	j s_check_next
cs: 	addi $a1, $a1, 32
	# here damage
	ble $a0, $a1, damaged
s_check_next:
	j collision_checked

collision_checked:
	# $a3 next label
	beq $a3, 12, c12
	beq $a3, 13, c13
	beq $a3, 22, c22
	beq $a3, 23, c23
	beq $a3, 24, c24
	beq $a3, 32, c32
	beq $a3, 33, c33
	beq $a3, 34, c34
	beq $a3, 35, c35
	j platform_check

damaged:
	j remove_health
	
respond_to_1:
	li $s0, 3 # set health to 3
	li $a3, 1
	li $t8, 0x31
	j remove_spike
end_r_p_1:
	li $s7, 1
	j remove_player
	
respond_to_2:
	li $a3, 2
	li $t8, 0x32
	j remove_spike
end_r_p_2:
	li $s7, 2
	j remove_player
	
respond_to_3:
	li $a3, 3
	li $t8, 0x33
	j remove_spike
end_r_p_3:
	li $s7, 3
	j remove_player	
	
#p
respond_to_p:
	j remove_win
removed_win:
	j remove_lose
removed_lose:
	li $t8, 0x31 
	j respond_to_1

Exit:
 	li $v0, 10 # terminate the program gracefully 
 	syscall 
end_screen:
	li $t9, 0xffff0000  
	lw $t8, 4($t9) # this assumes $t9 is set to 0xfff0000 from before 
	beq $t8, 0x70, respond_to_p   # ASCII code of 'p' is 0x70
	j end_screen

#win screen
respond_to_k:
	li $t8, 0x6b
	li $a3, 4
	j remove_spike
end_r_p_4:
	li $s7, 3
	j remove_player	

#lose screen
respond_to_l:
	li $t8, 0x6c
	li $a3, 5
	j remove_spike
end_r_p_5:
	li $s7, 3
	j remove_player

#win
win:	la $a1, COLOR_FINISH
	li $a2, 11
	j w_start
remove_win:	
	la $a1, COLOR_BLACK
	li $a2, 12
	j w_start
w_start:
	li $a0, BASE_ADDRESS
	addi $a0, $a0, 3920
	j paint_you

#lose screen
lose:	la $a1, COLOR_RED
	li $a2, 01
	j l_start
remove_lose:	
	la $a1, COLOR_BLACK
	li $a2, 02
	j l_start
l_start:
	li $a0, BASE_ADDRESS
	addi $a0, $a0, 3920
	j paint_you
 	
paint_lose:
	# L
	addi $a0, $a0, 2480
	sw $a1,($a0)
	sw $a1, 4($a0)
	
	sw $a1, 256($a0)
	sw $a1, 260($a0)
	
	sw $a1, 512($a0)
	sw $a1, 516($a0)
	
	sw $a1, 768($a0)
	sw $a1, 772($a0)
	
	sw $a1, 1024($a0)
	sw $a1, 1028($a0)
	
	sw $a1, 1280($a0)
	sw $a1, 1284($a0)
	
	sw $a1, 1536($a0)
	sw $a1, 1540($a0)
	sw $a1, 1544($a0)
	sw $a1, 1548($a0)
	sw $a1, 1552($a0)
	sw $a1, 1556($a0)
	
	sw $a1, 1792($a0)
	sw $a1, 1796($a0)
	sw $a1, 1800($a0)
	sw $a1, 1804($a0)
	sw $a1, 1808($a0)
	sw $a1, 1812($a0)
	
	#paint O
	addi $a0, $a0, 32
	sw $a1,($a0)
	sw $a1, 4($a0)
	sw $a1, 8($a0)
	sw $a1, 12($a0)
	sw $a1, 16($a0)
	sw $a1, 20($a0)
	
	sw $a1, 256($a0)
	sw $a1, 260($a0)
	sw $a1, 264($a0)
	sw $a1, 268($a0)
	sw $a1, 272($a0)
	sw $a1, 276($a0)
	
	sw $a1, 512($a0)
	sw $a1, 516($a0)
	sw $a1, 528($a0)
	sw $a1, 532($a0)
	
	sw $a1, 768($a0)
	sw $a1, 772($a0)
	sw $a1, 784($a0)
	sw $a1, 788($a0)
	
	sw $a1, 1024($a0)
	sw $a1, 1028($a0)
	sw $a1, 1040($a0)
	sw $a1, 1044($a0)
	
	sw $a1, 1280($a0)
	sw $a1, 1284($a0)
	sw $a1, 1296($a0)
	sw $a1, 1300($a0)
	
	sw $a1, 1536($a0)
	sw $a1, 1540($a0)
	sw $a1, 1544($a0)
	sw $a1, 1548($a0)
	sw $a1, 1552($a0)
	sw $a1, 1556($a0)
	
	sw $a1, 1792($a0)
	sw $a1, 1796($a0)
	sw $a1, 1800($a0)
	sw $a1, 1804($a0)
	sw $a1, 1808($a0)
	sw $a1, 1812($a0)
	
	#S
	addi $a0, $a0, 32
	sw $a1,($a0)
	sw $a1, 4($a0)
	sw $a1, 8($a0)
	sw $a1, 12($a0)
	sw $a1, 16($a0)
	sw $a1, 20($a0)
	
	sw $a1, 256($a0)
	sw $a1, 260($a0)
	sw $a1, 264($a0)
	sw $a1, 268($a0)
	sw $a1, 272($a0)
	sw $a1, 276($a0)
	
	sw $a1, 512($a0)
	sw $a1, 516($a0)
	
	sw $a1, 768($a0)
	sw $a1, 772($a0)
	sw $a1, 776($a0)
	sw $a1, 780($a0)
	sw $a1, 784($a0)
	
	sw $a1, 1028($a0)
	sw $a1, 1032($a0)
	sw $a1, 1036($a0)
	sw $a1, 1040($a0)
	sw $a1, 1044($a0)
	
	sw $a1, 1296($a0)
	sw $a1, 1300($a0)
	
	sw $a1, 1536($a0)
	sw $a1, 1540($a0)
	sw $a1, 1544($a0)
	sw $a1, 1548($a0)
	sw $a1, 1552($a0)
	sw $a1, 1556($a0)
	
	sw $a1, 1792($a0)
	sw $a1, 1796($a0)
	sw $a1, 1800($a0)
	sw $a1, 1804($a0)
	sw $a1, 1808($a0)
	sw $a1, 1812($a0)
	
	# E
	addi $a0, $a0, 32
	sw $a1,($a0)
	sw $a1, 4($a0)
	sw $a1, 8($a0)
	sw $a1, 12($a0)
	sw $a1, 16($a0)
	sw $a1, 20($a0)
	
	sw $a1, 256($a0)
	sw $a1, 260($a0)
	sw $a1, 264($a0)
	sw $a1, 268($a0)
	sw $a1, 272($a0)
	sw $a1, 276($a0)
	
	sw $a1, 512($a0)
	sw $a1, 516($a0)
	
	sw $a1, 768($a0)
	sw $a1, 772($a0)
	sw $a1, 776($a0)
	sw $a1, 780($a0)
	sw $a1, 784($a0)
	sw $a1, 788($a0)
	
	sw $a1, 1024($a0)
	sw $a1, 1028($a0)
	sw $a1, 1032($a0)
	sw $a1, 1036($a0)
	sw $a1, 1040($a0)
	sw $a1, 1044($a0)
	
	sw $a1, 1280($a0)
	sw $a1, 1284($a0)
	
	sw $a1, 1536($a0)
	sw $a1, 1540($a0)
	sw $a1, 1544($a0)
	sw $a1, 1548($a0)
	sw $a1, 1552($a0)
	sw $a1, 1556($a0)
	
	sw $a1, 1792($a0)
	sw $a1, 1796($a0)
	sw $a1, 1800($a0)
	sw $a1, 1804($a0)
	sw $a1, 1808($a0)
	sw $a1, 1812($a0)
	beq $a2, 02, removed_lose
	j end_screen
	
paint_win:
	#W
	addi $a0, $a0, 2492
	sw $a1,($a0)
	sw $a1, 4($a0)
	sw $a1, 32($a0)
	sw $a1, 36($a0)
	
	
	sw $a1, 256($a0)
	sw $a1, 260($a0)
	sw $a1, 288($a0)
	sw $a1, 292($a0)

	
	sw $a1, 512($a0)
	sw $a1, 516($a0)
	sw $a1, 544($a0)
	sw $a1, 548($a0)
	
	sw $a1, 768($a0)
	sw $a1, 772($a0)
	sw $a1, 784($a0)
	sw $a1, 788($a0)	
	sw $a1, 800($a0)
	sw $a1, 804($a0)
	
	sw $a1, 1024($a0)
	sw $a1, 1028($a0)
	sw $a1, 1040($a0)
	sw $a1, 1044($a0)
	sw $a1, 1056($a0)
	sw $a1, 1060($a0)
	
	sw $a1, 1280($a0)
	sw $a1, 1284($a0)
	sw $a1, 1296($a0)
	sw $a1, 1300($a0)
	sw $a1, 1312($a0)
	sw $a1, 1316($a0)
	
	sw $a1, 1536($a0)
	sw $a1, 1540($a0)
	sw $a1, 1544($a0)
	sw $a1, 1548($a0)
	sw $a1, 1552($a0)
	sw $a1, 1556($a0)
	sw $a1, 1560($a0)
	sw $a1, 1564($a0)
	sw $a1, 1568($a0)
	sw $a1, 1572($a0)
	
	sw $a1, 1792($a0)
	sw $a1, 1796($a0)
	sw $a1, 1800($a0)
	sw $a1, 1804($a0)
	sw $a1, 1808($a0)
	sw $a1, 1812($a0)
	sw $a1, 1816($a0)
	sw $a1, 1820($a0)
	sw $a1, 1824($a0)
	sw $a1, 1828($a0)
	
	#place I
	addi $a0, $a0, 48
	sw $a1,($a0)
	sw $a1, 4($a0)
	
	sw $a1, 256($a0)
	sw $a1, 260($a0)
	
	sw $a1, 512($a0)
	sw $a1, 516($a0)
	
	sw $a1, 768($a0)
	sw $a1, 772($a0)
	
	sw $a1, 1024($a0)
	sw $a1, 1028($a0)
	
	sw $a1, 1280($a0)
	sw $a1, 1284($a0)
	
	sw $a1, 1536($a0)
	sw $a1, 1540($a0)
	
	sw $a1, 1792($a0)
	sw $a1, 1796($a0)
	
	#N
	addi $a0, $a0, 16
	sw $a1,($a0)
	sw $a1, 4($a0)
	sw $a1, 4($a0)
	sw $a1, 24($a0)
	sw $a1, 28($a0)
	
	sw $a1, 256($a0)
	sw $a1, 260($a0)
	sw $a1, 264($a0)
	sw $a1, 280($a0)
	sw $a1, 284($a0)
	
	sw $a1, 512($a0)
	sw $a1, 516($a0)
	sw $a1, 520($a0)
	sw $a1, 524($a0)
	sw $a1, 536($a0)
	sw $a1, 540($a0)
	
	sw $a1, 768($a0)
	sw $a1, 772($a0)
	sw $a1, 776($a0)
	sw $a1, 780($a0)
	sw $a1, 784($a0)
	sw $a1, 792($a0)
	sw $a1, 796($a0)
	
	sw $a1, 1024($a0)
	sw $a1, 1028($a0)
	sw $a1, 1036($a0)
	sw $a1, 1040($a0)
	sw $a1, 1044($a0)
	sw $a1, 1048($a0)
	sw $a1, 1052($a0)
	
	
	sw $a1, 1280($a0)
	sw $a1, 1284($a0)
	sw $a1, 1296($a0)
	sw $a1, 1300($a0)
	sw $a1, 1304($a0)
	sw $a1, 1308($a0)
	
	sw $a1, 1536($a0)
	sw $a1, 1540($a0)
	sw $a1, 1556($a0)
	sw $a1, 1560($a0)
	sw $a1, 1564($a0)
	
	sw $a1, 1792($a0)
	sw $a1, 1796($a0)
	sw $a1, 1816($a0)
	sw $a1, 1820($a0)
	beq $a2, 12, removed_win
	j end_screen
	
paint_you:
	# paint Y
	sw $a1, 0($a0)
	sw $a1, 4($a0)
	sw $a1, 16($a0)
	sw $a1, 20($a0)
	sw $a1, 256($a0)
	sw $a1, 260($a0)
	sw $a1, 272($a0)
	sw $a1, 276($a0)
	sw $a1, 512($a0)
	sw $a1, 516($a0)
	sw $a1, 520($a0)
	sw $a1, 524($a0)
	sw $a1, 528($a0)
	sw $a1, 532($a0)
	sw $a1, 768($a0)
	sw $a1, 772($a0)
	sw $a1, 776($a0)
	sw $a1, 780($a0)
	sw $a1, 784($a0)
	sw $a1, 788($a0)
	sw $a1, 1032($a0)
	sw $a1, 1036($a0)
	sw $a1, 1288($a0)
	sw $a1, 1292($a0)
	sw $a1, 1544($a0)
	sw $a1, 1548($a0)
	sw $a1, 1800($a0)
	sw $a1, 1804($a0)
	
	
	#paint O
	addi $a0, $a0, 32
	sw $a1,($a0)
	sw $a1, 4($a0)
	sw $a1, 8($a0)
	sw $a1, 12($a0)
	sw $a1, 16($a0)
	sw $a1, 20($a0)
	
	sw $a1, 256($a0)
	sw $a1, 260($a0)
	sw $a1, 264($a0)
	sw $a1, 268($a0)
	sw $a1, 272($a0)
	sw $a1, 276($a0)
	
	sw $a1, 512($a0)
	sw $a1, 516($a0)
	sw $a1, 528($a0)
	sw $a1, 532($a0)
	
	sw $a1, 768($a0)
	sw $a1, 772($a0)
	sw $a1, 784($a0)
	sw $a1, 788($a0)
	
	sw $a1, 1024($a0)
	sw $a1, 1028($a0)
	sw $a1, 1040($a0)
	sw $a1, 1044($a0)
	
	sw $a1, 1280($a0)
	sw $a1, 1284($a0)
	sw $a1, 1296($a0)
	sw $a1, 1300($a0)
	
	sw $a1, 1536($a0)
	sw $a1, 1540($a0)
	sw $a1, 1544($a0)
	sw $a1, 1548($a0)
	sw $a1, 1552($a0)
	sw $a1, 1556($a0)
	
	sw $a1, 1792($a0)
	sw $a1, 1796($a0)
	sw $a1, 1800($a0)
	sw $a1, 1804($a0)
	sw $a1, 1808($a0)
	sw $a1, 1812($a0)
	
	#paint U
	addi $a0, $a0, 32
	sw $a1,($a0)
	sw $a1, 4($a0)
	sw $a1, 16($a0)
	sw $a1, 20($a0)
	
	sw $a1, 256($a0)
	sw $a1, 260($a0)
	sw $a1, 272($a0)
	sw $a1, 276($a0)
	
	sw $a1, 512($a0)
	sw $a1, 516($a0)
	sw $a1, 528($a0)
	sw $a1, 532($a0)
	
	sw $a1, 768($a0)
	sw $a1, 772($a0)
	sw $a1, 784($a0)
	sw $a1, 788($a0)
	
	sw $a1, 1024($a0)
	sw $a1, 1028($a0)
	sw $a1, 1040($a0)
	sw $a1, 1044($a0)
	
	sw $a1, 1280($a0)
	sw $a1, 1284($a0)
	sw $a1, 1296($a0)
	sw $a1, 1300($a0)
	
	sw $a1, 1536($a0)
	sw $a1, 1540($a0)
	sw $a1, 1544($a0)
	sw $a1, 1548($a0)
	sw $a1, 1552($a0)
	sw $a1, 1556($a0)
	
	sw $a1, 1792($a0)
	sw $a1, 1796($a0)
	sw $a1, 1800($a0)
	sw $a1, 1804($a0)
	sw $a1, 1808($a0)
	sw $a1, 1812($a0)

	beq $a2, 01, paint_lose
	beq $a2, 02, paint_lose
	j paint_win
