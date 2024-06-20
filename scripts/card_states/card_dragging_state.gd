extends CardState

# when clicking (without holding) and dragging, sometimes the release is registered too quickly
# to fix, have a minimum threshold for dragging
# const DRAG_MINIMUM_THRESHOLD := 0.05
# bool for if the min time has elapsed
# var minimum_drag_time_elapsed := false



func enter() -> void:
	# debug
	# if card_ui.disabled:
		# print("WHY ARE WE ENTERING DRAGGING WHILE DISABLED?")
	
	
	Events.card_drag_started.emit(card_ui)
	# debug
	print("entering dragging state")
	#card_ui.state_label.text = "DRAGGING"
	# card_ui.state_label.text = str(card_ui.card_state_machine.current_state)
	# stores CanvasLayerBattleUI node in var
	# REMEMBER TO ADD GROUP UI_LAYER!!
	var ui_layer = get_tree().get_first_node_in_group("ui_layer")
	
	
	if ui_layer:
		card_ui.reparent(ui_layer, true)
		# debug
		# WE FOUND THE CULPRIT?!?
		#print("XDXDXD test123")
		# all i had to do was add the "true"... ffs there goes 5 hours LMAO
		# still have to disable cards while they are tweening tho
	
	# emit signal to hand repo, cards in hand slide over while this one exits hand
	Events.hand_needs_repositioning.emit()
	# same for field, if the card was already on field
	if card_ui.card_played:
		Events.field_needs_repositioning.emit()


func on_input(event: InputEvent) -> void:
	var mouse_motion := event is InputEventMouseMotion
	var cancel = event.is_action_pressed("right_mouse")
	var confirm = event.is_action_released("left_mouse") or event.is_action_pressed("left_mouse")

	if mouse_motion:
		card_ui.global_position = card_ui.get_global_mouse_position() - card_ui.pivot_offset
	
	# debug
	# print("Cancel: " + str(cancel))
	
	
	# I was having a bug where canceling cards that were already in play sent them to hand
	# check if card_played here as well
	if cancel:
		if card_ui.card_played:
			transition_requested.emit(self, CardState.State.INPLAY)
		elif not card_ui.card_played:
			transition_requested.emit(self, CardState.State.BASE)
			# debug
			print("Requested transition to BASE")
			# Signal the hand repo to add this card back to hand and repo
			Events.new_card_in_hand.emit(card_ui)
			Events.hand_needs_repositioning.emit()
	elif confirm:
		# get_viewport().set_input_as_handled()
		transition_requested.emit(self, CardState.State.RELEASED)
		print("Requested transition to REALEASED")
		# TESTING moving this v
		# get_viewport().set_input_as_handled()


func exit() -> void:
	# emit signal w/ event bus that dragging ended
	Events.card_drag_ended.emit(card_ui)

# Todo: connect the signals from events card_drag_started and card_drag_ended
