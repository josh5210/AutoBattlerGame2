class_name PlayerGY
extends Control

@onready var gy_button = $GYButton
@onready var gy_num_label = $GYNumLabel
@onready var gyv_box = $GYVBox

const DEAD_CARD_SIZE = Vector2(30, 45)



func _ready() -> void:
	# connect the signal emitted by a dead card that is revived
	Events.card_left_gy.connect(_on_card_left_gy)
	# make the box invisible initially
	gyv_box.visible = false
	
	update_gy_num_label()


# func to set the num on gy label equal to num of cards in gy
func update_gy_num_label() -> void:
	
	var gy_count = gyv_box.get_child_count()
	
	gy_num_label.text = str(gy_count)



# the combat handler will tween a dead card towards the gy.
# then it will call this func
func add_card_to_gy(dead_card: CardUI) -> void:
	# call the func to make the components of the card invis
	make_children_invisible(dead_card)
	
	# get the gy texture node of the card
	var in_gy_texture = dead_card.in_gy_texture
	# make that visible
	in_gy_texture.set_visible(true)
	# set the label
	in_gy_texture.get_child(0).text = dead_card.card.name
	
	# change the card's size
	dead_card.set_custom_minimum_size(Vector2(DEAD_CARD_SIZE))
	dead_card.set_size(Vector2(DEAD_CARD_SIZE))
	
	# reparent the card to the vbox
	dead_card.reparent(gyv_box)
	# i can use v this version if i plan to change the position myself
	# dead_card.reparent(gyv_box, true)
	
	# make the img shrink left
	dead_card.set_h_size_flags(Control.SIZE_SHRINK_BEGIN)
	# update the label
	update_gy_num_label()

#"size_flags_horizontal"

# when the button is pressed, alter the visibility of vbox
func _on_gy_button_toggled(_toggled_on):
	
	gyv_box.visible = !gyv_box.visible


# use this func to make all the children of the card invis
func make_children_invisible(node):
	# loop through all the nodes children
	for child in node.get_children():
		# make the ones with a vis property invisible
		if child is Control or child is CanvasItem:
			child.visible = false
		# or use a method if it has one
		elif child.has_method("set_visible"):
			child.set_visible(false)
		# optionally, recursively call this func to make that child's children invis
		# Not needed rn
		# else:
			# make_children_invisible(child)


# func from signal
func _on_card_left_gy(_card_ui) -> void:
	# awkwardly have to wait a tiny bit for the card that sent the signal to be deleted
	get_tree().create_timer(0.1, false).timeout.connect(update_gy_num_label)
	
	# might also have to reorder children so they don't look weird
