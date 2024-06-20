class_name BattleTimer
extends Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# connect the timeout func
	self.timeout.connect(_on_timer_timeout)


# counting func to be called by other nodes
func timer_countdown(seconds: int) -> void:
	
	self.wait_time = seconds
	self.start()


# func to call when time is done counting down.
func _on_timer_timeout():
	
	# emit a signal that timer has finished counting
	Events.battle_timer_finished.emit()
