##################################################################### 
# 
# CSCB58 Winter 2023 Assembly Final Project 
# University of Toronto, Scarborough 
# # 
# Bitmap Display Configuration: 
# - Unit width in pixels: 8 
# - Unit height in pixels: 8
# - Display width in pixels: 512
# - Display height in pixels: 512 
# - Base Address for Display: 0x10008000 ($gp) 
# 
# Which milestones have been reached in this submission? 
# - Milestone 3
# 
# Which approved features have been implemented for milestone 3? 
# 1. Health/score [2 marks]
# 2. Fail condition [1 mark] 
# 3. Win condition [1 mark]
# 4. Moving objects [2 mark]
# 5. Different levels [2 marks]
# 6. Double jump [1 mark]
# 
# Link to video demonstration for final submission: 
# - https://play.library.utoronto.ca/watch/abc87be52f016de511732f9e015c2841
# 
# Are you OK with us sharing the video with people outside course staff? 
# - yes
# - https://github.com/AndrewEffendi/Assembly-Platform-Game
# 
# Any additional information that the TA needs to know: 
# - (write here, if any) 
# 
##################################################################### 
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

.eqv	SPIKE_1_1	11952
.eqv	SPIKE_1_2	14204
.eqv	SPIKE_1_3	14220
.eqv	SPIKE_2_1	11176
.eqv	SPIKE_2_2	14184
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
  # t8: previous pressed key
  # t9: jump counter

# ------------------------------------
# initialize program global variable	
reset:	li $s0, 3 	# health
	li $s7, 1 	# level
# ------------------------------------
# initialize global variable for next level
next_level:
 	li $s1, 0 	# player's x-coordinate
 	li $s2, 204 	# player's y-coordinate
 	li $s3, 2 	# double jump
 	li $s4, 0 	# 0 to 40 range
 	li $s5, 0 	# 0 right, 1 left
 	li $s6, 1 	# reset clock to 1
 	li $t9, 0 	# jump counter
 	j paint_ground
# ------------------------------------
# main loop
wait:
 	# Wait for key press
 	li $t0, 0xffff0000  
	lw $t8, 0($t0) 
	beq $t8, 1, keypress_happened 
	
	# every 0.5 got to half_second to update gravity and move monster
	addi $s6, $s6, 1
	beq $s6, 50, half_second 
	
	# Wait 10 milliseconds (60 hz)
	li $v0, 32 
	li $a0, 10    
	syscall 
	j wait
# ------------------------------------
# handle keypresses
keypress_happened :	
	lw $t8, 4($t0) 			# this assumes $t0 is set to 0xfff0000 from before 
	beq $t8, 0x77, respond_to_w   	# ASCII code of 'w' is 0x77 
	beq $t8, 0x61, respond_to_a   	# ASCII code of 'a' is 0x61
	beq $t8, 0x73, respond_to_s   	# ASCII code of 's' is 0x73 
	beq $t8, 0x64, respond_to_d   	# ASCII code of 'd' is 0x64
	beq $t8, 0x70, respond_to_p   	# ASCII code of 'p' is 0x70
	beq $t8, 0x31, respond_to_1   	# ASCII code of '1' is 0x31
	beq $t8, 0x32, respond_to_2   	# ASCII code of '2' is 0x32
	beq $t8, 0x33, respond_to_3   	# ASCII code of '3' is 0x32
	j wait
# ------------------------------------
# w keypress
respond_to_w:
	beq $s3, 0, wait 	# jump not available
	addi $s3, $s3, -1 	# reduce jump
jump_1:	li $t9, 1
	j jump_loop
jump_2: li $t9, 2
	j jump_loop
jump_3: li $t9, 3
	j jump_loop
jump_4: li $t9, 4
	j jump_loop
jump_5: li $t9, 0
	j jump_loop
jump_loop:
	ble $s2, 40, wait
	j collision_check
jump:	addi $s2, $s2, -4 	# y-1
	j move_player
# ------------------------------------
# a keypress
respond_to_a:
	blez $s1, wait
	j collision_check
left:	addi $s1, $s1, -4 	# x-4
	j move_player
# ------------------------------------
# s keypress
respond_to_s:
	bge $s2, 204, wait
	j collision_check
down:	addi $s2, $s2, 4 	# y+4
	j move_player
# ------------------------------------
# d keypress
respond_to_d:
	bge $s1, 236, wait
	j collision_check
right: 	addi $s1, $s1, 4 	# x+4
	j move_player
# ------------------------------------
# move player
move_player:
	jal paint_player
jump_count:
	beq $t9, 1, jump_2
	beq $t9, 2, jump_3
	beq $t9, 3, jump_4
	beq $t9, 4, jump_5
	j finish_check
finished_check:
	bne $t8 0x77, jump_check # w
jump_checked:
	j wait
# ------------------------------------
# p keypress
respond_to_p:
	j remove_win
removed_win:
	j remove_lose
removed_lose:
	li $t8, 0x31 
	j respond_to_1
# ------------------------------------
# 1 keypress
respond_to_1:
	li $s0, 3 # set health to 3
	li $a3, 1
	li $t8, 0x31
	j remove_spike
end_r_p_1:
	li $s7, 1
	jal remove_player
	j next_level
# ------------------------------------
# 2 keypress
respond_to_2:
	li $a3, 2
	li $t8, 0x32
	j remove_spike
end_r_p_2:
	li $s7, 2
	jal remove_player
	j next_level
# ------------------------------------
# 3 keypress	
respond_to_3:
	li $a3, 3
	li $t8, 0x33
	j remove_spike
end_r_p_3:
	li $s7, 3
	jal remove_player
	j next_level	
# ------------------------------------
# what happen every 0.5 seconds
half_second:
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
	j check_move_monster
update_monster:
	li $a3, 0 # not type end_r_p
	j remove_monster
remove_monster_done:
	beqz $s5, move_monster_right
	j move_monster_left 
move_monster_left:
	addi $s4, $s4, -4 # move monster left
	j add_monster
move_monster_right:
	addi $s4, $s4, 4  # move monster right
	j add_monster
move_monster_done:
	li $s6, 1 	# reset clock to 1
	li $t8, 0x73
	j respond_to_s 	#go down once
# ------------------------------------
# Exit
Exit:
 	li $v0, 10 # terminate the program gracefully 
 	syscall 

#####################################################################
#                   Add, remove, paint functions                    #
#####################################################################
# ------------------------------------
# paint ground
paint_ground:
	# $a0: position
	# $a1: colour
	li $a1, COLOR_GROUND
	li $a0, GROUND
	addi $a0, $a0, BASE_ADDRESS
    	li $t0, 0
loop_ground:
	bge $t0, 256, add_spike
	li $t1, 4	  # 4 bytes
	mul $t1, $t1, $t0 # offset = 4 bytes * index
	add $t1, $t1, $a0 # t1 = address + offset
	sw $a1, ($t1)
    	addi $t0, $t0, 1
    	j loop_ground
# ------------------------------------
# add or remove spike
add_spike:
	li $a3,0 # indicate not remove_spike	
	li $a1, COLOR_SPIKE
	j s_skip
remove_spike:
	li $a1, COLOR_BLACK
s_skip: beq $s7, 2, spike_lvl_2
	beq $s7, 3, spike_lvl_3
spike_lvl_1:
	li $a0, SPIKE_1_1
	jal paint_spike
	li $a0, SPIKE_1_2
	jal paint_spike
	li $a0, SPIKE_1_3
	jal paint_spike
	j paint_spike_done
spike_lvl_2:
	li $a0, SPIKE_2_1
	jal paint_spike
	li $a0, SPIKE_2_2
	jal paint_spike
	j paint_spike_done
spike_lvl_3:
	li $a0, SPIKE_3_1
	jal paint_spike
	li $a0, SPIKE_3_2
	jal paint_spike
	j paint_spike_done
paint_spike:
	# $a0: position
	# $a1: colour
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
	jr $ra
paint_spike_done:
	bnez $a3, remove_platform
	j add_platform
# ------------------------------------
# add or remove platform
add_platform: 
	li $a3,0 # indicate not remove_platform
	li $a1, COLOR_PLATFORM
	j p_skip
remove_platform:
	li $a1, COLOR_BLACK
p_skip:	beq $s7, 2, platform_lvl_2
	beq $s7, 3, platform_lvl_3
platform_lvl_1:
	li $a0, PLATFORM_1_1
	jal paint_platform
	li $a0, PLATFORM_1_2
	jal paint_platform
	j paint_platform_done
platform_lvl_2:
	li $a0, PLATFORM_2_1
	jal paint_platform
	li $a0, PLATFORM_2_2
	jal paint_platform
	j paint_platform_done
platform_lvl_3:
	li $a0, PLATFORM_3_1
	jal paint_platform
	li $a0, PLATFORM_3_2
	jal paint_platform
	li $a0, PLATFORM_3_3
	jal paint_platform
	li $a0, PLATFORM_3_4
	jal paint_platform
	li $a0, PLATFORM_3_5
	jal paint_platform
	j paint_platform_done
paint_platform:
	# $a0: position
	# $a1: colour
	# $a3 remove calling level
	addi $a0, $a0, BASE_ADDRESS
    	li $t0, 0 # init t0 = 0
loop_platform:
	bge $t0, 15, end_loop_p
	li $t1, 4 	  # 4 bytes
	mul $t1, $t1, $t0 # offset = 4 bytes * index
	add $t1, $t1, $a0 # t1 = address + offset
	sw $a1, ($t1)
    	addi $t0, $t0, 1
    	j loop_platform
end_loop_p:
	jr $ra
paint_platform_done:
	bnez $a3, remove_monster
	j add_monster
# ------------------------------------
# add or remove monster
add_monster:
	li $a3,0 	# $a3: remove calling function, monster not remove
	li $a1, COLOR_MONSTER
	j m_skip
remove_monster:
	li $a1, COLOR_BLACK
m_skip:	beq $s7, 2, monster_lvl_2
	beq $s7, 3, monster_lvl_3
monster_lvl_1:
	j paint_monster_done # no monster for level 1
monster_lvl_2:
	li $a0, MONSTER_2_1
	add $a0, $a0, $s4
	jal paint_monster
	li $a0, MONSTER_2_2
	add $a0, $a0, $s4
	jal paint_monster
	j paint_monster_done
monster_lvl_3:
	li $a0, MONSTER_3_1
	add $a0, $a0, $s4
	jal paint_monster
	li $a0, MONSTER_3_2
	add $a0, $a0, $s4
	jal paint_monster
	li $a0, MONSTER_3_3
	add $a0, $a0, $s4
	jal paint_monster
	j paint_monster_done
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
	beqz $a3, red_eyes
	jr $ra
red_eyes:
	li $t0, COLOR_RED
	sw $t0, 260($a0)
	sw $t0, 268($a0)
	sw $t0, 772($a0)
	sw $t0, 776($a0)
	sw $t0, 780($a0)
	jr $ra
paint_monster_done:
	beq $a3, 1, end_r_p_1
	beq $a3, 2, end_r_p_2
	beq $a3, 3, end_r_p_3
	beq $a3, 4, end_r_p_4
	beq $a3, 5, end_r_p_5
	beqz $s6, move_monster_next 	# move monster
	j add_finish_line
move_monster_next:	
	li $t0, COLOR_BLACK	
	beq $a1, $t0 , remove_monster_done	
	j move_monster_done
# ------------------------------------
# add finish line
add_finish_line:
	li $a1, COLOR_FINISH
	beq $s7, 2, finish_lvl_2
	beq $s7, 3, finish_lvl_3
finish_lvl_1:
	li $a0, FINISH_1
	j paint_finish_line
finish_lvl_2:
	li $a0, FINISH_2
	j paint_finish_line
finish_lvl_3:
	li $a0, FINISH_3
	j paint_finish_line
paint_finish_line:
	# $a0: position
	# $a1: colour
	addi $a0, $a0, BASE_ADDRESS
	sw $a1, ($a0)
	sw $a1, 4($a0)
	sw $a1, 8($a0)
	sw $a1, 12($a0)
	sw $a1, 16($a0)
	sw $a1, 20($a0)
	j add_health
# ------------------------------------
# add health
add_health:	
	li, $a1, COLOR_HEALTH
	li, $a0, HEALTH_1
	jal paint_health
h_2:	blt $s0, 2, add_health_done #if health less than 2 don't paint
	li, $a0, HEALTH_2
	jal paint_health
h_3:	blt $s0, 3, add_health_done #if health less than 3 don't paint
	li, $a0, HEALTH_3
	jal paint_health
add_health_done:
	jal paint_player
	j wait
# remove health	
remove_health:
	li, $a1, COLOR_BLACK
	beq $s0, 3, rh_3
	beq $s0, 2, rh_2
	beq $s0, 1, rh_1
	j lose_screen
rh_3:	li, $a0, HEALTH_3
	jal paint_health
	j damage_player
rh_2:	li, $a0, HEALTH_2
	jal paint_health
	j damage_player
rh_1:	li, $a0, HEALTH_1
	jal paint_health
	j lose_screen
# paint health	
paint_health:
	# $a0: position
	# $a1: colour
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
	jr $ra
# ------------------------------------
# paint player	
paint_player:
	li $t0, 64 	  	# t0 = 64
	mul $t0, $t0, $s2 	# t0 = 64*y
	add $t0, $s1, $t0 	# t0 = x + 64*y
	addi $t0, $t0, BASE_ADDRESS
	li $t1, COLOR_RED
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 1028($t0)
	sw $t1, 1036($t0)
	li $t1, COLOR_CREAM
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	sw $t1, 772($t0)
	sw $t1, 776($t0)
	sw $t1, 780($t0)
	sw $t1, 1024($t0)
	sw $t1, 1040($t0)
	sw $t1, 2052($t0)
	sw $t1, 2060($t0)
	li $t1, COLOR_BLUE
	sw $t1, 1032($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1540($t0)
	sw $t1, 1544($t0)
	sw $t1, 1548($t0)
	sw $t1, 1796($t0)
	sw $t1, 1800($t0)
	sw $t1, 1804($t0)
	jr $ra
# ------------------------------------
# remove player	
remove_player:
	li $t0, 64 	  	# t0 = 64
	mul $t0, $t0, $s2 	# t0 = 64*y
	add $t0, $s1, $t0 	# t0 = x + 64*y
	addi $t0, $t0, BASE_ADDRESS
	li $t1, COLOR_BLACK
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	sw $t1, 772($t0)
	sw $t1, 776($t0)
	sw $t1, 780($t0)
	sw $t1, 1024($t0)
	sw $t1, 1040($t0)
	sw $t1, 2052($t0)
	sw $t1, 2060($t0)
	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1540($t0)
	sw $t1, 1544($t0)
	sw $t1, 1548($t0)
	sw $t1, 1796($t0)
	sw $t1, 1800($t0)
	sw $t1, 1804($t0)
	jr $ra
# ------------------------------------
# damage player	
damage_player:
	li $t0, 64 	  	# t0 = 64
	mul $t0, $t0, $s2 	# t0 = 64*y
	add $t0, $s1, $t0 	# t0 = x + 64*y
	addi $t0, $t0, BASE_ADDRESS
	li $t1, COLOR_RED
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 1028($t0)
	sw $t1, 1036($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	sw $t1, 772($t0)
	sw $t1, 776($t0)
	sw $t1, 780($t0)
	sw $t1, 1024($t0)
	sw $t1, 1040($t0)
	sw $t1, 2052($t0)
	sw $t1, 2060($t0)
	sw $t1, 1032($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1540($t0)
	sw $t1, 1544($t0)
	sw $t1, 1548($t0)
	sw $t1, 1796($t0)
	sw $t1, 1800($t0)
	sw $t1, 1804($t0)
	li $v0, 32 
	li $a0, 100   		# Wait 100 milliseconds 
	syscall 
	jal paint_player
	addi $s0, $s0, -1 	# reduced health by 1
	beqz $s6, move_monster_done
	j wait

#####################################################################
#             check collisions and movements functions              #
#####################################################################
# ------------------------------------
# check monster movement
check_move_monster:
	# player location
	li $a0, 64 	  	# a0 = 64
	mul $a0, $a0, $s2 	# a0 = 64*y
	add $a0, $s1, $a0 	# a0 = x + 64*y
	beqz $s5, check_move_monster_right
	j check_move_monster_left
check_move_monster_left:
	addi $a0, $a0, 1044 	# 4*256 (down) down + 5 *4 (right)
	j cmm_start
check_move_monster_right:
	addi $a0, $a0, 1004 	# 4*256 (down) down + -5*4 (left)
	j cmm_start
cmm_start:
	beq $s7, 2, monster_move_check_2
	beq $s7, 3, monster_move_check_3
	j update_monster
monster_move_check_2:
	li $a1, MONSTER_2_1
	jal check_mm
	li $a1, MONSTER_2_2
	jal check_mm
	j update_monster
monster_move_check_3:
	li $a1, MONSTER_3_1
	jal check_mm
	li $a1, MONSTER_3_2
	jal check_mm
	li $a1, MONSTER_3_3
	jal check_mm
	j update_monster
check_mm:
	add $t0, $a1, $s4
	beq $a0, $t0, remove_health
	addi $t0, $t0, -256 #move monster up
	beq $a0, $t0, remove_health
	addi $t0, $t0, -256 #move monster up
	beq $a0, $t0, remove_health
	addi $t0, $t0, -256 #move monster up
	beq $a0, $t0, remove_health
	addi $t0, $t0, -256 #move monster up
	beq $a0, $t0, remove_health
	jr $ra
# ------------------------------------
# check double jump	
jump_check:
	# player location
	li $a0, 64 	  	# a0 = 64
	mul $a0, $a0, $s2 	# a0 = 64*y
	add $a0, $s1, $a0 	# a0 = x + 64*y
	addi $a0, $a0, 2308 	# 9*256 (down) + 1*4 (right)
# check double jump ground
jump_check_ground:
	li $t2, GROUND
    	li $t0, 0
loop_jcg:
	bge $t0, 64, end_loop_jcg
	li $t1, 4	  	# 4 bytes
	mul $t1, $t1, $t0 	# offset = 4 bytes * index
	add $t1, $t1, $t2 	# t1 = address + offset
	beq $t1, $a0 double_jump_reset
    	addi $t0, $t0, 1
    	j loop_jcg
end_loop_jcg:
	beq $s7, 1, jump_check_1
	beq $s7, 2, jump_check_2
	j jump_check_3
# check double jump platform
jump_check_1:
	li $a1, PLATFORM_1_1
	jal jump_check_patform
	li $a1, PLATFORM_1_2
	jal jump_check_patform
	j jump_checked
jump_check_2:
	li $a1, PLATFORM_2_1 
	jal jump_check_patform
	li $a1, PLATFORM_2_2
	jal jump_check_patform
	j jump_checked
jump_check_3:
	li $a1, PLATFORM_3_1 
	jal jump_check_patform
	li $a1, PLATFORM_3_2
	jal jump_check_patform
	li $a1, PLATFORM_3_3 
	jal jump_check_patform
	li $a1, PLATFORM_3_4
	jal jump_check_patform
	li $a1, PLATFORM_3_5 
	jal jump_check_patform
	j jump_checked
jump_check_patform:
	li $t0, -2 		# init t0 = 0
loop_jcp:
	bge $t0, 15, end_loop_jcp
	li $t1, 4	  	# 4 bytes
	mul $t1, $t1, $t0 	# offset = 4 bytes * index
	add $t1, $t1, $a1 	# t1 = address + offset
	beq $t1, $a0 double_jump_reset
    	addi $t0, $t0, 1
    	j loop_jcp
end_loop_jcp:
	jr $ra
double_jump_reset:
	li $s3, 2
	j jump_checked
# ------------------------------------
# check player at finish line
finish_check:
	# player location
	li $a0, 64 	  	# a0 = 64
	mul $a0, $a0, $s2 	# a0 = 64*y
	add $a0, $s1, $a0 	# a0 = x + 64*y
	addi $a0, $a0, 2308 	# 9*256 (down) + 1*4 (right)
	beq $s7, 1, finish_check_1
	beq $s7, 2, finish_check_2
	j finish_check_3
	j finished_check
finish_check_1:
	li $t2, FINISH_1
	beq $a0, $t2, respond_to_2
	addi $t2, $t2, 4
	beq $a0, $t2, respond_to_2
	addi $t2, $t2, 4
	beq $a0, $t2, respond_to_2
	addi $t2, $t2, 4
	beq $a0, $t2, respond_to_2
	j finished_check
finish_check_2:
	li $t2, FINISH_2
	beq $a0, $t2, respond_to_3
	addi $t2, $t2, 4
	beq $a0, $t2, respond_to_3
	addi $t2, $t2, 4
	beq $a0, $t2, respond_to_3
	addi $t2, $t2, 4
	beq $a0, $t2, respond_to_3
	j finished_check
finish_check_3:
	li $t2, FINISH_3
	beq $a0, $t2, win_screen
	addi $t2, $t2, 4
	beq $a0, $t2, win_screen
	addi $t2, $t2, 4
	beq $a0, $t2, win_screen
	addi $t2, $t2, 4
	beq $a0, $t2, win_screen
	j finished_check
# ------------------------------------
# check platform collision
platform_check:
	beq $s7, 1, platform_check_1
	beq $s7, 2, platform_check_2
	j platform_check_3
platform_check_1:
	li $a1, PLATFORM_1_1 
	jal check_mtp
	li $a1, PLATFORM_1_2
	jal check_mtp
	j platform_checked
platform_check_2:
	li $a1, PLATFORM_2_1 
	jal check_mtp
	li $a1, PLATFORM_2_2
	jal check_mtp
	j platform_checked
platform_check_3:
	li $a1, PLATFORM_3_1 
	jal check_mtp
	li $a1, PLATFORM_3_2
	jal check_mtp
	li $a1, PLATFORM_3_3 
	jal check_mtp
	li $a1, PLATFORM_3_4
	jal check_mtp
	li $a1, PLATFORM_3_5 
	jal check_mtp
	j platform_checked
platform_checked:
	jal remove_player
	beq $t8, 0x77, jump   	# ASCII code of 'w' is 0x77 
	beq $t8, 0x61, left   	# ASCII code of 'a' is 0x61
	beq $t8, 0x73, down  	# ASCII code of 's' is 0x73 
	beq $t8, 0x64, right   	# ASCII code of 'd' is 0x64
# check movement type
check_mtp:
	li $a0, 64 	  		# a0 = 64
	mul $a0, $a0, $s2 		# a0 = 64*y
	add $a0, $s1, $a0 		# a0 = x + 64*y
	addi $a0, $a0, BASE_ADDRESS 	# a0 = base + offset
	beq $t8, 0x77, wp_offset   # ASCII code of 'w' is 0x77
	beq $t8, 0x61, ap_offset   # ASCII code of 'a' is 0x61
	beq $t8, 0x73, sp_offset   # ASCII code of 's' is 0x73 
	j dp_offset
# offset for each movement type
wp_offset:
	addi $a0, $a0, -244  	# 1*256 (up) + 1*3 (right)
	j horizontal_p_check
ap_offset:
	addi $a0, $a0, 1988  	# 8*256 (down) + -15*4 (left)
	j vertical_p_check
dp_offset:
	addi $a0, $a0, 2068  	# 8*256 (down) + 5*4 (right)
	j vertical_p_check
sp_offset:
	addi $a0, $a0, 2316  	# 9*256 (down) + 3*4 (right)
	j horizontal_p_check
# vertical (y -axis) platform collision check
vertical_p_check:
	addi $a1, $a1, BASE_ADDRESS
	li $t1, 0
loop_vpc:
	bge $t1, 9, end_loop_vpc
	beq $a1, $a0, wait
	addi $a1, $a1, 256
    	addi $t1, $t1, 1
    	j loop_vpc
end_loop_vpc:
	jr $ra
# horizontal (x -axis) platform collision check
horizontal_p_check:
	addi $a1, $a1,-4 	# shift left once
	addi $a1, $a1, BASE_ADDRESS
	bge $a0, $a1, hcp_and
	j end_hcp
hcp_and:
	addi $a1, $a1, 72
	ble $a0, $a1, wait
end_hcp:
	jr $ra
# ------------------------------------
# check monster and spike collision	
collision_check:
	beq $s7, 1, collision_check_1
	beq $s7, 2, collision_check_2
	j collision_check_3
# check collission for lvl 1
collision_check_1:
	li $a1, SPIKE_1_1 
	jal check_mt
	li $a1, SPIKE_1_2
	jal check_mt
	li $a1, SPIKE_1_3
	jal check_mt
	j platform_check
#check collision for level 2
collision_check_2:
	li $a1, SPIKE_2_1 
	jal check_mt
	li $a1, SPIKE_2_2
	jal check_mt
	li $a1, MONSTER_2_1
	add $a1, $a1, $s4
	jal check_mt
	li $a1, MONSTER_2_2
	add $a1, $a1, $s4
	jal check_mt
	j platform_check
#check collision for level 3
collision_check_3:
	li $a1, SPIKE_3_1 
	jal check_mt
	li $a1, SPIKE_3_2
	jal check_mt
	li $a1, MONSTER_3_1
	add $a1, $a1, $s4
	jal check_mt
	li $a1, MONSTER_3_2
	add $a1, $a1, $s4
	jal check_mt
	li $a1, MONSTER_3_3
	add $a1, $a1, $s4
	jal check_mt
	j platform_check
#check movement type
check_mt:
	li $a0, 64 	  		# a0 = 64
	mul $a0, $a0, $s2 		# a0 = 64*y
	add $a0, $s1, $a0 		# a0 = x + 64*y
	addi $a0, $a0, BASE_ADDRESS 	# a0 = base + offset
	beq $t8, 0x61, a_offset   # ASCII code of 'a' is 0x61
	beq $t8, 0x73, s_offset   # ASCII code of 's' is 0x7
	beq $t8, 0x64, d_offset   # ASCII code of 'd' is 0x643 
	j platform_check
# set offset for different movement type
a_offset:
	addi $a0, $a0, 2028  	# 8*256 (down) + -5*4 (left)
	j vertical_check
d_offset:
	addi $a0, $a0, 2068  	# 8*256 (down) + 5*4 (right)
	j vertical_check
s_offset:
	addi $a0, $a0, 2316  	# 9*256 (down) + 3*4 (right)
	j horizontal_check
# vertical (y -axis) platform collision check	
vertical_check:
	addi $a1, $a1, BASE_ADDRESS
	li $t1, 0
loop_vc:
	bge $t1, 5, end_loop_vc
	# here damage
	beq $a1, $a0, remove_health
	addi $a1, $a1, 256
    	addi $t1, $t1, 1
    	j loop_vc
end_loop_vc:
	jr $ra
# horizontal (x -axis) platform collision check	
horizontal_check:
	addi $a1, $a1,-4 #shift left once
	add $a1, $a1, BASE_ADDRESS
	bge $a0, $a1, hc_and
	j end_hc
hc_and: 
	addi $a1, $a1, 32
	# here damage
	ble $a0, $a1, remove_health
end_hc:
	jr $ra
	
#####################################################################
#                       Win / Lose End Screen                       #
#####################################################################
# ------------------------------------
# end screen wait for player to press p to restart
end_screen:
	li $t0, 0xffff0000  
	lw $t8, 4($t0) 			# this assumes $t0 is set to 0xfff0000 from before 
	beq $t8, 0x70, respond_to_p   	# ASCII code of 'p' is 0x70
	j end_screen
# ------------------------------------
# win end screen 
win_screen:
	li $t8, 0x6b
	li $a3, 4
	j remove_spike
end_r_p_4:
	li $s7, 3
	jal remove_player
	j win	
# lose end screen 
lose_screen:
	li $t8, 0x6c
	li $a3, 5
	j remove_spike
end_r_p_5:
	li $s7, 3
	jal remove_player
	j lose
# ------------------------------------
# paint win
win:	li $a1, COLOR_FINISH
	li $a2, 11
	j wl_start
# remove win
remove_win:	
	li $a1, COLOR_BLACK
	li $a2, 12
	j wl_start
# paint lose
lose:	li $a1, COLOR_RED
	li $a2, 01
	j wl_start
# remove lose
remove_lose:	
	li $a1, COLOR_BLACK
	li $a2, 02
	j wl_start
# ------------------------------------
# start painting end screen message
wl_start:
	li $a0, BASE_ADDRESS
	addi $a0, $a0, 3152
	j paint_you
# ------------------------------------
# paint 'YOU'	
paint_you:
	jal paint_big_Y
	addi $a0, $a0, 32
	jal paint_big_O
	addi $a0, $a0, 32
	jal paint_big_U
	beq $a2, 01, paint_lose
	beq $a2, 02, paint_lose
	j paint_win
# ------------------------------------
# paint 'LOSE'	
paint_lose:
	addi $a0, $a0, 2480
	jal paint_big_L
	addi $a0, $a0, 32
	jal paint_big_O
	addi $a0, $a0, 32
	jal paint_big_S
	addi $a0, $a0, 32
	jal paint_big_E
	j press_p_to_restart
# ------------------------------------
# paint 'WIN'	
paint_win:
	# paint 'W'
	addi $a0, $a0, 2492
	jal paint_big_W
	# paint 'I'
	addi $a0, $a0, 48
	jal paint_big_I
	# paint 'N'
	addi $a0, $a0, 16
	jal paint_big_N
	j press_p_to_restart
# ------------------------------------
# paint press p to restart	
press_p_to_restart:
	beq $a2, 01, restart_lose
	beq $a2, 02, restart_lose
	j restart_win
restart_win:
	addi $a0, $a0, 2988
	j pptr_start
restart_lose:
	addi $a0, $a0, 2964
	j pptr_start
pptr_start:
	jal paint_P
	addi $a0, $a0, 16
	jal paint_R
	addi $a0, $a0, 16
	jal paint_E
	addi $a0, $a0, 16
	jal paint_S
	addi $a0, $a0, 16
	jal paint_S
	
	addi $a0, $a0, 24
	jal paint_P
	
	addi $a0, $a0, 24
	jal paint_T
	addi $a0, $a0, 16
	jal paint_O
	
	addi $a0, $a0, 1936
	jal paint_R
	addi $a0, $a0, 16
	jal paint_E
	addi $a0, $a0, 16
	jal paint_S
	addi $a0, $a0, 16
	jal paint_T
	addi $a0, $a0, 16
	jal paint_A
	addi $a0, $a0, 16
	jal paint_R
	addi $a0, $a0, 16
	jal paint_T
	
	beq $a2, 02, removed_lose
	beq $a2, 12, removed_win
	j end_screen
# ------------------------------------
# paint big letters
# $a0: position
# $a1: colour
paint_big_E:
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
	jr $ra
paint_big_I:
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
	jr $ra
 paint_big_L:
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
	jr $ra	
paint_big_N:
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
	jr $ra
 paint_big_O:
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
	jr $ra	
paint_big_S:
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
	jr $ra
 paint_big_U:
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
	jr $ra
paint_big_W:
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
	jr $ra
 paint_big_Y:
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
	jr $ra
# ------------------------------------
# paint small letters
# $a0: position
# $a1: colour
paint_A:
	sw $a1,($a0)
	sw $a1, 4($a0)
	sw $a1, 8($a0)
	sw $a1, 256($a0)
	sw $a1, 264($a0)
	sw $a1, 512($a0)
	sw $a1, 516($a0)
	sw $a1, 520($a0)
	sw $a1, 768($a0)
	sw $a1, 776($a0)
	sw $a1, 1024($a0)
	sw $a1, 1032($a0)
	jr $ra	
paint_E:
	sw $a1,($a0)
	sw $a1, 4($a0)
	sw $a1, 8($a0)
	sw $a1, 256($a0)
	sw $a1, 512($a0)
	sw $a1, 516($a0)
	sw $a1, 520($a0)
	sw $a1, 768($a0)
	sw $a1, 1024($a0)
	sw $a1, 1028($a0)
	sw $a1, 1032($a0)
	jr $ra
paint_O:
	sw $a1,($a0)
	sw $a1, 4($a0)
	sw $a1, 8($a0)
	sw $a1, 256($a0)
	sw $a1, 264($a0)
	sw $a1, 512($a0)
	sw $a1, 520($a0)
	sw $a1, 768($a0)
	sw $a1, 776($a0)
	sw $a1, 1024($a0)
	sw $a1, 1028($a0)
	sw $a1, 1032($a0)
	jr $ra
paint_P:
	sw $a1,($a0)
	sw $a1, 4($a0)
	sw $a1, 8($a0)
	sw $a1, 256($a0)
	sw $a1, 264($a0)
	sw $a1, 512($a0)
	sw $a1, 516($a0)
	sw $a1, 520($a0)
	sw $a1, 768($a0)
	sw $a1, 1024($a0)
	jr $ra
paint_R:
	sw $a1,($a0)
	sw $a1, 4($a0)
	sw $a1, 8($a0)
	sw $a1, 256($a0)
	sw $a1, 264($a0)
	sw $a1, 512($a0)
	sw $a1, 516($a0)
	sw $a1, 520($a0)
	sw $a1, 768($a0)
	sw $a1, 772($a0)
	sw $a1, 1024($a0)
	sw $a1, 1032($a0)
	jr $ra
paint_S:
	sw $a1,($a0)
	sw $a1, 4($a0)
	sw $a1, 8($a0)
	sw $a1, 256($a0)
	sw $a1, 512($a0)
	sw $a1, 516($a0)
	sw $a1, 520($a0)
	sw $a1, 776($a0)
	sw $a1, 1024($a0)
	sw $a1, 1028($a0)
	sw $a1, 1032($a0)
	jr $ra
paint_T:
	sw $a1,($a0)
	sw $a1, 4($a0)
	sw $a1, 8($a0)
	sw $a1, 260($a0)
	sw $a1, 516($a0)
	sw $a1, 772($a0)
	sw $a1, 1028($a0)
	jr $ra
