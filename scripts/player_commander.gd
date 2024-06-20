class_name PlayerCommander
extends Node2D

# export a var for max hp
@export var max_health := 30
var current_health: int

# reference life node for updating hp label
@onready var life_label = $CommanderColor/Life
# ref summon star to update after 1 sum
@onready var summon = $CommanderColor/Summon

# export a bool of can summon. get and setter func that changes the icon color when used
# can_summon is set to true at the start of player turn by Battle node.
# Hand 
@export var can_summon := true:
	get:
		return can_summon
	set(value):
		# change color
		if value:
			summon.set_modulate(Color(1, 1, 1, 1))
		else:
			summon.set_modulate(Color(0, 0, 0, 1))
		# change bool value
		can_summon = value


func _ready():
	
	# set initial health
	current_health = max_health
	
	# update label
	update_label()
	
	# connect the signal
	Events.damage_player_commander.connect(_on_damage_player_commander)





func _on_damage_player_commander(damage: int) -> void:
	
	# debug print
	print("_on_damage_player_commander: taking " + str(damage) + " damage.")
	
	current_health -= damage
	update_label()
	# check for game over
	if current_health <= 0:
		player_dead()


func update_label() -> void:
	if current_health <= 0:
		life_label.text = "0"
	else:
		life_label.text = str(current_health)


func player_dead() -> void:
	
	print("You died!")
