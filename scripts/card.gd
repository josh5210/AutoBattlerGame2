class_name Card
extends Resource

# these enums are accessed in code e.g.
# "if card.type == 1" -> tests if card is COMMAND
# don't change the order of these
enum Type {MINION, COMMAND}
enum Target {PLAYER_FIELD}

# enum for (beneficial) status effects a card (minion) has.
enum NativeStatusEffect {NONE, POISON, BLOCK, IGNITE}


@export_group("Card Attributes")
@export var id: String
@export var name: String
@export var type: Type
@export var target: Target
@export var max_strength: int
@export var strength: int
@export var max_health: int
@export var health: int
# new bool, will change based on if card on field can attack.
@export var can_attack: bool
# string description, for commands describes effect
@export_multiline var description: String

@export_group("Card Status Effects")
@export var status_effect_one: NativeStatusEffect
@export var s_e_value_one: int
@export var status_effect_two: NativeStatusEffect
@export var s_e_value_two: int
@export var status_effect_three: NativeStatusEffect
@export var s_e_value_three: int

@export_group("Card Visuals")
@export var in_hand_pic: Texture
@export var in_play_pic: Texture
# command cards will have smaller pic
@export var command_pic: Texture

# Some cards, like commands, will require certain game states to play
# e.g. gravegidding requires at least 1 minion in own GY
# NOTE: this category should be updated for new cards if needed
@export_group("Requirements to Play")
# let the command handler know how many conditions to check for
@export var number_of_special_conditions: int
@export var min_minions_in_own_gy: int

# This list might get long but I think categorizing effects will be better than doing
# every new card individually
@export_group("Card Effects")
# return x random minions from gy to deck
@export var revive_x: int



func targets_player_field() -> bool:
	return target == Target.PLAYER_FIELD
