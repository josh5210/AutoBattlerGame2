extends Label

# DEBUG SCRIPT FOR SEEING A CARD"S PARENT
####


@onready var card_ui: CardUI = self.get_parent()

# disabling for now.
func DISABLED_process(_delta):
	
	
	self.text = "PARENT: " + str(card_ui.get_parent())
