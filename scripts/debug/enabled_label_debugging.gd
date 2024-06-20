extends Label

# DEBUG SCRIPT FOR SEEING IF A CARD IS ENABLED
####


@onready var card_ui: CardUI = self.get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
# disabling this for now, rename if needed again
func DISABLED_process(_delta):
	
	
	self.text = "DISABLED: " + str(card_ui.disabled)
	
	# if card_ui.disabled and card_ui.card_state_machine.current_state.DRAGGING:
		# wtf()
	
	if card_ui.disabled:
		self.modulate = Color(1, 0, 1, 1)
	else:
		self.modulate = Color(1, 1, 0, 1)




func wtf() -> void:
	
	print("WTF")
