extends CardState


func enter():
	
	# debug
	print("Entered IN_PLAY")
	#card_ui.state_label.text = "INPLAY"
	# card_ui.state_label.text = str(card_ui.card_state_machine.current_state)
	# commenting out these lines for now for debuging
	card_ui.hand_texture.set_visible(false)
	card_ui.color.set_color(1)
	card_ui.in_play_texture.set_visible(true)
	
	
	
	# having issues with size, and the boxes moving
	# test, this seems to work
	card_ui.set_custom_minimum_size(Vector2(200, 300))
	card_ui._set_size(Vector2(200, 300))
	
	# reset pivot_offset
	# card_ui.pivot_offset = Vector2.ZERO
	
	# use this event to let repositioner know to remake array for field
	Events.new_card_in_play.emit(card_ui)
	# repositioner testing: when a card enters play, emit this signal to repositioner
	Events.field_needs_repositioning.emit()



# I want cards In play to be able to be picked up again and place in a different spot on the field
# so the card can go back to CLICKED state
func on_gui_input(event: InputEvent) -> void:
	
	# we do not want to take input if card is disabled
	if card_ui.disabled:
		# print("gui input while in play and disabled")
		return
	
	if event.is_action_pressed("left_mouse") and !card_ui.disabled:
		card_ui.pivot_offset = card_ui.get_global_mouse_position() - card_ui.global_position
		transition_requested.emit(self, CardState.State.CLICKED)


# new func for anytime a card exits in_play. Make a request to the repositioner
func exit():
	pass
