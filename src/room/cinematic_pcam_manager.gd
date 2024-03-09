extends Node


@export var entrance_pcam: PhantomCamera3D
@export var die_pcam: PhantomCamera3D
@export var cinematic_anim: AnimationPlayer


func _ready() -> void:
	GlobalSignals.fight_start.connect(on_fight_start)
	GlobalSignals.fight_finished.connect(on_fight_finished)


func lose_cinematic() -> void:
	cinematic_anim.play("player_lose")


func on_fight_start() -> void:
	entrance_pcam.set_priority(0)


func on_fight_finished(player_win: bool) -> void:
	if player_win:
		pass
	else:
		lose_cinematic()
