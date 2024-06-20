class_name BattleDebugLabel
extends Label

# max num of lines to show in the label
const MAX_LINES: int = 5

# create an array var that will store the text of the label
var debug_text_arr: Array[String] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# connect a signal emmited by dead card state
	Events.card_left_gy.connect(_on_card_left_gy)
	Events.card_left_enemy_gy.connect(_on_card_left_enemy_gy)
	# update the array with the initial debug text
	# debug_text_arr.append("Battle Debugging Label\n")
	
	# call the update label func to draw this text.
	update_text("Battle Debugging Label\n")


# this func will clear the label, update the array of strings, then show that array on the label
func update_text(txt: String) -> void:
	
	# clear the label
	self.text = ""
	
	# update the array of strings
	debug_text_arr.append(txt)
	
	# if there are more than MAX_LINES items in the array, delete the oldest one.
	if debug_text_arr.size() > MAX_LINES:
		debug_text_arr.pop_front()
	
	# if there is text in the array
	if !debug_text_arr.is_empty():
		# loop over the text
		for t in debug_text_arr:
			# add it to the label.
			self.text += t


#
func _on_card_left_gy(card_ui) -> void:
	
	var revive_text := "You revived " + str(card_ui.card.name) + "!\n"
	
	update_text(revive_text)


#
func _on_card_left_enemy_gy(ecard_ui) -> void:
	
	var revive_text := "Enemy revived " + str(ecard_ui.card.name) + "!\n"
	
	update_text(revive_text)
