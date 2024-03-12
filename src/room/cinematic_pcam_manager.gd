extends Node


@export var entrance_pcam: PhantomCamera3D
@export var die_pcam: PhantomCamera3D
@export var anim_player: AnimationPlayer


func _ready() -> void:
	GlobalSignals.game_begin.connect(
		func() -> void:
			anim_player.play("RESET")
			anim_player.play("beginning")
	)
	GlobalSignals.fight_start.connect(on_fight_start)
	GlobalSignals.fight_finished.connect(on_fight_finished)


func win_cinematic() -> void:
	anim_player.play("player_win")


func lose_cinematic() -> void:
	anim_player.play("player_lose")


func on_fight_start() -> void:
	anim_player.play("fight-start")


func on_fight_finished(player_win: bool) -> void:
	if player_win:
		win_cinematic()
	else:
		lose_cinematic()
	
	await anim_player.animation_finished
	
	anim_player.play("beginning")
