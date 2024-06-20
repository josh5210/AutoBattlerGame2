class_name EnemyField
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# connect to the signal that comes when a card is parented to enemy field.
	Events.enemy_card_played.connect(_on_enemy_card_played)
	



#
func _on_enemy_card_played() -> void:
	
	# emit a signal to the e repo
	# actually, just going to direct a signal from the enemyturnhandler to the erepo
	
	pass
