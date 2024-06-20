extends Label

# DEBUG SCRIPT FOR SEEING CARD STATE
####


@onready var card_ui: CardUI = self.get_parent()

# Disabled.
func DISABLED_process(_delta):
	
	
	self.text = "STATE: " + str(card_ui.card_state_machine.current_state)
