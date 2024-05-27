class_name Cheat
extends Node


signal cheat_activated()
signal cheat_deactivated()

const CHEAT_SEQUENCE := [
	"cheat_up",
	"cheat_up",
	"cheat_down",
	"cheat_down",
	"cheat_left",
	"cheat_right",
	"cheat_left",
	"cheat_right",
]

var is_cheat_activated := false
var _cheat_tracker := 0


func _unhandled_input(event: InputEvent) -> void:
	var is_cheat_input := false
	var correct_cheat_input := false
	
	for c in ["cheat_up", "cheat_down", "cheat_left", "cheat_right"]:
		if event.is_action_pressed(c):
			get_viewport().set_input_as_handled()
			is_cheat_input = true
			break
	
	if is_cheat_input:
		if event.is_action_pressed("cheat_up") and CHEAT_SEQUENCE[_cheat_tracker] == "cheat_up":
			_cheat_tracker += 1
			correct_cheat_input = true
		if event.is_action_pressed("cheat_down") and CHEAT_SEQUENCE[_cheat_tracker] == "cheat_down":
			_cheat_tracker += 1
			correct_cheat_input = true
		if event.is_action_pressed("cheat_left") and CHEAT_SEQUENCE[_cheat_tracker] == "cheat_left":
			_cheat_tracker += 1
			correct_cheat_input = true
		if event.is_action_pressed("cheat_right") and CHEAT_SEQUENCE[_cheat_tracker] == "cheat_right":
			_cheat_tracker += 1
			correct_cheat_input = true
	
	if is_cheat_input and not correct_cheat_input:
		_cheat_tracker = 0
	
	if _cheat_tracker == CHEAT_SEQUENCE.size():
		_cheat_tracker = 0
		is_cheat_activated = not is_cheat_activated
		
		if is_cheat_activated:
			cheat_activated.emit()
		else:
			cheat_deactivated.emit()
