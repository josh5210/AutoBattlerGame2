class_name BattleUI
extends CanvasLayer

# this script I can use in the future for some UI stuff, like maybe the commander
# This will probably also propegate data that starts in battle node further down the scene tree

@onready var end_turn_button: Button = %EndTurnButton
@onready var battle_debug_label: Label = %BattleDebugLabel

# v I'll just make all the updates to this label in Battle
#@onready var battle_debug_label: Label = $BattleDebugLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	# connect hand drawn signal to func, and button press signal
	Events.player_hand_drawn.connect(_on_player_hand_drawn)
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	
	#battle_debug_label.text += "test string\n"
	#battle_debug_label.text += "test string 2"
	
	# the end turn button should start disabled, can't be pressed until hand is drawn
	end_turn_button.disabled = true


# We don't want to allow the player to end their turn until after they are done drawing their hand
# for the current turn. This will prevent unexpected outcomes
func _on_player_hand_drawn() -> void:
	end_turn_button.disabled = false
	battle_debug_label.text += "Player hand drawn signal recieved.\n"


# when pressing btn
func _on_end_turn_button_pressed() -> void:
	# disable end turn btn so it can't be pressed again until next turn
	end_turn_button.disabled = true
	# emit signal, this signal goes to Battle, where player turn is ended
	Events.player_turn_ended.emit()
	
