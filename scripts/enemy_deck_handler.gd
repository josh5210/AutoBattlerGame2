class_name EnemyDeckHandler
extends CardPile
# THIS IS BASICALLY a copy of deck_handler. I only really made this script 
# so i could put in a different deck for enemy
# there is probably a better way to do this.


# maybe I should make this extend CardPile

# this script is an adaptation of CharacterStats from the tut
# my intention with this script is to handle the creation of the deck, draw pile, discard pile

@export var e_starting_deck: CardPile
@export var cards_per_turn: int
# mana was here in tut

# i dont think I need to make deck and draw_pile a seperate var in my game
var deck: CardPile
var discard: CardPile
#var draw_pile: CardPile

###
func create_instance() -> Resource:
	# create an instance of a deck and return it
	var instance: EnemyDeckHandler = self.duplicate()
	instance.deck = instance.e_starting_deck.duplicate()
	#instance.draw_pile = CardPile.new()
	instance.discard = CardPile.new()
	return instance
