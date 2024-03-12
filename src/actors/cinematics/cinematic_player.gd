extends CharacterBody3D


@export_group("Internal Node Dependencies")
@export var state_chart: StateChart
@export var animation_player: AnimationPlayer
@export var flaming_orb: Node3D


func _ready() -> void:
	GlobalSignals.game_begin.connect(
		func() -> void:
			state_chart.send_event("GameBegin")
	)
	GlobalSignals.fight_start.connect(
		func() -> void:
			state_chart.send_event("FightStarted")
	)
	GlobalSignals.fight_finished.connect(
		func(player_win: bool) -> void:
			state_chart.send_event("PlayerWon" if player_win else "PlayerLose")
	)


func root_motion_movement(delta: float, move_factor := 1.0) -> void:
	var current_rotation := transform.basis.get_rotation_quaternion()
	velocity = (current_rotation.normalized() * animation_player.get_root_motion_position()) / delta * move_factor


func _physics_process(delta: float) -> void:
	root_motion_movement(delta)
	move_and_slide()


func _on_waiting_state_entered() -> void:
	hide()
	animation_player.play("T-Pose")


func _on_waiting_state_exited() -> void:
	show()


func _on_walking_state_entered() -> void:
	animation_player.play("walking")


func _on_pickup_state_entered() -> void:
	animation_player.play("pick-up")


func _on_transform_state_entered() -> void:
	animation_player.play("transform")
