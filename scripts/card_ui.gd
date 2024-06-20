class_name CardUI
extends Control

signal reparent_requested(which_card_ui: CardUI)

# adding in the setter func here, the card_ui setter should be called when
# instantiating a new card, like when drawing them at start of game
@export var card: Card : set = _set_card


@onready var hand_texture: TextureRect = $InHandTexture
@onready var in_play_texture: TextureRect = $InPlayTexture
# icon of card in gy, will set to a smaller version of inplay pic
@onready var in_gy_texture: TextureRect = $InGYTexture

@onready var color: ColorRect = $CardColor
@onready var card_state_machine: CardStateMachine = $CardStateMachine as CardStateMachine
@onready var drop_point_detector: Area2D = $DropPointDetector

@onready var targets: Array[Node] = []

# Strength Label! Strength of card, this should be updated whenever str changes
@onready var strength_label: Label = $StrengthLabel
@onready var health_label: Label = $HealthLabel

# LABELs for debugging what state card is in
@onready var state_label: Label = $StateLabel
@onready var enabled_label: Label = $EnabledLabel

# member flag to keep track of card has been put in play yet
# with setter func
var card_played := false : set = _set_card_played

# other cards disabled when we are dragging one card, and when we end turn
var disabled := true
##### ^ this disabled may need to go back to false initially
# edit 6/11/24: changing where we use strength.
# strength should be stored and used for battle calculations at the card_ui level
# str is set when card_ui instantiated in _set_card
var strength := 9999
var max_strength := 9999
var health := 9999
var max_health := 9999

var can_attack: bool

# simple setter func that sets card to played when called
# calling this func in released state
func _set_card_played(value: bool) -> void:
	# card is played when true, in hand when false
	card_played = value
	# debug
	print("Card: " + str(self) + "set to card_played value: " + str(card_played))


func _ready() -> void:
	# initialize state machine
	card_state_machine.init(self)
	
	# connect to player_turn_ended signal, so we can use that to update label
	Events.player_turn_ended.connect(_on_player_turn_ended)
	Events.player_hand_drawn.connect(_on_player_hand_drawn)


func _input(event: InputEvent) -> void:
	card_state_machine.on_input(event)


func _on_gui_input(event: InputEvent) -> void:
	card_state_machine.on_gui_input(event)


func _on_mouse_entered() -> void:
	card_state_machine.on_mouse_entered()


func _on_mouse_exited() -> void:
	card_state_machine.on_mouse_exited()


func _on_drop_point_detector_area_entered(area: Area2D) -> void:
	# check if the targets array has this area already
	if not targets.has(area):
		# if not, append it
		targets.append(area)
		# debug print
		# print("Target added. Targets: " + str(targets))


# signal func for when we exit an area (no longer hovering over it as target)
func _on_drop_point_detector_area_exited(area: Area2D) -> void:
	# erase the area from the array of targets
	# debug prints
	# print("Target area " + str(area) + "is being erased from targets array")
	targets.erase(area)
	# print("Targets array is now: " + str(targets))


# func play() -> void:
	# safety check to make sure what we played is type card
	# if not card:
		#return


# set the card. this func is called when new card_uis are instantiated.
func _set_card(value: Card) -> void:
	# wait for node to be ready
	if not is_node_ready():
		await ready
	# change the card property, cost, icon
	##### note
	# if the value is null, we tried to draw from an empty deck, so just return
	if value == null:
		# debug
		print("invalid card drawn or created, returning from _set_card func.")
		return
	
	card = value
	
	# set pic for hand and field
	hand_texture.texture = card.in_hand_pic
	in_play_texture.texture = card.in_play_pic
	# edit 6/11/24: changing where we use strength.
	# strength should be stored and used for battle calculations at the card_ui level
	max_strength = card.max_strength
	strength = card.strength
	max_health = card.max_health
	health = card.health
	
	can_attack = card.can_attack
	
	# set the gy icon to be a smaller version of the in play pic
	# size will be changed by gy script
	in_gy_texture.texture = in_play_texture.texture
	
	# update the card_ui's str label to reflect the str of the card
	# strength_label.text = str(card.strength)
	# made a function for this
	update_strength_label()
	update_health_label()


# func to update the label that displays whether a card is disabled
func update_enabled_label(_value: CardUI) -> void:
	enabled_label.text = "disabled = %s" % disabled


# func connecting to signal of player turn ending, this will just update labels
func _on_player_turn_ended() -> void:
	
	update_enabled_label(self)



# func connecting to signal of player hand drawn, this will just update labels
func _on_player_hand_drawn() -> void:
	
	update_enabled_label(self)


# function to update the strength label in UI to reflect the actual
# str value of the card.
# it might make sense to change this to take an argument of CardUI in the future, like the update_enabled_label
func update_strength_label() -> void:
	
	strength_label.text = str(strength)
	
	# if str is less than 0, visually it will show as 0
	if strength < 0:
		strength_label.text = "0"


func update_health_label() -> void:
	
	health_label.text = str(health)
	
	if health < 0:
		health_label.text = "0"
