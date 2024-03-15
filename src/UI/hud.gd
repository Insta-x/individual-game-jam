extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignals.player_charged.connect(
		func():
			$ControlTexts/VBoxContainer/AttackLabel.show()
	)
	GlobalSignals.game_begin.connect(
		func():
			$ControlTexts/VBoxContainer/AttackLabel.hide()
	)
