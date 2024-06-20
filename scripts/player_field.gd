class_name PlayerField
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# cards on the field are can't be moved while disabled.
# We call this func to disable them when it isn't player turn.
func disable_field() -> void:
	for child in get_children():
		
		if child is CardUI:
			child.disabled = true


# cards can move again, called when starting player turn.
func enable_field() -> void:
	for child in get_children():
		
		if child is CardUI: 
			child.disabled = false
