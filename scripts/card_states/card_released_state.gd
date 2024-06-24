extends CardState

# ref the player commander using the group it is in
@onready var player_commander = get_tree().get_first_node_in_group("player_commander")
# ref the command handler for command cards
@onready var command_handler = get_tree().get_first_node_in_group("command_handler")


# when entering released state, check some logic to see where card should go
func enter() -> void:
	
	# command cards will have different func for entering released
	if card_ui.is_command:
		command_enter_released()
		return
	
	# if card that was already played released, send back to inplay
	if card_ui.card_played:
		transition_requested.emit(self, CardState.State.INPLAY)
		return
	
	# if there is no target or we can't summon, card goes back to BASE in hand
	elif card_ui.targets.is_empty() or not player_commander.can_summon:
		transition_requested.emit(self, CardState.State.BASE)
		# signal to hand repo to repo this card back in hand
		Events.new_card_in_hand.emit(card_ui)
		Events.hand_needs_repositioning.emit()
		return
	
	# when we can summon (and card not played, and we have target)
	elif player_commander.can_summon:
		# set the card played, no more summon, go in play
		card_ui._set_card_played(true)
		player_commander.can_summon = false
		transition_requested.emit(self, CardState.State.INPLAY)
	
	# else case for error handling, this shouldnt be called theoretically
	else:
		print("Error in released state for " + str(card_ui))





# this was the old enter func, new one also accounts for player_commander.can_summon
func old_enter() -> void:
	
	# tween_to_original_size()
	
	print("Entered RELEASED")
	card_ui.state_label.text = str(card_ui.card_state_machine.current_state)
	print("Targets: " + str(card_ui.targets))
	
	if not card_ui.targets.is_empty():
		# if the card has a target, it should be played
		# this can be refined to also check if the target is valid (field not full) later
		
		#debug
		print("Targets: " + str(card_ui.targets))
		
		# set card to played true
		card_ui._set_card_played(true)
		
		print("Requesting transition to INPLAY")
		transition_requested.emit(self, CardState.State.INPLAY)
	
	else:
		# else, if there is no target
		# we should check if the card came from hand or field
		if card_ui.card_played:
			# go back to INPLAY state
			transition_requested.emit(self, CardState.State.INPLAY)
		
		# if card not played, we were in hand, so go back to BASE in hand
		else:
			transition_requested.emit(self, CardState.State.BASE)
			# signal to hand repo to repo this card back in hand
			Events.new_card_in_hand.emit(card_ui)
			Events.hand_needs_repositioning.emit()


func on_input(event: InputEvent) -> void:
	#
	print("released state input detection")
	
	if not event is InputEventMouse:
		print("released state NON mouse input, returning")
		return
	
	if card_ui.card_played:
		transition_requested.emit(self, CardState.State.INPLAY)
	else:
		transition_requested.emit(self, CardState.State.BASE)



# not going to use this func, it gets in the way of repositioner func
# instead, lets try combining with repo tweens
func tween_to_original_size() -> void:
	
	card_ui.pivot_offset = card_ui.size / 2
	var final_size = Vector2(1, 1)
	var tween = Tween
	tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(card_ui, "scale", final_size, 0.5)


# func executed when a command card enters released state.
func command_enter_released() -> void:
	
	# if it is a card that targets field
	if card_ui.card.targets_player_field():
		# check if the cardui has a target (it's hovering over field)
		# if it doesn't, it goes back to BASE in hand
		if card_ui.targets.is_empty():
			transition_requested.emit(self, CardState.State.BASE)
			# signal to hand repo to repo this card back in hand
			Events.new_card_in_hand.emit(card_ui)
			Events.hand_needs_repositioning.emit()
			return
		# otherwise, the card is trying to be played
		# call the CommandHandler func, which returns TRUE if the card
		# ends up being played, false if not
		else:
			var card_was_played = command_handler.command_targeting_field_released(card_ui)
			# now, if it wasn't played, go back to BASE
			if !card_was_played:
				transition_requested.emit(self, CardState.State.BASE)
				# signal to hand repo to repo this card back in hand
				Events.new_card_in_hand.emit(card_ui)
				Events.hand_needs_repositioning.emit()
				return
			# if it was played, I think we can queue_free() it from here
			if card_was_played:
				card_ui.queue_free()
	
	
	# debug.
	print("command_enter_released: a non-field target command released.")


