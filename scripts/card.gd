class_name Card
extends Resource

enum Type {MINION}
enum Target {PLAYER_FIELD}

# enum for (beneficial) status effects a card has.
enum NativeStatusEffect {NONE, POISON}


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

@export_group("Card Status Effects")
@export var status_effect_one: NativeStatusEffect
@export var status_effect_two: NativeStatusEffect
@export var status_effect_three: NativeStatusEffect

@export_group("Card Visuals")
@export var in_hand_pic: Texture
@export var in_play_pic: Texture


func targets_player_field() -> bool:
	return target == Target.PLAYER_FIELD
