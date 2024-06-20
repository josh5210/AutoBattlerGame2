class_name CombatHandler
extends Node

# constant for bonus damage for the attacker
const ATTACKER_BONUS := 0
const TWEEN_ATTACK_TIME := 1.5

@onready var player_field: PlayerField = %PlayerField as PlayerField
@onready var enemy_field: EnemyField = %EnemyField as EnemyField
@onready var combat_log: Label = %CombatLog

# array var that will hold the order that attacks should happen.
var combat_stack = []


# bool that will decide whose turn it is to attack
var player_first = true


# bool that will say if next attack is ready to happen
# starts true bc first attacker doesn't need to wait
#var next_attack_ready = true



func combat_started() -> void:
	# clear the stack
	combat_stack.clear()
	
	# randomly choose a player to attack first
	# 0 for player, 1 for enemy
	var random_turn = randi_range(0, 1)
	if random_turn == 0:
		player_first = true
	else:
		player_first = false
	
	# create the stack. It gets put in member var combat_stack
	create_stack()
	
	# start attacks based on stack
	await start_stack()
	
	# emit the signal that combat is over after stack is done
	Events.combat_phase_ended.emit()


#### TODO: stack sometimes isn't filled fully. needs more debugging.
# this func will create the stack, an order in which the minions should attack.
func create_stack() -> void:
	
	# get arrays of minions on both sides of field.
	var player_minions = player_field.get_children()
	var enemy_minions = enemy_field.get_children()
	
	# join the 2 arrays together.
	var all_minions = []
	all_minions.append_array(player_minions)
	all_minions.append_array(enemy_minions)
	
	# loop through every minion, adding them to stack
	for minion in all_minions:
		#
		print("This minion is type: " + str(typeof(minion)))
		if player_first && !player_minions.is_empty():
			# add a minion to the stack if the array isn't empty
			# if !player_minions.is_empty():
			combat_stack.append(player_minions.pop_front())
		elif !player_first && !enemy_minions.is_empty():
			#if !enemy_minions.is_empty():
			combat_stack.append(enemy_minions.pop_front())
		# invert turn
		player_first = !player_first
	
	
	# debugging
	print("Combat stack created. The stack Contains: \n")
	for m in combat_stack:
		print(str(m))


#
func start_stack() -> void:
	
	# the first attack does not need to wait for the signal of next attack ready
	# so create a flag to indicate first attack
	#var first_attack = true
	
	# loop over every minion in combat stack
	for guy in combat_stack:
		# if the minion in the stack died already, skip this loop
		if guy == null:
			# debug print
			print("null value in stack.")
			continue
		

		# create a waiting loop.
		# next_attack_ready will be set true when a card finishes its return anim
		#while !next_attack_ready:
			#print("waiting for next attack ready")
			#continue
		
		
		# debug print stuff
		combat_log.update_text(guy.card.name + " is preparing to attack.\n")
		
		# now that we've made the first attack check, we can set the flag false
		#next_attack_ready = false
		
		# if the minion in this loop is player's minion
		if guy is CardUI:
			# select a target
			# If there are no minions to attack, hit commander
			if enemy_field.get_child_count() == 0:
				attack_enemy_commander()
			else:
				var target = p_choose_target()
				# use the tween func to animate. guy attacks target
				await p_v_e_tween(guy, target)
				
				# maybe adding a continue here will help await
				continue
				
				# vvv the calc dmg func is going to be called from the tween func now
				# call the func to calc damage
				# CardUI is attacking Target, player's attack
				# calculate_damage(guy, target, "player")
		# elif its enemy's minion
		elif guy is EnemyCardUI:
			# If there are no minions to attack, hit commander
			if player_field.get_child_count() == 0:
				attack_player_commander()
			else:
				# selecting target
				var target = e_choose_target()
				# animate the tween
				await e_v_p_tween(guy, target)
				
				# maybe adding a continue here will help await
				continue
				
				# call calc dmg
				# CardUI is the target being attacked by EnemyCardUI, enemy's attack
				# calculate_damage(target, guy, "enemy")



# func for a player's minion to choose a target
func p_choose_target() -> EnemyCardUI:
	# get an array of all the minions on enemy field
	var possible_targets: Array = enemy_field.get_children()
	# pick a number in range
	var target_num: int = randi_range(0, possible_targets.size() - 1)
	# return the object at that index
	return possible_targets[target_num]


# func for an enemy's minion to choose a target
func e_choose_target() -> CardUI:
	# get an array of all the minions on enemy field
	var possible_targets: Array = player_field.get_children()
	# pick a number in range
	var target_num: int = randi_range(0, possible_targets.size() - 1)
	# return the object at that index
	return possible_targets[target_num]


func calculate_damage(p_card: CardUI, e_card: EnemyCardUI, attacker: String) -> void:
	
	# the cards will take damage based on the opposite cards strength
	var p_damage_taken: int = e_card.strength
	var e_damage_taken: int = p_card.strength
	
	# apply the damage to health
	p_card.health -= p_damage_taken
	e_card.health -= e_damage_taken
	
	# update the hp labels
	p_card.update_health_label()
	e_card.update_health_label()
	
	
	# write what happened to the combat log.
	if attacker == "player":
		combat_log.update_text("Your " + p_card.card.name + "(-" + str(p_damage_taken) + ") attacked enemy " + e_card.card.name + "(-" + str(e_damage_taken) + ")\n")
	
	elif attacker == "enemy":
		combat_log.update_text("Enemy " + e_card.card.name + "(-" + str(e_damage_taken) + ") attacked your " + p_card.card.name + "(-" + str(p_damage_taken) + ")\n")
	
	# send cards to gy if they are dead
	if p_card.health <= 0:
		send_to_p_graveyard(p_card)
	if e_card.health <= 0:
		send_to_e_graveyard(e_card)


##### vv obselete func, based only on str.
# calculate damage
# not returning anything from this func, it will just update the str stat of the card itself
# Takes 3 args
# CardUI, EnemyCardUI, whoIsAttacking("player"/"enemy")
func calculate_damage_obsolete(p_card:CardUI, e_card:EnemyCardUI, attacker:String) -> void:
	var p_damage: int
	var e_damage: int
	
	var difference: int = p_card.strength - e_card.strength
	
	if attacker == "player":
		p_damage = abs(difference)
		e_damage = abs(difference) + ATTACKER_BONUS
	
	elif attacker == "enemy":
		p_damage = abs(difference) + ATTACKER_BONUS
		e_damage = abs(difference)
	
	else:
		# something what wrong
		print("some kind of error in combat_handler: unknown attacker")
	
	# apply the damage
	p_card.strength -= p_damage
	# update the label
	p_card.update_strength_label()
	# if dead, send to graveyard.
	if p_card.strength <= 0:
		send_to_p_graveyard(p_card)
	
	# same thing for enemy card
	e_card.strength -= e_damage
	e_card.update_strength_label()
	if e_card.strength <= 0:
		send_to_e_graveyard(e_card)
	
	# write what happened to the combat log.
	if attacker == "player":
		combat_log.update_text("Your " + p_card.card.name + "(-" + str(p_damage) + ") attacked enemy " + e_card.card.name + "(-" + str(e_damage) + ")\n")
	
	elif attacker == "enemy":
		combat_log.update_text("Enemy " + e_card.card.name + "(-" + str(e_damage) + ") attacked your " + p_card.card.name + "(-" + str(p_damage) + ")\n")



#
func send_to_p_graveyard(dead_card: CardUI) -> void:
	
	# this func will send a card to the graveyard.
	# for now ill just queue_free the card
	
	dead_card.queue_free()
	
	# emit the signal that next att is ready
	#Events.next_attack_ready.emit()



func send_to_e_graveyard(dead_card: EnemyCardUI) -> void:
	
	dead_card.queue_free()
	
	# emit the signal that next att is ready
	#Events.next_attack_ready.emit()




# func to hit enemy commander, called when player has an attacker and enemy has no minion
func attack_enemy_commander() -> void:
	# debug
	print("Your minion has no target so it hits enemy commander.")


# func to hit player commander, called when enemy has an attacker and player has no minion
func attack_player_commander() -> void:
	# debug
	print("Enemy minion has no target so it hits your commander.")



# this func animated a player minion to move towards an enemy minion
func p_v_e_tween(p: CardUI, e: EnemyCardUI) -> void:
	
	var tween = Tween
	tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	
	var initial_position = p.global_position
	var target_position = e.global_position
	
	tween.tween_property(p, "global_position", target_position, TWEEN_ATTACK_TIME)
	# tween.tween_property(p, "global_position", initial_position, 1.0).set_delay(1.0)
	await tween.finished
	# print("tween finished")
	# call the func to calc damage, player attacked enemy, player's attack.
	if is_instance_valid(p) and is_instance_valid(e):
		await calculate_damage(p, e, "player")
	
	# if the player minion is still alive, animate it back
	if is_instance_valid(p) and p.health > 0:
		await p_return(p, initial_position)
	
	# maybe adding a return at the end will help the await kick in
	return


func e_v_p_tween(e: EnemyCardUI, p: CardUI) -> void:
	
	var tween = Tween
	tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	
	var initial_position = e.global_position
	var target_position = p.global_position
	
	tween.tween_property(e, "global_position", target_position, TWEEN_ATTACK_TIME)
	# tween.tween_property(e, "global_position", initial_position, 1.0).set_delay(1.0)
	await tween.finished
	#### call calc dmg here
	if is_instance_valid(p) and is_instance_valid(e):
		await calculate_damage(p, e, "enemy")
	
	# if the enemy minion is still alive, animate it back
	if is_instance_valid(e) and e.health > 0:
		await e_return(e, initial_position)
	
	# maybe adding a return at the end will help the await kick in
	return



# This func will return a player minion that attacked back to it's original position
func p_return(p: CardUI, initial_position: Vector2) -> void:
	var tween = Tween
	tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(p, "global_position", initial_position, TWEEN_ATTACK_TIME)
	await tween.finished
	
	# maybe adding a return at the end will help the await kick in
	return


func e_return(e: EnemyCardUI, initial_position: Vector2) -> void:
	var tween = Tween
	tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(e, "global_position", initial_position, TWEEN_ATTACK_TIME)
	await tween.finished
	
	
	return
