class_name EnemyTurnHandler
extends Node

# @onready var battle_ui: BattleUI = $BattleUI as BattleUI

@onready var enemy_deck: EnemyDeck = %EnemyDeck as EnemyDeck
@onready var enemy_field: EnemyField = %EnemyField as EnemyField
@onready var enemy_hand: EnemyHand = %EnemyHand as EnemyHand
@onready var enemy_commander: EnemyCommander = %EnemyCommander as EnemyCommander
@onready var enemy_gy: EnemyGY = get_tree().get_first_node_in_group("enemy_gy") as EnemyGY


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# func to draw a card
func enemy_draw_card() -> void:
	# just call the hand's func
	enemy_hand.draw_single_card()



# func that will play a card from the enemy's hand to their field
func e_play_card() -> void:
	# double check that e can summon
	if !enemy_commander.can_summon:
		print("error: e_play_card was called by enemy commander can not summon")
		return
	
	# if there are cards in hand, return from func
	if enemy_hand.get_child_count() == 0:
		return
		
	# randomly choose a card in hand to play
	# lets make this a function call
	var card_picked = e_pick_card_to_play()
	
	# debug
	print("The enemy wants to play " + str(card_picked))
	
	###### implement putting this card on enemy field next.
	
	# Using group enemy_field_layer, I will reparent the card to the PlayerField
	var enemy_field_layer = get_tree().get_first_node_in_group("enemy_field_layer")
	# reparent the card from hand to the player field
	if enemy_field_layer:
		print("Reparenting card to enemy field")
		card_picked.reparent(enemy_field_layer, true)
		
		# emit a signal that the enemy has played a card.
		# This signal will be used by EnemyField, and maybe elsewhere
		Events.enemy_card_played.emit()
		# emit the signal that the ERepo picks up
		Events.e_new_card_in_play.emit(card_picked)
		# set the summon to false
		enemy_commander.can_summon = false



# This func will just randomly choose a card in enemy hand to play
# i think returning the object type EnemyCardUI will work
func e_pick_card_to_play() -> EnemyCardUI:
	
	# loop over children of enemy hand. Assign them to an array.
	# randomly pick a num from the array to return.
	
	var e_card_uis: Array[EnemyCardUI] = []
	
	for child in enemy_hand.get_children():
		
		e_card_uis.append(child)
		# debug print the array
		# print("Added " + str(child) + " to e_card_uis array.")
	
	# If the array is not empty, get a random index
	if e_card_uis.size() > 0:
		var random_index: int = randi_range(0, e_card_uis.size() - 1)
		# return the object at this index
		return e_card_uis[random_index]
	# else, the array was empty, so hand was empty
	else:
		return null


# func called by battle when enemy has no card in hand and has a summon and has card in gy
func e_revive_card() -> void:
	# unlike player revive, this func will randomly pick something in enemy gy to revive
	var e_card_uis: Array[EnemyCardUI] = []
	for child in enemy_gy.gyv_box.get_children():
		e_card_uis.append(child)
	if e_card_uis.size() == 0:
		print("no card found in enemy gy by e_revive_card")
		return
	# get a random index and pick that card
	var random_index: int = randi_range(0, e_card_uis.size() - 1)
	var dead_card = e_card_uis[random_index]
	
	# add a copy of the card to the deck, then delete the current card
	var duped_card = dead_card.card.duplicate()
	enemy_deck.add_card_to_deck(duped_card)
	
	# take away the summon
	enemy_commander.can_summon = false
	
	# send a signal to let the gy know to update label
	Events.card_left_enemy_gy.emit(dead_card)
	
	dead_card.queue_free()
