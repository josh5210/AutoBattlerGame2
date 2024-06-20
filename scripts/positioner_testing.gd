extends Node2D

@onready var hand = %Hand
@onready var p_field = $UILayer/PField


# Called when the node enters the scene tree for the first time.
func _ready():
	hand.draw_hand(hand.STARTING_HAND_SIZE)


