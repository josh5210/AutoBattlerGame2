class_name HandRepo
extends Node

# repositioner for hand
var repo_is_running := false

@onready var hand = %Hand
# @onready var repo_button = $"../RepoButton"
# @onready var p_field = %PlayerField

# I'm going to position the Node2D of the hand right on the deck
# so that the cards appear to come from there when drawn.
# This means the tween to position will need to account for that and offset

# const to account for the offset from deck
const X_OFFSET_FROM_DECK := -1200.0
# the repositioner will set Y pos of cards to this
const HAND_Y_POSITION := 100.0
# max width of cards on field
const HAND_MAX_WIDTH := 800.0
# this const is used to slightly seperate cards when there are 2 or 3 on field
const SEPERATION_BUFFER := 20.0
# this const used to determine field width when 2 or 3 or 4 cards
const CARD_WIDTH_IN_HAND := 200.0
# time it will take to tween a card into position
const TWEEN_TIME := 0.25


# each card will use these vars to reach it's position after repositioning 
var y_position
var x_position


func _ready() -> void:
	# repo_button.pressed.connect(_on_repo_button_pressed)
	# connec to the signal that indicates repositioning is needed.
	Events.hand_needs_repositioning.connect(_on_hand_needs_repositioning)
	# connect to the signal that a new card is in play
	Events.new_card_in_hand.connect(_on_new_card_in_hand)



func tween_to_position(card_ui: CardUI, x_pos: float, y_pos: float) -> void:
	card_ui.disabled = true
	var final_position = Vector2(x_pos, y_pos)
	var final_size = Vector2(1, 1)
	var tween = Tween
	tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(card_ui, "position", final_position, TWEEN_TIME)
	tween.set_parallel()
	tween.tween_property(card_ui, "scale", final_size, TWEEN_TIME)
	tween.finished.connect(
		func(): card_ui.disabled = false
	)
	#### ^



# func is called by signal emmited when card released, canceled, or dragged
func _on_hand_needs_repositioning() -> void:
	
	for card_ui in hand.get_children():
		
		x_position = calc_x_pos(card_ui)
		y_position = calc_y_pos(card_ui)
		# tween them to their new pos
		tween_to_position(card_ui, x_position, y_position)
	
	# Use a lil temporary timer that waits for the tween time, then emits the signal
	# that reposition is complete.
	get_tree().create_timer(TWEEN_TIME, false).timeout.connect(
		func():
			Events.hand_reposition_complete.emit()
			)
	



func calc_x_pos(card_ui: CardUI) -> float:
	
	# calculate X position based on same thing from repo btn func
	var num_cards: int = hand.get_child_count()
	if num_cards == 1:
		x_position = HAND_MAX_WIDTH / 2
	elif num_cards > 1:
		var weight: float = float(card_ui.get_index()) / float(num_cards - 1)
		if num_cards >= 2 and num_cards <= 4:
			var hand_width
			# making it so when we have 2 cards they are a bit closer
			if num_cards == 2:
				hand_width = (CARD_WIDTH_IN_HAND * num_cards) - 80.0
			else:
				hand_width = (CARD_WIDTH_IN_HAND * num_cards) + SEPERATION_BUFFER
			var buffer_towards_center = (HAND_MAX_WIDTH - hand_width) / 2
			x_position = (weight * hand_width) + buffer_towards_center
		else:
			x_position = weight * HAND_MAX_WIDTH
	# account for the offset from deck
	x_position += X_OFFSET_FROM_DECK
	return x_position



func calc_y_pos(_card_ui: CardUI) -> float:
	
	return HAND_Y_POSITION


# when we want to insert a new card on the hand at target position
# this func will take the old array of minions in hand and the new card as args
# it will return an int which is the index the new card should be at
func find_new_card_index(old_array: Array, new_card: CardUI) -> int:
	
	# vars we will use to know which card should be after the new card in the array
	var after_card = null
	
	# take the global x position of the new card
	var target_position_x = new_card.global_position.x
	
	# loop over the cards in the array and compare the x position
	for card_ui in old_array:
		# find the first minion that is after the new minion by x position
		if card_ui.global_position.x >= target_position_x:
			after_card = card_ui
			break
	
	# this will be the index to place the new card
	var new_card_index
	# if an after card was found
	if after_card:
		# the new card will take over the index of the card that was after it
		new_card_index = old_array.find(after_card)
	# if no after card was found, the new card is the last card in array
	else:
		new_card_index = old_array.size()
	
	# return the new index
	return new_card_index


# when a new card enters hand, we want to insert the new card at the right spot
func _on_new_card_in_hand(new_card: CardUI) -> void:
	
	var old_array = hand.get_children()
	
	# find right index for new card
	var new_index = find_new_card_index(old_array, new_card)
	#
	# check if the new card has a parent, and remove it if it does
	if new_card.get_parent():
		new_card.get_parent().remove_child(new_card)
	
	# then add it as a child of hand
	hand.add_child(new_card)
	# move it to the new index
	hand.move_child(new_card, new_index)
	
	# let's try this? it works!
	# new_card.global_position = new_card.get_global_mouse_position() - new_card.pivot_offset
	
