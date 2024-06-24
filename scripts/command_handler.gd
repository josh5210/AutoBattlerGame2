class_name CommandHandler
extends Node

# this node will handle executing the effects of command cards that are played

@onready var player_commander = %PlayerCommander
@onready var enemy_commander = %EnemyCommander
@onready var deck = %Deck
@onready var enemy_deck = %EnemyDeck
@onready var enemy_hand = %EnemyHand
@onready var hand = %Hand
@onready var enemy_field = %EnemyField
@onready var player_field = %PlayerField
@onready var enemy_gy = get_tree().get_first_node_in_group("enemy_gy")
@onready var player_gy = get_tree().get_first_node_in_group("player_gy")



# this func is called by released state.
# Pass in the card attempting to be played and who played it
# should accept both CardUI and EnemyCardUI
# shouldn't need player string bc we can use type CardUI/EnemyCardUI
# This command will return TRUE if card was played, FALSE if not
func command_targeting_field_released(cardui) -> bool:
	
	# run another func that returns if the conditions to play the card have been met
	var card_is_playable: bool = is_card_playable(cardui)
	
	# if the card is found to be playable, we can move on to executing the effect of it
	if card_is_playable:
		execute_effects(cardui)
		# return true to released state, which will queuefree the card
		return true
	
	# if it isn't playable, it will have to go back to hand
	else:
		# debug
		print("command_targeting_field_released but conditions to play card not met.")
		# return FALSE back to released state, so it knows to go to base state
		return false





# This func should check the conditions unique to each card and return if those conditions
# are met
# e.g., gravedigging requires at least 1 minion in the player's GY
# NOTE: this will have to be updated when @export_group("Requirements to Play") is updated
func is_card_playable(my_card) -> bool:
	# the number of conditions that has to be met to return true is defined by card
	var num_of_conditions : int = my_card.card.number_of_special_conditions
	# if no special conditions are needed, we can return true right away
	if num_of_conditions == 0:
		# debug print
		print("is_card_playbale returned true with num_of_conditions == 0")
		return true
	
	# now we begin checking against the conditions
	# this var will count how many conditions are met
	var conditions_met := 0
	
	# for GY check (gravedigging)
	if my_card.card.min_minions_in_own_gy > 0:
		# know which GY to check based on class
		if my_card is CardUI:
			if player_gy.gyv_box.get_child_count() >= my_card.card.min_minions_in_own_gy:
				# true condition
				conditions_met += 1
		elif my_card is EnemyCardUI:
			if enemy_gy.gyv_box.get_child_count() >= my_card.card.min_minions_in_own_gy:
				conditions_met += 1
	
	# NOTE: future condition checks will need to be added here
	
	# return true if enough conditions were met
	return conditions_met >= num_of_conditions


# this func will check what effects a card has and call the relevant func to do those
func execute_effects(my_card) -> void:
	
	# REVIVE
	if my_card.card.revive_x > 0:
		revive_x(my_card, my_card.card.revive_x)


################################################################
# now the part where we actually define the funcs that do stuff#
################################################################

# func to revive x random minions from player/enemy gy to deck
func revive_x(my_card, x: int) -> void:
	
	# we know which gy and deck to target based on type of my_card
	var tar_deck = deck if my_card is CardUI else enemy_deck
	var tar_gyv_box = player_gy.gyv_box if my_card is CardUI else enemy_gy.gyv_box
	
	# loop in range of x looking for card to revive
	for num_targets in range(0, x):
		
		# check for a child of gy, as x can be larger than size of gy
		if tar_gyv_box.get_child_count() > 0:
			
			# pick a random index in range of gy
			var random_index: int = randi_range(0, tar_gyv_box.get_children().size() - 1)
			# assign the revive target
			var revive_target = tar_gyv_box.get_children()[random_index]
			# make a duplicate card resource of the target
			var dupe_card = revive_target.card.duplicate()
			# add that to the tar deck
			tar_deck.add_card_to_deck(dupe_card)
			# send a signal to let the gy know to update label
			if my_card is CardUI:
				Events.card_left_gy.emit(revive_target)
			elif my_card is EnemyCardUI:
				Events.card_left_enemy_gy.emit(revive_target)
			# delete the revived card (immediately)
			revive_target.free()
