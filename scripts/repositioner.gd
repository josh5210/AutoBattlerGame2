class_name Repositioner
extends Node

@onready var hand = %Hand
# @onready var repo_button = $"../RepoButton"
@onready var p_field = %PlayerField

@onready var battle = get_tree().get_first_node_in_group("battle")

# the repositioner will set Y pos of cards to this
const FIELD_Y_POSITION := 0.0
# max width of cards on field
const FIELD_MAX_WIDTH := 1000.0
# this const is used to slightly seperate cards when there are 2 or 3 on field
const SEPERATION_BUFFER := 20.0
# this const used to determine field width when 2 or 3 or 4 cards
const CARD_WIDTH_IN_PLAY := 175.0
# time it will take to tween a card into position
const TWEEN_TIME := 0.4


# weight = index / num children

# I think I will have to use a card array for the repositioner that is different than
# just the array that is the nodes array of children of field
# var cards_array : Array[CardUI]

# each card will use these vars to reach it's position after repositioning 
var y_position
var x_position

# To tackle this bug of repo happening several times, I will try using this flag
# to cancel the on field needs repo function if it is already running
# var repo_is_running := false

# I have to keep track of the # of times the repo is called at once.
# Bc only the last instance of an active repo should re-enable cards
var repositioning_instances := 0



func _ready() -> void:
	# repo_button.pressed.connect(_on_repo_button_pressed)
	# connec to the signal that indicates repositioning is needed.
	Events.field_needs_repositioning.connect(_on_field_needs_repositioning)
	# connect to the signal that a new card is in play
	Events.new_card_in_play.connect(_on_new_card_in_play)



# obsolete func, was for testing
func _on_repo_button_pressed() -> void:
	
	print("repositioning")
	
	var num_cards: int = p_field.get_child_count()
	
	
	# if there is only 1 card in play, it is in the center
	if num_cards == 1:
		var card_ui = p_field.get_child(0)
		x_position = FIELD_MAX_WIDTH / 2
		y_position = FIELD_Y_POSITION
		tween_to_position(card_ui, x_position, y_position)
		# p_field.get_child(0).position.x = FIELD_MAX_WIDTH / 2
		# p_field.get_child(0).global_position.y = FIELD_Y_POSITION
	
	# if there are more than 1 cards in play
	elif num_cards > 1:
		# loop over the array of children cards
		for card_ui in p_field.get_children():
			# get the weight of the card
			var weight: float = float(card_ui.get_index()) / float(num_cards - 1)
			# card_ui.global_position.y = FIELD_Y_POSITION
			y_position = FIELD_Y_POSITION
			
			# if there are 2 or 3 or 4 cards,
			if num_cards >= 2 and num_cards <= 4:
				# the field width will be lower based on num of cards
				var field_width = (CARD_WIDTH_IN_PLAY * num_cards) + SEPERATION_BUFFER
				# bring the cards closer to center with this var
				var buffer_towards_center = (FIELD_MAX_WIDTH - field_width) / 2
				# card_ui.position.x = (weight * field_width) + buffer_towards_center
				x_position = (weight * field_width) + buffer_towards_center
			# else when we have 5+ cards, use max width of field
			else:
				# the x pos is the weight times the max width
				# card_ui.position.x = weight * FIELD_MAX_WIDTH
				x_position = weight * FIELD_MAX_WIDTH
			
			# call the func that tweens the card to it's pos
			tween_to_position(card_ui, x_position, y_position)



# why don't I just disable the card from here?...
func tween_to_position(card_ui: CardUI, x_pos: float, y_pos: float) -> void:
	card_ui.disabled = true
	
	var final_position = Vector2(x_pos, y_pos)
	var tween = Tween
	var final_size = Vector2(1, 1)
	tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(card_ui, "position", final_position, TWEEN_TIME)
	tween.set_parallel()
	tween.tween_property(card_ui, "scale", final_size, TWEEN_TIME)
	
	# re-enable cards only if it is player turn
	if battle.is_player_turn:
		tween.finished.connect(
			func(): card_ui.disabled = false
		)
	


func _on_field_needs_repositioning() -> void:
	
	for card_ui in p_field.get_children():
		
		x_position = calc_x_pos(card_ui)
		y_position = calc_y_pos(card_ui)
		# tween them to their new pos
		tween_to_position(card_ui, x_position, y_position)
	
	
	get_tree().create_timer(TWEEN_TIME, false).timeout.connect(
		func():
			Events.reposition_complete.emit()
			)

# func is called by signal emmited when a card changes into/out of in_play state
func old_on_field_needs_repositioning() -> void:
	# debug
	# print("_on_field_needs_repositioning started.")
	# To tackle this bug of repo happening several times, I will try using this flag
	# to cancel the function if it is already running
	# OK... we still need to repo things with the re-call of the func
	# but we doooont re-enable things with the re-call of the func
	# if repo_is_running:
		# print("repo called but re-enable will be cancelled! repo is running")
		# NOTE: the return must stay out, the above can go it's only for debug
		# return
	# repo_is_running = true
	
	# disable the cards on field until repositioning is complete
	p_field.disable_field()
	
	for card_ui in p_field.get_children():
		
		x_position = calc_x_pos(card_ui)
		y_position = calc_y_pos(card_ui)
		# tween them to their new pos
		tween_to_position(card_ui, x_position, y_position)
	
	# var repo_timer: Timer
	
	# get_tree().has_node(repo_timer)
	
	# Use a lil temporary timer that waits for the tween time, then emits the signal
	# that reposition is complete.
	# EDIT 6/18/24: Make the wait just a bit longer than tween time. (with the other fix, additional time shouldnt be needed.)
	get_tree().create_timer(TWEEN_TIME, false).timeout.connect(
		func():
			Events.reposition_complete.emit()
			# now that the func is done, reset the flag
			# repo_is_running = false
			# ONLY REENABLE CARDS IF ANOTHER INSTANCE OF REPO IS NOT RUNNING
			# if !repo_is_running:
			p_field.enable_field()
	)



func calc_x_pos(card_ui: CardUI) -> float:
	
	# calculate X position based on same thing from repo btn func
	var num_cards: int = p_field.get_child_count()
	if num_cards == 1:
		x_position = FIELD_MAX_WIDTH / 2
	elif num_cards > 1:
		var weight: float = float(card_ui.get_index()) / float(num_cards - 1)
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


func calc_y_pos(_card_ui: CardUI) -> float:
	
	return FIELD_Y_POSITION




# when we want to insert a new card on the field at target position
# this func will take the old array of minions on field and the new card as args
# it will return an int which is the index the new minion should be at
func find_new_card_index(old_array: Array, new_card: CardUI) -> int:
	
	# vars we will use to know which minion should be after the new minion in the array
	var after_minion = null
	
	# take the global x position of the new card
	var target_position_x = new_card.global_position.x
	
	# loop over the cards in the array and compare the x position
	for card_ui in old_array:
		# find the first minion that is after the new minion by x position
		if card_ui.global_position.x >= target_position_x:
			after_minion = card_ui
			break
	
	# this will be the index to place the new card
	var new_card_index
	# if an after minion was found
	if after_minion:
		# the new card will take over the index of the card that was after it
		new_card_index = old_array.find(after_minion)
	# if no after minion was found, the new card is the last card in array
	else:
		new_card_index = old_array.size()
	
	# return the new index
	return new_card_index




# when a new card enters, we want to insert the new card at the right spot
func _on_new_card_in_play(new_card: CardUI) -> void:
	
	var old_array = p_field.get_children()
	
	#
	var new_index = find_new_card_index(old_array, new_card)
	#
	# check if the new card has a parent, and remove it if it does
	# if new_card.get_parent():
		# new_card.get_parent().remove_child(new_card)
	
	# then add it as a child of field
	# p_field.add_child(new_card)
	
	new_card.reparent(p_field, true)
	
	# move it to the new index
	p_field.move_child(new_card, new_index)
	
	# let's try this? it works!
	# new_card.global_position = new_card.get_global_mouse_position() - new_card.pivot_offset
	
