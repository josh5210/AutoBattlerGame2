extends Node2D

@onready var area_2d: Area2D = $Area2D

var current_card: CardUI
# flag to track if we are in the targeting process
var targeting := false


func _ready() -> void:
	# connect the signals from event bus
	Events.card_drag_started.connect(_on_card_drag_started)
	Events.card_drag_ended.connect(_on_card_drag_ended)


func _process(_delta: float) -> void:
	if not targeting:
		return
	
	# update pos based on mouse
	area_2d.position = get_local_mouse_position()


func _on_card_drag_started(card: CardUI) -> void:
	# make sure it is a card that goes on the field
	if not card.card.targets_player_field():
		# debug print
		# print("card does not target player field")
		return
	
	# start targeting
	targeting = true
	area_2d.monitoring = true
	area_2d.monitorable = true
	# current card is the card passeed on in signal
	current_card = card
	
	# debugging
	# print("now dragging. card target selector active. targeting: " + str(targeting))
	# print("current card:" + str(current_card))


func _on_card_drag_ended(_card: CardUI) -> void:
	# when ending dragging, flags go false
	targeting = false
	# area 2d goes back to topleft corner
	area_2d.position = Vector2.ZERO
	area_2d.monitoring = false
	area_2d.monitorable = false
	current_card = null
	# print vars for debugging
	# print("targeting: " + str(targeting))

# i need to connect on area 2d entered/exited signals.


func _on_area_2d_area_entered(area: Area2D) -> void:
	# make sure we have a card and are targeting
	if not current_card or not targeting:
		# debug
		print("area 2d entered but missing card/targeting")
		return
	
	#debug
	# print("area 2d entered and have card and targeting. checking targets array.")
	# print("area being targeted: " + str(area))
	# print("targets array is: " + str(current_card.targets))
	# when we are properly targeting, check the array of targets
	# if our card's array of targets does not have this enemy
	if not current_card.targets.has(area):
		# debug
		# print("array does not have this target. appending.")
		# append the target to the array
		current_card.targets.append(area)
		
		#
		# print("Targets array is now: " + str(current_card.targets))





func _on_area_2d_area_exited(area: Area2D) -> void:
	# skip func if we don't have a card or not targeting
	if not current_card or not targeting:
		# print("area 2d exited, but we are not targeting.")
		return
	
	
	# debug
	# print("Exiting the area 2d. Area is about to be erased from targets array.")
	# print("Before erasing, targets: " + str(current_card.targets))
	# exiting the area means we are no longer trying to target the enemy
	# so, erase the enemy/area from the targets array
	current_card.targets.erase(area)
	
	# print("After erasing, targets: " + str(current_card.targets))
