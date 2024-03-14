extends AudioStreamPlayer3D


@export var possible_step_sounds: Array[AudioStream]


func play_sfx() -> void:
	stream = possible_step_sounds.pick_random()
	play()
