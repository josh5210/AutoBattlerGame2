extends Node2D


# battle script will be sort of the central hub of the battle, starting it and such


# reference nodes
@onready var battle_ui: BattleUI = $BattleUI as BattleUI
@onready var hand: Hand = %Hand as Hand
@onready var deck: Deck = %Deck as Deck
@onready var player_field: PlayerField = %PlayerField as PlayerField
@onready var end_turn_button = %EndTurnButton

@onready var enemy_turn_handler: EnemyTurnHandler = $EnemyTurnHandler as EnemyTurnHandler
@onready var enemy_hand: EnemyHand = %EnemyHand as EnemyHand
#@onready var combat_handler: CombatHandler = $CombatHandler
@onready var combat_handler_2: CombatHandler2 = $CombatHandler2

@onready var player_commander = %PlayerCommander
@onready var enemy_commander = %EnemyCommander
@onready var enemy_gy = get_tree().get_first_node_in_group("enemy_gy") as EnemyGY

# debugging things
@onready var battle_debug_label: BattleDebugLabel = %BattleDebugLabel as BattleDebugLabel

@onready var battle_timer: Timer = $BattleTimer
# simple string var to keep track of who goes next.
# it will be "player" or "enemy"
# there should be a better way to do this in the future for sure
var next_phase: String = ""

# I don't have any scripts for PlayerField/EnemyField yet, but I assume I probably will
# in the future once I start getting some code for actual battle to happen
# I assume I will need to reference them here

#@onready var player_field: PlayerField = %PlayerField as PlayerField
#@onready var enemy_field: EnemyField = %EnemyField as EnemyField


# this var is needed to allow/deny reviving
@export var is_player_turn : bool


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# some stuff will probably go here in the future, stuff that needs to happen at the start of the battle
	# maybe some stuff relating to commander, enemy commander, etc.
	
	# might need to connect some signals here
	Events.player_turn_ended.connect(_on_player_turn_ended)
	# Events.player_hand_discarded.connect(player_handler.start_turn)
	
	Events.battle_timer_finished.connect(_on_battle_timer_finished)
	Events.player_hand_drawn.connect(_on_player_hand_drawn)
	
	
	# at the end of battle ready, call start_battle
	start_battle()


# this func can be used in the future, and maybe It will pass some data along with it
func start_battle() -> void:
	battle_debug_label.update_text("Battle Started!\n")
	
	# enemy draws their starting hand
	enemy_hand.draw_hand(enemy_hand.STARTING_HAND_SIZE)
	# draw a starting hand
	hand.draw_hand(hand.STARTING_HAND_SIZE)
	# after this hand is drawn, the player_hand_drawn signal will be emitted
	# we'll use that signal to start the first turn
	
	# start with player turn
	#start_player_turn()


func _on_player_hand_drawn() -> void:
	# when first hand is finished drawing, start first player turn
	# delay a short time so we don't draw immediately
	
	get_tree().create_timer(hand.HAND_DRAW_INTERVAL, false).timeout.connect(start_player_turn)
	
	
	# start_player_turn()


#
func start_player_turn() -> void:
	
	is_player_turn = true
	
	battle_debug_label.update_text("Player turn Started!\n")
	next_phase = "enemy"
	
	# enable cards in hand
	hand.enable_hand()
	# enable cards in field
	player_field.enable_field()
	# draw a card
	hand.draw_single_card()
	# re-enable end turn button
	end_turn_button.disabled = false
	
	# call the setter func to allow a summon
	player_commander.can_summon = true
	



# this func will cause an enemy turn
func start_enemy_turn() -> void:
	# is_player_turn = false
	
	# debug
	print("The enemy will take their turn.")
	battle_debug_label.update_text("Enemy turn started!\n")
	next_phase = "enemey_play_cards"
	
	######### I will add in the stuff needed for the enemy to take their turn later
	
	# enemy draw
	enemy_turn_handler.enemy_draw_card()
	# call the setter func to allow a summon
	enemy_commander.can_summon = true
	
	# i want a lil delay here between the enemy drawing and playing,
	# So it doesn't look like the card just goes into play instantly and is never in hand.
	
	# we will call the battle_timer for a shorter duration.
	# when the timer expires, we'll move to next phase of enemy playing cards
	battle_timer.timer_countdown(1)
	


# this is the phase that happens on enemies turn after they draw, before combat
func enemy_play_cards() -> void:
	# set next phase
	next_phase = "combat"
	
	# if enemy hand is empty and they have a summon, and they have minion in gy, revive
	if enemy_hand.get_child_count() == 0 and enemy_commander.can_summon and enemy_gy.gyv_box.get_child_count() != 0:
		enemy_turn_handler.e_revive_card()
	
	# call the func e_play_card
	# only if they have a card to play, and has a summon
	elif enemy_hand.get_children() != null and enemy_commander.can_summon:
		# enemy play a card
		enemy_turn_handler.e_play_card()
	
	# use the timer to move to combat
	battle_timer.timer_countdown(1)




#
func _on_player_turn_ended() -> void:
	is_player_turn = false
	# disable cards in hand so they can't be played during enemy turn
	hand.disable_hand()
	player_field.disable_field()
	
	battle_debug_label.update_text("Player turn ended.\n")
	# debug
	print("The player's turn has ended.")
	
	next_phase = "enemy_draw"

	# start timer for next phase
	battle_timer.timer_countdown(1)


func start_combat_phase() -> void:
	#
	battle_debug_label.update_text("Combat phase started!\n")
	
	next_phase = "player"
	# emit signal to other nodes
	Events.combat_phase_started.emit()
	
	#############
	# i will call various battle function from here to handle the combat
	
	# here it is, hope this works.
	#combat_handler.combat_started()
	
	# NEW AND IMPROVED COMBAT HANDLER v2 READY FOR DEPLOYMENT YOLO
	combat_handler_2.combat_started()
	
	# wait for the signal that combat is over before going to player turn
	await Events.combat_phase_ended
	
	# For now, for debugging, lets just make a timer to move to next phase
	battle_timer.timer_countdown(1)



# this func is called when the battle timer finishes and emits it's signal
# we will move to the next phase depending on who is in var next_phase
func _on_battle_timer_finished() -> void:
	
	# lets split up the enemy's turn here so we can use the timer
	# to move between the enemy's phases as well.
	
	if next_phase == "enemy_draw":
		start_enemy_turn()
	elif next_phase == "enemey_play_cards":
		enemy_play_cards()
	elif next_phase == "combat":
		start_combat_phase()
	elif next_phase == "player":
		# wait for the signal that combat is over before going to player turn
		# await Events.combat_phase_ended
		start_player_turn()
