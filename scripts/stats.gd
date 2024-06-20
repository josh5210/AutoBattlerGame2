class_name Stats
extends Resource

## note: I still haven't put this script to use.
# strength is currently assigned by card, instantiated in card_ui, with combat calculated
# by strength instantiated on card_ui


# this script/resource will track stats of the card.
# This is first implemented in ep4 of the tut, refer to that when I fully implement this.
# keeping in mind the tut uses stats differently, for enemies and the player char

# signal to emit when stats change
signal stats_changed

# var for max strength.
@export var max_strength := 1

# var for (current) strength. has a setter func
var strength: int : set = set_strength


func set_strength(value: int) -> void:
	# set the strength, clamped
	### should I allow negative str values?
	strength = clampi(value, 0, max_strength)
	# emit the signal
	stats_changed.emit()



# Create a new instance of this resource 
##
func create_instance() -> Resource:
	var instance: Stats = self.duplicate()
	instance.strength = max_strength
	return instance


func take_damage(damage : int) -> void:
	#
	pass
