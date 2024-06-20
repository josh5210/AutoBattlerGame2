extends Node

# card-related events
signal card_drag_started(card_ui: CardUI)
signal card_drag_ended(card_ui: CardUI)


# signal for drawing hand at start of battle and turn, used by battle_ui
# this will be emitted by deck
signal player_hand_drawn
signal enemy_hand_drawn

# signal for end of player turn, used by battle_ui, associated with end turn button
signal player_turn_ended

# signal for when the deck has been assembled and is ready to draw
signal deck_ready

# signal emitted by battle node for when combat phase starts
signal combat_phase_started

signal combat_phase_ended

# signal emited by timer that it has finished counting down
signal battle_timer_finished

# This signal is emitted by enemy turn handler when the enemy plays a card.
# it will be connected in enemy field.
signal enemy_card_played

# signals emitted from combathandler2 to commanders when they take damage
signal damage_enemy_commander(damage: int)
signal damage_player_commander(damage: int)



# this signal will be emitted when number of children of field changes
# the repositioner will use this to know when to move the cards on the field
signal field_needs_repositioning

# use this signal to let repositioner know to remake array for field
signal new_card_in_play(card_ui: CardUI)

# this signal is emitted by repositioner after field_needs_repositioning is completed.
# it will be used by CombatHandler2 when minions are repositioned mid combat
signal reposition_complete

# hand repo signals
signal hand_reposition_complete
signal hand_needs_repositioning
signal new_card_in_hand

# signals for E repo
signal e_field_needs_repositioning
signal e_new_card_in_play
signal e_reposition_complete

# signal emitted by dead card to let gy know to update label
signal card_left_gy(card_ui: CardUI)
signal card_left_enemy_gy(ecard_ui: EnemyCardUI)
