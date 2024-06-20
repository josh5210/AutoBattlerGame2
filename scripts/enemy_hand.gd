class_name EnemyHand
extends HBoxContainer

# This script uses a lot of the same code as Hand.


# constant for amount of cards that should start in hand at start of battle
const STARTING_HAND_SIZE := 3
# const for having a pause between drawing each card, and discarding
const HAND_DRAW_INTERVAL := 0.25
const HAND_DISCARD_INTERVAL := 0.25


# ref the card ui scene itself so we can instantiate it whenever we draw cards
# @onready var card_ui := preload("res://scenes/card_ui.tscn")
@onready var e_card_ui := preload("res://scenes/enemy_card_ui.tscn")


# ref the deck so we can draw cards from it
# @onready var deck = get_parent().get_node("Deck")
@onready var e_deck: EnemyDeck = %EnemyDeck


# member var for cards played this turn, help keep track of repositioning
var cards_played_this_turn := 0

# the hand sets cards as children
#func _ready() -> void:
	# we wait for the deck to be ready, then draw our starting hand
	# Events.deck_ready.connect(_on_deck_ready)
	# let's try moving this functionality to the battle script to keep things more centralized


func _on_card_ui_reparent_requested(child: CardUI) -> void:
	child.reparent(self)
	# debug
	print("Reparenting card " + str(child) + " to enemy hand.")


# requires card resouce to pass in as param
func add_card(card: Card) -> void:
	# instantiate a new card ui as a child
	
	##### vvv I have to make this instantiate an enemy card ui instead.
	var new_card_ui := e_card_ui.instantiate()
	add_child(new_card_ui)
	# connect reparent signal, set card, parent, char_stats properties
	new_card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)
	new_card_ui.card = card
	# vvvv commented out this line and stuff works, not sure
	#new_card_ui.parent = self
	# enable_hand()



#func test_draw() -> void:
	#add_card(deck.draw_card())


#func _on_deck_ready() -> void:
	
	#draw_hand(STARTING_HAND_SIZE)
	# let's try moving this functionality to the battle script to keep things more centralized


func draw_hand(amount: int) -> void:
	
	var tween := create_tween()
		# loop over cards using amount to draw and interval to wait between draws
	for i in range(amount):
		tween.tween_callback(self.draw_single_card).set_delay(HAND_DRAW_INTERVAL)
	# connect the tweens finished signal to an anon func that emits signal of hand drawn
	tween.finished.connect(
		func(): Events.enemy_hand_drawn.emit()
	)
	


# this func is called by draw_cards, it is needed in order ot make the tween work
func draw_single_card() -> void:
	
	# check that deck is not empty before drawing
	if !e_deck.deck_array.is_empty():
		add_card(e_deck.draw_card())
		# if we just drew the last card, make deck sprite invisible
		if e_deck.deck_array.is_empty():
			e_deck.e_deck_sprite.visible = false
	else:
		print("the enemy deck is empty, hand will not draw")
