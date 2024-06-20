class_name EnemyDeck
extends Node2D

# this script combines some functionality from player_handler and battle.gd from the tut
# we make the deck and start drawing


# const for having a pause between drawing each card, and discarding
#const HAND_DRAW_INTERVAL := 0.25
#const HAND_DISCARD_INTERVAL := 0.25


# vars for 3 card piles
var deck: CardPile
var discard: CardPile
#var draw_pile: CardPile

# var that will be deck but as an array of cards
var deck_array: Array[Card] = []

@onready var enemy_hand: EnemyHand = %EnemyHand
# var for the sprite, that gets deleted if running out of cards
#@onready var deck_sprite: Sprite2D = %DeckSprite
@onready var e_deck_sprite = $EDeckControl/EDeckSprite
@onready var number_label = $EDeckControl/NumberLabel

# connect to the DeckHandler resource in inspector, which connects to cardpile resource
@export var enemy_deck_handler: EnemyDeckHandler

func _ready() -> void:
	
	var new_deck: EnemyDeckHandler = enemy_deck_handler.create_instance()
	deck = new_deck.deck
	discard = new_deck.discard
	#draw_pile = new_deck.draw_pile
	
	# call a func to make deck into an array
	make_array(deck)


# func to change a deckhandler deck into an array of cards
func make_array(pile) -> void:
	
	for c in pile.cards:
		deck_array.append(c)
	
	# emit a signal that deck is ready, this will start drawing first hand
	if not enemy_hand.is_node_ready():
		await enemy_hand.ready
	# Events.deck_ready.emit()
	
	# i think i need a signal here for enemy deck ready




# trying to make a func to draw a card from the deck to the hand.
# I Think I will make this return a card and call this func form the hand.
func draw_card() ->  Card:
	# I need this func to pop the first card in the deck, remove it from there, and return it
	
	
	# check if there are still any cards in the deck before drawing
	if !deck_array.is_empty():
		var card = deck_array.pop_front()
		# debug
		print("Drawing card: " + str(card))
		
		update_number_label()
		return card
	
	# else, if deck is empty, run a new func
	# we should be prevented from executing this code by the if statement in the hand script
	else:
		print("DECK EMPTY")
		deck_is_empty()
		# return null, but this could cause errors further up the stack
		return null



#
func deck_is_empty() -> void:
	print("deck is empty func")
	# this



# func to update num label when num of cards in deck changes.
func update_number_label() -> void:
	
	# i should also handle case when deck is empty
	
	# the text of num label is set to the size of the array of teh card pile
	number_label.text = str(deck_array.size())


# func to add a card to deck, called when reviving
func add_card_to_deck(card: Card) -> void:
	# append the card
	deck_array.append(card)
	# update num label
	update_number_label()
	# also call func to shuffle
	shuffle_deck()
	# make the sprite visible again if it wasn't
	e_deck_sprite.visible = true


# shuffle deck
func shuffle_deck() -> void:
	
	deck_array.shuffle()
