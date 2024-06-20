class_name CombatHandler2
extends Node

# time it takes for 1 attack animation
const TWEEN_ATTACK_TIME := 0.5
# An attacker will move this percentage of the distance twoards it's target when attacking
const TWEEN_MOVE_PERCENT := 0.75


@onready var player_field: PlayerField = %PlayerField as PlayerField
@onready var enemy_field: EnemyField = %EnemyField as EnemyField
@onready var combat_log: Label = %CombatLog
@onready var player_commander = %PlayerCommander
@onready var enemy_commander = %EnemyCommander
# @onready var player_gy = %PlayerGY
@onready var player_gy = player_commander.get_node("PlayerGY")
@onready var enemy_gy = enemy_commander.get_node("EnemyGY")

# signal the next attack is ready
signal next_attack_ready

# signal that current moving animation is finished
signal animation_finished

# This var is used when a minion attacks and needs to return to it's original positoin
# set in tween of move_to_target() and used by move_back()
var return_position: Vector2
# this has a limitation of only allowing 1 attack animation at a time, but I think that's ok for now


# flag that keeps track of who is next to attack. True for player, false for enemy
var player_attacks_next: bool

# flags that keep track of if there are minions that are waiting to attack
# changing these to funcs that return a bool instead, so I know it will always be updated when used
#var player_has_attackers: bool
#var enemy_has_attackers: bool

# arrays of minions on field
var player_minions: Array
var enemy_minions: Array

# var that holds the next attacker. It will be either a CardUI or EnemyCardUI
# we should make sure anything assinged to this is 1 of those 2 types
# the next_attacker can also be null to represent an "empty attack"
# e.g. it's the enemy's turn to attack but they have no minion
var next_attacker: Variant

# var that holds the next target of next attack. It will be either a CardUI or EnemyCardUI
# we should make sure anything assinged to this is 1 of those 2 types
var next_target: Variant


# func that will be called by Battle node at start of combat.
func combat_started() -> void:
	
	# For the first attack, we call the func to randomly choose who goes first
	player_attacks_next = choose_who_has_first_attack()
	
	# update the arrays of minions
	update_minion_arrays()
	
	# at the start of a round of combat, set everyone's can_attack back to true
	set_everyone_can_attack()
	
	# main loop continues while minions are waiting to attack
	while player_has_attackers() or enemy_has_attackers():
		
		# pick the next minion to attack.
		pick_next_attacker()
		# if the next attacker got set to null, it's an empty attack, go to next iteration of loop
		if next_attacker == null:
			continue
		
		# if there is a target for the attacker, pick a target
		if attacker_has_valid_target():
			pick_next_target()
			# now, next_attacker is ready to fight next_target
		# if there is no valid target, the attacker will attack commander
		else:
			# animate the attacker moving to commander
			if next_attacker is CardUI:
				move_to_target(next_attacker, enemy_commander)
			elif next_attacker is EnemyCardUI:
				move_to_target(next_attacker, player_commander)
			# wait for animation finished signal
			await animation_finished
			# damage to commander
			attack_commander()
			# move the atttacker back
			move_back(next_attacker)
			await animation_finished
			# no target, so go to next loop
			continue
		
		# call the func to animate the attacker moving to target
		move_to_target(next_attacker, next_target)
		
		# wait for the signal that the animation finished
		await animation_finished
		
		# call the func to calculate the damage dealt in the fight
		calculate_damage(next_attacker, next_target)
		
		# 2 vars checking if the hp dropped below 0
		var next_attacker_alive = (next_attacker.health > 0)
		var next_target_alive = (next_target.health > 0)
		
		# match statement to handle the cases resulting from damage
		match [next_attacker_alive, next_target_alive]:
			[true, true]:
				move_back(next_attacker)
				await animation_finished
			[true, false]:
				move_back(next_attacker)
				send_to_graveyard(next_target)
				# await animation_finished
				await Events.reposition_complete
				await animation_finished
			[false, true]:
				send_to_graveyard(next_attacker)
				await Events.reposition_complete
			[false, false]:
				send_to_graveyard(next_attacker)
				send_to_graveyard(next_target)
				await Events.reposition_complete
	
	
	# after all that jazz, emit the signal that combat is over back to the battle node
	Events.combat_phase_ended.emit()
	# hope this works xD



# at the start of a round of combat, set everyone's can_attack back to true
func set_everyone_can_attack() -> void:
	# we should be able to use the minion arrays for this
	for minion in player_minions:
		minion.can_attack = true
	
	for minion in enemy_minions:
		minion.can_attack = true



# func that will decide if a player or enemys minion will be next attacker
# output of this func is stored in member var next_attacker
func pick_next_attacker() -> void:
	# pick a player minion on their turn and they have attackers
	if player_attacks_next && player_has_attackers():
		next_attacker = pick_player_attacker()
	
	elif !player_attacks_next && enemy_has_attackers():
		
		next_attacker = pick_enemy_attacker()
	# else is called e.g. enemy's turn to attack but they have no minions.
	else:
		print("pick_next_attacker found no attacker.")
		# set the next attacker to null. This will represent an "empty attack" in the loop.
		next_attacker = null
	
	# invert the player_attacks_next flag, to prepare for next loop
	player_attacks_next = !player_attacks_next


# func to pick a minion from the players field that will attack next. Returns the CardUI
func pick_player_attacker() -> CardUI:
	# loop through the player minions until the first minion that can attack is found
	for minion in player_minions:
		if minion.can_attack == true:
			return minion
		
	# if we didn't find an attacker in there, oops
	print("pick_player_attacker didn't find a valid attacker!")
	return null


# func to pick a minion from the enemys field that will attack next
func pick_enemy_attacker() -> EnemyCardUI:
	# loop through the player minions until the first minion that can attack is found
	for minion in enemy_minions:
		if minion.can_attack == true:
			return minion
		
	# if we didn't find an attacker in there, oops
	print("pick_enemy_attacker didn't find a valid attacker!")
	return null


# func to update the arrays of minions on field. should be called anytime mininos can die, prior to selecting targets.
func update_minion_arrays() -> void:
	
	player_minions = player_field.get_children()
	enemy_minions = enemy_field.get_children()
	
	# perform a safety check to remove any unexpected data from the arrays
	for m in player_minions:
		if not m is CardUI:
			print("update_minion_arrays found an error: " + str(m) + " is in player_minions array.")
			print("type: " + str(typeof(m)))
			print("removing it from array.")
			player_minions.erase(m)
	
	for m in enemy_minions:
		if not m is EnemyCardUI:
			print("update_minion_arrays found an error: " + str(m) + " is in enemy_minions array.")
			print("type: " + str(typeof(m)))
			print("removing it from array.")
			enemy_minions.erase(m)


# func to pick next target of attack, based on who is attacking.
func pick_next_target() -> void:
	# double check there is a valid target.
	if !attacker_has_valid_target():
		print("pick_next_target failed: no valid target. func should not have been called.")
		return
	# if player minion is attacking,
	if next_attacker is CardUI:
		# get the index of a random minion on enemy field
		var index = randi_range(0, enemy_minions.size() - 1)
		# assign the minion at that index as target
		next_target = enemy_minions[index]
	# if enemy minion is attacking,
	elif next_attacker is EnemyCardUI:
		# get the index of a random minion on enemy field
		var index = randi_range(0, player_minions.size() - 1)
		# assign the minion at that index as target
		next_target = player_minions[index]
	# else, the next_attacker is an unexpected type
	else:
		print("pick_next_target failed: next_attacker is unexpected type: " + str(typeof(next_attacker)))


# we should only run the above pick_next_target func if the attacker has some valid choice
# func to decide if that is the case
# this will return that as a bool
func attacker_has_valid_target() -> bool:
	# true if player attacker and enemy has minions
	if next_attacker is CardUI && !enemy_minions.is_empty():
		return true
	# true if enemy attacker and player has minions
	elif next_attacker is EnemyCardUI && !player_minions.is_empty():
		return true
	# false in other cases, which should mean the attacker hits commander
	else:
		# debug print
		print("attacker_has_valid_target returned false")
		return false 


# func that checks if any of the players minions can attack.
func player_has_attackers() -> bool:
	# first, make sure the array is up to date.
	update_minion_arrays()
	
	# loop through player minions, return true once one that can attack is found
	for minion in player_minions:
		if minion.can_attack:
			return true
	
	# otherwise, return false. debug print
	print("player_has_attackers returned false.")
	return false


# func that checks if any of the enemys minions can attack.
func enemy_has_attackers() -> bool:
	# first, make sure the array is up to date.
	update_minion_arrays()
	
	# loop through player minions, return true once one that can attack is found
	for minion in enemy_minions:
		if minion.can_attack:
			return true
	
	# otherwise, return false. debug print
	print("enemy_has_attackers returned false.")
	return false


# this func randomly chooses who attacks for the very first attack.
# it returns true for player, false for enemy
func choose_who_has_first_attack() -> bool:
	var random_choice = randi_range(0, 1)
	if random_choice == 0:
		return true
	else:
		return false


# this func is called when an attacker has no target enemy minion
# deal some damage to commander and take away the minions attack
func attack_commander() -> void:
	### insert some code to deal dmg to commander
	print(str(next_attacker.card.name) + " is attacking the commander.")
	
	# update combat log, emit signals to commanders to take damage
	if next_attacker is CardUI:
		Events.damage_enemy_commander.emit(next_attacker.strength)
		combat_log.update_text(str(next_attacker.card.name) + " attacks enemy commander (-" + str(next_attacker.strength) + ")\n")
	elif next_attacker is EnemyCardUI:
		Events.damage_player_commander.emit(next_attacker.strength)
		combat_log.update_text(str(next_attacker.card.name) + " attacks your commander (-" + str(next_attacker.strength) + ")\n")
	
	# take away the minions attack
	next_attacker.can_attack = false


# function to animate w/ tween the attacker moving to it's target
func move_to_target(attacker, target) -> void:
	
	var initial_position = attacker.global_position
	var target_position = target.global_position
	
	# set the member variable return_position, in case the attacker lives and needs to go back
	return_position = initial_position
	
	# Calculate the vector between initial pos and tar pos
	var direction_vector = target_position - initial_position
	# Calculate the final position that is a percentage of the way to the target
	var final_position = initial_position + (direction_vector * TWEEN_MOVE_PERCENT)
	
	var tween = Tween
	# tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	# lets try a TRANS_QUINT tween
	tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(attacker, "global_position", final_position, TWEEN_ATTACK_TIME)
	
	await tween.finished
	
	# emit the signal that animation is finished
	animation_finished.emit()


# func that calcs damage and applies it to health of cards
# also takes away the attacker's attack for the turn
func calculate_damage(attacker, target) -> void:
	# apply damage to health. dmg = str
	attacker.health -= target.strength
	target.health -= attacker.strength
	
	# update the hp labels
	attacker.update_health_label()
	target.update_health_label()
	
	# take away the attacker's attack
	attacker.can_attack = false
	
	# write what happened to the combat log.
	if attacker is CardUI:
		combat_log.update_text("Your " + attacker.card.name + "(-" + str(target.strength) + ") attacked enemy " + target.card.name + "(-" + str(attacker.strength) + ")\n")
	
	elif attacker is EnemyCardUI:
		combat_log.update_text("Enemy " + attacker.card.name + "(-" + str(target.strength) + ") attacked your " + target.card.name + "(-" + str(attacker.strength) + ")\n")
	


# this func takes a dead card (CardUI or EnemyCardUI) and sends it to the right GY
# for now, just delete the card until GY is implemented
# note: I might want to use .free() instead?
func send_to_graveyard(dead_card) -> void:
	# safety check for data type
	if not dead_card is CardUI and not dead_card is EnemyCardUI:
		print("send_to_graveyard failed. " + str(dead_card) + " is unexpected type: " + str(typeof(dead_card)))
		# delete it anyway I guess
		print("calling queue_free on it anyway")
		dead_card.free()
		return
	
	if dead_card is CardUI:
		# I'm gonna make the card transition states here. This might not be the best place but oh well
		dead_card.card_state_machine.current_state.transition_requested.emit(dead_card.card_state_machine.current_state, CardState.State.DEAD)
		player_gy.add_card_to_gy(dead_card)
	
	elif dead_card is EnemyCardUI:
		enemy_gy.add_card_to_gy(dead_card)
	
	else:
		dead_card.free()
	
	# emit the signal that repositions stuff
	Events.field_needs_repositioning.emit()
	Events.e_field_needs_repositioning.emit()
	# await a signal that the cards have been repositioned
	# await Events.reposition_complete
	# print("Reposition complete")
	# I Think the await needs to go back up in the main loop


# this func is called to move an attacker that survivd battle back into place.
# uses return_position var
func move_back(attacker_survived) -> void:
	
	# var initial_position = attacker_survived.global_position
	var target_position = return_position
	
	var tween = Tween
	# tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	# trying a TRANS_QUINT tween
	tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(attacker_survived, "global_position", target_position, TWEEN_ATTACK_TIME)
	
	await tween.finished
	
	# emit the signal that animation is finished
	animation_finished.emit()
