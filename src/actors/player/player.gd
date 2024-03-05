extends CharacterBody3D

class_name Player


signal dead

@export var turning_speed := 1.0
@export var walk_speed := 2.0
@export var attack_move_factor := 5.0

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

var attack_charge := 0


#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("die_test"):
		#animation_tree["parameters/playback"].travel("dying")
		#dead.emit()


func set_pcam_rotation() -> void:
	player_pcam.set_third_person_rotation(global_rotation)


func animation_tree_travel(new_state: String) -> void:
	animation_tree["parameters/playback"].travel(new_state)


func root_motion_movement(delta: float, move_factor := 1.0) -> void:
	var current_rotation := transform.basis.get_rotation_quaternion()
	velocity = (current_rotation.normalized() * animation_tree.get_root_motion_position()) / delta * move_factor


#region Moving State
func _on_moving_state_entered() -> void:
	animation_tree_travel("Move")


func _on_moving_state_unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("block"):
		state_chart.send_event("ToBlocking")
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("attack") and attack_charge >= 5:
		state_chart.send_event("ToAttacking")
		get_viewport().set_input_as_handled()


func _on_moving_state_physics_processing(delta: float) -> void:
	var target_position := look_at_target.transform.origin
	target_position.y = 0
	var new_transform := transform.looking_at(target_position, Vector3.UP)
	transform = transform.interpolate_with(new_transform, turning_speed * delta)
	
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
	attack_charge = clampi(attack_charge + 1, 0, 5)


func _on_blocking_state_exited() -> void:
	hurtbox.area_entered.disconnect(_on_blocking_hurtbox_detected)
	hurtbox.area_entered.connect(_on_not_blocking_hurtbox_area_entered)
#endregion


#region Attacking State
func _on_attacking_state_entered() -> void:
	animation_tree_travel("jump-attack")
	attack_charge = 0


func _on_attacking_state_physics_processing(delta: float) -> void:
	root_motion_movement(delta, attack_move_factor)
	move_and_slide()
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
