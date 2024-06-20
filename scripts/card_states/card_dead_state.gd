extends CardState

# the combat handler will take care of
# sending the card to gy
# then it will put the card in the dead state
@onready var deck = get_tree().get_first_node_in_group("deck") as Deck
# also need our commander to check if we can summon
@onready var player_commander = get_tree().get_first_node_in_group("player_commander") as PlayerCommander
# get the battle node that knows if it's player's turn
@onready var battle = get_tree().get_first_node_in_group("battle")


func enter() -> void:
	# debug
	# print("Card: " + str(card_ui) + " entered dead state.")
	# card_ui.visible = false
	pass




# possible future func for cards coming back from death
func exit() -> void:
	pass



# using this func to trigger revives
func on_gui_input(event: InputEvent) -> void:
	# we shouldnt allow revive if not player turn
	if !battle.is_player_turn:
		return
	
	# we shouldnt take the input if not visilbe
	if !card_ui.is_visible():
		return
	
	# LMB will attempt to revive the card
	if event.is_action_pressed("left_mouse"):
		
		# we shouldn't take input if we can't summon
		if !player_commander.can_summon:
			# debug
			print("You tried to revive " + str(card_ui) + " but you can't summon now.")
			return
		else:
			# if we can summon, call the func to revive
			revive(card_ui)


# this func will handle reviving a dead card.
# normally called by the above gui input
func revive(dead_card: CardUI) -> void:
	
	# add a copy of the card to the deck, then delete the current card
	var duped_card = dead_card.card.duplicate()
	deck.add_card_to_deck(duped_card)
	
	# also take away the player's summon
	player_commander.can_summon = false
	
	
	# send a signal to let the gy know to update label
	Events.card_left_gy.emit(dead_card)
	
	dead_card.queue_free()
