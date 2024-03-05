extends CharacterBody3D

class_name Player


signal dead

@export var walk_speed := 2.0

@export_group("Animation Parameters")
@export var locomotion_transition_speed := 3.0

@export_group("Internal Node Dependencies")
@export var animation_tree: AnimationTree
@export var state_chart: StateChart
@export var hurtbox: Area3D

@export_group("External Node Dependencies")
@export var player_pcam: PhantomCamera3D
@export var look_at_target: Node3D

var input_vector := Vector2.ZERO
var locomotion_vector := Vector2.ZERO


#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("die_test"):
		#animation_tree["parameters/playback"].travel("dying")
		#dead.emit()


func set_pcam_rotation() -> void:
	player_pcam.set_third_person_rotation(global_rotation)


func animation_tree_travel(new_state: String) -> void:
	animation_tree["parameters/playback"].travel(new_state)


func root_motion_movement(delta: float) -> void:
	var current_rotation := transform.basis.get_rotation_quaternion()
	velocity = (current_rotation.normalized() * animation_tree.get_root_motion_position()) / delta * walk_speed


#region Moving State
func _on_moving_state_entered() -> void:
	animation_tree_travel("Move")


func _on_moving_state_unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("block"):
		state_chart.send_event("ToBlocking")
		get_viewport().set_input_as_handled()


func _on_moving_state_physics_processing(delta: float) -> void:
	look_at(look_at_target.global_position)
	
	input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
	
	if direction:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)
	
	move_and_slide()


func _on_moving_state_processing(delta: float) -> void:
	locomotion_vector = locomotion_vector.move_toward(Vector2(input_vector.x, -input_vector.y), delta * locomotion_transition_speed)
	set_pcam_rotation()
	animation_tree.set("parameters/Move/blend_position", locomotion_vector)
#endregion


#region Blocking State
func _on_blocking_state_entered() -> void:
	animation_tree_travel("block")
	hurtbox.area_entered.connect(_on_blocking_hurtbox_detected)
	hurtbox.area_entered.disconnect(_on_not_blocking_hurtbox_area_entered)


func _on_blocking_hurtbox_detected(area: Area3D) -> void:
	animation_tree_travel("block-react")


func _on_blocking_state_exited() -> void:
	hurtbox.area_entered.disconnect(_on_blocking_hurtbox_detected)
	hurtbox.area_entered.connect(_on_not_blocking_hurtbox_area_entered)
#endregion


#region Dying State
func _on_dying_state_entered() -> void:
	animation_tree_travel("dying")
	dead.emit()


func _on_dying_state_physics_processing(delta: float) -> void:
	root_motion_movement(delta)
	move_and_slide()
#endregion


func die() -> void:
	state_chart.send_event("ToDying")


func _on_not_blocking_hurtbox_area_entered(area: Area3D) -> void:
	die()
