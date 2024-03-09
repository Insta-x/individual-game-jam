extends Control


func _ready() -> void:
	GlobalSignals.fight_finished.connect(
		func(_player_win: bool) -> void:
			show()
	)


func _on_fight_button_pressed() -> void:
	GlobalSignals.fight_start.emit()
	hide()


func _on_run_away_button_pressed() -> void:
	get_tree().quit()
