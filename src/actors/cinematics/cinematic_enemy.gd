extends CharacterBody3D


@export_group("Internal Node Dependencies")
@export var animation_player: AnimationPlayer


func root_motion_movement(delta: float, move_factor := 1.0) -> void:
	var current_rotation := transform.basis.get_rotation_quaternion()
	velocity = (current_rotation.normalized() * animation_player.get_root_motion_position()) / delta * move_factor


func _physics_process(delta: float) -> void:
	root_motion_movement(delta)
	move_and_slide()
