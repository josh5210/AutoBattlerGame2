extends CardState

var tween_to_mouse: Tween


func enter() -> void:
	
	if card_ui.disabled:
		print("WHY ARE WE ENTERING CLICKED WHILE DISABLED?")
	
	# test
	# card_ui.pivot_offset = card_ui.get_global_mouse_position() - card_ui.global_position
	# card_ui.pivot_offset = Vector2.ZERO
	
	# kill any active tweens when a card is clicked
	# stop_active_tweens(card_ui)
	
	
	card_ui.drop_point_detector.monitoring = true
	# debug
	# print("entering clicked state")
	#card_ui.state_label.text = "CLICKED"
	# card_ui.state_label.text = str(card_ui.card_state_machine.current_state)
	
	# start_tween_to_mouse()


func on_input(event: InputEvent) -> void:
	
	# DONT TRANSITION IF DISABLED
	if card_ui.disabled:
		print("GOTCHA BUG!?")
		return
	
	if event is InputEventMouseMotion:
		# debug
		# print("requesting transition to dragging state")
		
		
		
		# if tween_to_mouse:
			# tween_to_mouse.kill()
		
		transition_requested.emit(self, CardState.State.DRAGGING)




# don't like how this turned out, not oging to use for now
func start_tween_to_mouse() -> void:
	
	var mouse_position = card_ui.get_global_mouse_position()
	tween_to_mouse = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween_to_mouse.tween_property(card_ui, "global_position", mouse_position, 0.5)



# kill any active tweens when a card is clicked
# this func didn't cause any errors but didnt help either
# not using this for now
func stop_active_tweens(tweening_card: CardUI) -> void:
	# check for a tween
	var tween = tweening_card.get_node_or_null("Tween")
	# if a tween is found, stop the tween
	if tween != null and tween.has_tween_pending():
		# debug
		print("clicked state found an active tween and is stopping it.")
		tween.stop_all()
