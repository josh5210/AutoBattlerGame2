class_name ERepositioner
extends Node

@onready var e_hand = %EnemyHand
@onready var e_field = %EnemyField

# the repositioner will set Y pos of cards to this (relative)
const FIELD_Y_POSITION := 0.0
# max width of cards on field
const FIELD_MAX_WIDTH := 1000.0
# this const is used to slightly seperate cards when there are 2 or 3 on field
const SEPERATION_BUFFER := 20.0
# this const used to determine field width when 2 or 3 or 4 cards
const CARD_WIDTH_IN_PLAY := 175.0
# time it will take to tween a card into position
const TWEEN_TIME := 0.5



# each card will use these vars to reach it's position after repositioning 
var y_position
var x_position


func _ready() -> void:
	# connec to the signal that indicates repositioning is needed.
	Events.e_field_needs_repositioning.connect(_on_e_field_needs_repositioning)
	# connect to the signal that a new card is in play
	Events.e_new_card_in_play.connect(_on_e_new_card_in_play)




func tween_to_position(ecard_ui: EnemyCardUI, x_pos: float, y_pos: float) -> void:
	
	var final_position = Vector2(x_pos, y_pos)
	var tween = Tween
	# var final_size = Vector2(1, 1)
	tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(ecard_ui, "position", final_position, TWEEN_TIME)
	# tween.set_parallel()
	# tween.tween_property(ecard_ui, "scale", final_size, TWEEN_TIME)




# func is called by signal emmited
func _on_e_field_needs_repositioning() -> void:
	
	for ecard_ui in e_field.get_children():
		
		x_position = calc_x_pos(ecard_ui)
		y_position = calc_y_pos(ecard_ui)
		# tween them to their new pos
		tween_to_position(ecard_ui, x_position, y_position)
	
	# Use a lil temporary timer that waits for the tween time, then emits the signal
	# that reposition is complete.
	get_tree().create_timer(TWEEN_TIME, false).timeout.connect(
		func():
			#
			Events.e_reposition_complete.emit()
	)
	




func calc_x_pos(ecard_ui: EnemyCardUI) -> float:
	
	# calculate X position based on same thing from repo btn func
	var num_cards: int = e_field.get_child_count()
	if num_cards == 1:
		x_position = FIELD_MAX_WIDTH / 2
	elif num_cards > 1:
		var weight: float = float(ecard_ui.get_index()) / float(num_cards - 1)
		if num_cards >= 2 and num_cards <= 4:
			var field_width
			# making it so when we have 2 cards they are a bit closer
			if num_cards == 2:
				field_width = (CARD_WIDTH_IN_PLAY * num_cards) - 80.0
			else:
				field_width = (CARD_WIDTH_IN_PLAY * num_cards) + SEPERATION_BUFFER
			var buffer_towards_center = (FIELD_MAX_WIDTH - field_width) / 2
			x_position = (weight * field_width) + buffer_towards_center
		else:
			x_position = weight * FIELD_MAX_WIDTH
	
	return x_position



func calc_y_pos(_ecard_ui: EnemyCardUI) -> float:
	
	return FIELD_Y_POSITION


# Have not added "find_new_card_index" to enemy repo, might reconsider adding later



func _on_e_new_card_in_play(new_card: EnemyCardUI) -> void:
	
	# check if the new card has a parent, and remove it if it does
	if new_card.get_parent():
		new_card.get_parent().remove_child(new_card)
	
	# then add it as a child of field
	e_field.add_child(new_card)
	
	# emit signal(to self) for repositioning
	Events.e_field_needs_repositioning.emit()
	
	get_tree().create_timer(TWEEN_TIME, false).timeout.connect(
		func():
			# change the new card to it's in play visuals after the tween.
			new_card.hand_texture.set_visible(false)
			new_card.color.set_color(1)
			new_card.in_play_texture.set_visible(true)
	)
	
