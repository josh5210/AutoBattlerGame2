extends CardState

@onready var hover_tween : Tween



func enter() -> void:
	if not card_ui.is_node_ready():
		await card_ui.ready
	
	card_ui.reparent_requested.emit(card_ui)
	card_ui.pivot_offset = Vector2.ZERO
	
	# debug
	# print("entered base state")
	# card_ui.state_label.text = str(card_ui.card_state_machine.current_state)
	
	# when entering base state, show the in hand texture, hide the in play texture
	card_ui.in_play_texture.set_visible(false)
	# also hide the in gy txtr
	card_ui.in_gy_texture.set_visible(false)


func on_gui_input(event: InputEvent) -> void:
	
	# we do not want to take input if card is disabled
	if card_ui.disabled:
		return
	
	if event.is_action_pressed("left_mouse") and !card_ui.disabled:
		card_ui.pivot_offset = card_ui.get_global_mouse_position() - card_ui.global_position
		transition_requested.emit(self, CardState.State.CLICKED)


# override the mouse enter callback to change card on hover
func on_mouse_entered() -> void:
	
	# start_hover_tween()
	pass


# override exit to no longer hover
func on_mouse_exited() -> void:
	
	# start_unhover_tween()
	pass



func start_hover_tween() -> void:
	
	
	if card_ui.disabled:
		return
	
	if hover_tween:
		hover_tween.kill()
	
	# card_ui.pivot_offset = card_ui.size / 2
	
	# var goal_pos = card_ui.global_position + Vector2.UP * 100
	
	var final_size = Vector2(1.5, 1.5)
	hover_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	hover_tween.tween_property(card_ui, "scale", final_size, 0.25)


func start_unhover_tween() -> void:
	
	if hover_tween:
		hover_tween.kill()
	
	# card_ui.pivot_offset = card_ui.size / 2
	var final_size = Vector2(1, 1)
	hover_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	hover_tween.tween_property(card_ui, "scale", final_size, 0.5)
