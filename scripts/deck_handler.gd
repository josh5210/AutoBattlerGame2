class_name DeckHandler
extends CardPile
# maybe I should make this extend CardPile

# this script is an adaptation of CharacterStats from the tut
# my intention with this script is to handle the creation of the deck, draw pile, discard pile

@export var starting_deck: CardPile
@export var cards_per_turn: int
# mana was here in tut

# i dont think I need to make deck and draw_pile a seperate var in my game
var deck: CardPile
var discard: CardPile
#var draw_pile: CardPile

###
func create_instance() -> Resource:
	# create an instance of a deck and return it
	var instance: DeckHandler = self.duplicate()
	instance.deck = instance.starting_deck.duplicate()
	#instance.draw_pile = CardPile.new()
	instance.discard = CardPile.new()
	return instance
