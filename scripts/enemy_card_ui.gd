class_name EnemyCardUI
extends Control

# this script is adapted from CardUI. Most of the functionality from there
# isn't needed rn in enemy cards, so I commented a lot out.


signal reparent_requested(which_card_ui: EnemyCardUI)

# adding in the setter func here, the card_ui setter should be called when
# instantiating a new card, like when drawing them at start of game
@export var card: Card : set = _set_card

# @onready var in_gy_texture: TextureRect = $EInGYTexture
@onready var hand_texture: TextureRect = $EInHandTexture
@onready var in_play_texture: TextureRect = $EInPlayTexture
@onready var in_gy_texture: TextureRect = $EInGYTexture

@onready var color: ColorRect = $ECardColor

@onready var strength_label: Label = $StrengthLabel
@onready var health_label: Label = $HealthLabel
@onready var strength_icon = $StrengthIcon
@onready var health_icon = $HealthIcon
# icons and labels for (positive) status effects
@onready var se_icon_1 = $SEIcon1
@onready var se_label_1 = $SEIcon1/SELabel1
@onready var se_icon_2 = $SEIcon2
@onready var se_label_2 = $SEIcon2/SELabel2
@onready var se_icon_3 = $SEIcon3
@onready var se_label_3 = $SEIcon3/SELabel3
# vbox that will hold bad effect icons
@onready var bad_effect_vbox = $BadEffectVBox

# preload icons for status effects. NOTE: I have to update this spot whenever I want to add soemehting new
# for POISON
const FLASK_FULL_ICON = preload("res://art/icons/flask_full.png")
# for BLOCK
const SHIELD_ICON = preload("res://art/icons/shield.png")
# for IGNITE
const FIRE_ICON = preload("res://art/icons/fire.png")

# preload the bad effect icon scene to be used when poisoned/etc.
const BAD_EFFECT_ICON_SCENE = preload("res://scenes/bad_effect_icon.tscn")


@onready var enemy_deck = get_tree().get_first_node_in_group("enemy_deck") as EnemyDeck


# member flag to keep track of card has been put in play yet
# with setter func
var card_played := false : set = _set_card_played


# edit 6/11/24: changing where we use strength.
# strength should be stored and used for battle calculations at the card_ui level
# str is set when card_ui instantiated in _set_card
var strength := 9999
var max_strength := 9999
var health := 9999
var max_health := 9999

var can_attack: bool

###### status effect stuff
# create_status_effect_dict() will return and assign this
var status_effects: Dictionary

# NOTE: bools to be referenced that tell if a card has a certain native status effect
# these will be set by set_se_bools()
var is_blocker := false
var is_poisoner := false
var is_igniter := false

# when a card is damaged by a poisoner, this value is changed
var poisoned_for_amount := 0

#######


# simple setter func that sets card to played when called
# calling this func in released state
func _set_card_played(value: bool) -> void:
	# card is played when true, in hand when false
	card_played = value
	# debug
	print("Card: " + str(self) + "set to card_played value: " + str(card_played))


func _ready() -> void:
	
	pass



# set the card. this func is called when new card_uis are instantiated.
func _set_card(value: Card) -> void:
	# wait for node to be ready
	if not is_node_ready():
		await ready
	# if the value is null, we tried to draw from an empty deck, so just return
	if value == null:
		# debug
		print("invalid card drawn or created, returning from _set_card func.")
		return
	
	card = value
	
	# set pic for hand and field
	# hand_texture.texture = card.in_hand_pic
	in_play_texture.texture = card.in_play_pic
	
	max_strength = card.max_strength
	strength = card.strength
	max_health = card.max_health
	health = card.health
	
	can_attack = card.can_attack
	# in gy text will be smalelr version of inplay text
	in_gy_texture.texture = in_play_texture.texture
	# update the str label
	update_strength_label()
	update_health_label()
	
	# func that will take SE values from card and organize it as dict
	status_effects = create_status_effect_dict(value)
	
	# debug:
	# print("\nCard " + card.name + " instantiated with SE dict:")
	# print(str(status_effects) + "\n")
	
	# func that will update the SE visuals
	update_status_effect_visuals()
	# func to set the boolean values of which native SE card has
	set_se_bools()
	# these were moved to above func
	# set the card as a blocker if it is
	#if status_effects.has("BLOCK"):
		#is_blocker = true
	#if status_effects.has("POISON"):
		#is_poisoner = true


# func called by _set_card that just sets the native SE bools
# NOTE: should be updated when adding a new SE to the game
func set_se_bools() -> void:
	if status_effects.has("BLOCK"):
		is_blocker = true
	
	if status_effects.has("POISON"):
		is_poisoner = true
	
	if status_effects.has("IGNITE"):
		is_igniter = true



# function to update the strength label in UI to reflect the actual
# str value of the card.
func update_strength_label() -> void:
	
	strength_label.text = str(strength)
	
	# if str is less than 0, visually it will show as 0
	if strength < 0:
		strength_label.text = "0"


func update_health_label() -> void:
	
	health_label.text = str(health)
	
	if health < 0:
		health_label.text = "0"



func create_status_effect_dict(mycard: Card) -> Dictionary:
	var return_dict := {}
	
	if mycard.status_effect_one != Card.NativeStatusEffect.NONE:
		return_dict[Card.NativeStatusEffect.keys()[mycard.status_effect_one]] = mycard.s_e_value_one
	if mycard.status_effect_two != Card.NativeStatusEffect.NONE:
		return_dict[Card.NativeStatusEffect.keys()[mycard.status_effect_two]] = mycard.s_e_value_two
	if mycard.status_effect_three != Card.NativeStatusEffect.NONE:
		return_dict[Card.NativeStatusEffect.keys()[mycard.status_effect_three]] = mycard.s_e_value_three
	return return_dict




# we have to update positions of icons and labels on card when it goes in play
# calling from enemyturnhandler
# I guess the enemy cards don't really change size
func update_icon_and_label_positions() -> void:
	# str in bottom left
	strength_icon.set_position(Vector2(0, self.size.y - 60))
	strength_label.set_position(Vector2(0, self.size.y - 60))
	# health in bottom right
	health_icon.set_position(Vector2(self.size.x - 60, self.size.y - 60))
	health_label.set_position(Vector2(self.size.x - 60, self.size.y - 60))
	# SE icons in top left
	se_icon_1.set_position(Vector2(0, 0))
	se_icon_2.set_position(Vector2(0, 60))
	se_icon_3.set_position(Vector2(0, 120))


# the goal of this func is to update the icons and labels
# to accuarately reflect the status effects of the card
func update_status_effect_visuals() -> void:
	# set them invisible initially
	se_icon_1.visible = false
	se_icon_2.visible = false
	se_icon_3.visible = false
	
	if status_effects.size() == 0:
		return
	
	if status_effects.size() >= 1:
		set_se_icon(se_icon_1, 1)
	
	if status_effects.size() >= 2:
		set_se_icon(se_icon_2, 2)
	
	if status_effects.size() >= 3:
		set_se_icon(se_icon_3, 3)
	
	if status_effects.size() >= 4:
		print("error in update_status_effect_visuals, SE size shouldn't be >= 4")



# Func to set an icon pic, make it visible and set it's label correctly
# NOTE: this func will have to be updated when adding new SE
func set_se_icon(icon, num) -> void:
	# it has to be num - 1 bc arrays from 0 
	if status_effects.keys()[num - 1] == "POISON":
		icon.texture = FLASK_FULL_ICON
	
	elif status_effects.keys()[num - 1] == "BLOCK":
		icon.texture = SHIELD_ICON
	
	elif status_effects.keys()[num - 1] == "IGNITE":
		icon.texture = FIRE_ICON
	
	icon.visible = true
	
	# set the number on the label
	var se_label = icon.get_child(0)
	se_label.text = str(status_effects.values()[num - 1])


# this func should be called when a card is first affected by a poison, etc.
func instantiate_bad_effect_icon(effect_type, amount) -> void:
	
	# instantaite the scene
	var icon = BAD_EFFECT_ICON_SCENE.instantiate()
	var label = icon.get_node("BadEffectLabel")
	
	# add the scene as a child of the vbox
	bad_effect_vbox.add_child(icon)
	
	
	# NOTE: new bad effects added will need their icons to be updated here
	if effect_type == "POISON":
		icon.texture = FLASK_FULL_ICON
	# debug message
	else:
		print("instantiate_bad_effect_icon failed, unknown effect type/missing icon")
	
	# update label
	label.text = str(amount)


func update_bad_effect_icon(effect_type, amount) -> void:
	# save an array of the vbox children
	var active_bad_effects = bad_effect_vbox.get_children(false)
	
	# icon to look for while looping over children
	var check_for_icon
	# NOTE: new effect types will have to be updated here
	if effect_type == "POISON":
		check_for_icon = FLASK_FULL_ICON
	
	# loop and see if what we are updating already exists
	for icons in active_bad_effects:
		# if we find the right icon
		if icons.texture == check_for_icon:
			# then we can update it's label
			icons.get_child(0).text = str(int(icons.get_child(0).text) + amount)
			# if this update brought the effect's value to 0
			if int(icons.get_child(0).text) <= 0:
				# remove it
				icons.queue_free()
			# and return from the func
			return
	
	# if we didn't find the icon, instantiate it instead.
	instantiate_bad_effect_icon(effect_type, amount)
