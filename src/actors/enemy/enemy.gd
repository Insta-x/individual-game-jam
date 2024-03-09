extends CharacterBody3D

class_name Enemy


signal dead

@export var turning_speed := 1.0
@export var walk_speed := 2.0

@export_group("Animation Parameters")
@export var locomotion_transition_speed := 3.0

@export_group("Internal Node Dependencies")
@export var animation_tree: AnimationTree
@export var state_chart: StateChart
@export var hurtbox: Area3D
@export var hitbox_collision: CollisionShape3D
@export var debug_label: Label3D
@export_subgroup("Audio")
@export var parry_sfx: AudioStreamPlayer3D
@export var hit_sfx: AudioStreamPlayer3D

@export_group("External Node Dependencies")
@export var player: Player

var move_vector := Vector2.ZERO
var locomotion_vector := Vector2.ZERO


func animation_tree_travel(new_state: String) -> void:
	animation_tree["parameters/playback"].travel(new_state)


func character_movement() -> void:
	var direction := (transform.basis * Vector3(move_vector.x, 0, move_vector.y)).normalized()
	
	if direction:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)


func root_motion_movement(delta: float, move_factor := 1.0) -> void:
	var current_rotation := transform.basis.get_rotation_quaternion()
	velocity = (current_rotation.normalized() * animation_tree.get_root_motion_position()) / delta * move_factor


func smooth_look_at(delta: float) -> void:
	var target_position := player.transform.origin
	target_position.y = 0
	var new_transform := transform.looking_at(target_position, Vector3.UP)
	transform = transform.interpolate_with(new_transform, turning_speed * delta)


func play_parry_sfx() -> void:
	parry_sfx.pitch_scale = randf_range(0.5, 0.7)
	parry_sfx.play()


#region Observing State
func _on_observing_state_entered() -> void:
	debug_label.text = "Observing"
	
	animation_tree_travel("Move")
	
	# Random Move for the duration
	if randf() > 0.3:
		move_vector = Vector2.LEFT.rotated(randf_range(-PI / 8, PI / 6))
		if randf() > 0.5:
			move_vector.x *= -1
	else:
		move_vector = Vector2.ZERO
	
	# TODO: Proper change state to attacking
	await get_tree().create_timer(randf_range(2, 4)).timeout
	state_chart.send_event("ToClosingIn")


func _on_observing_state_physics_processing(delta: float) -> void:
	smooth_look_at(delta)
	
	character_movement()
	move_and_slide()


func _on_observing_state_processing(delta: float) -> void:
	locomotion_vector = locomotion_vector.move_toward(Vector2(move_vector.x, -move_vector.y), delta * locomotion_transition_speed)
	
	animation_tree.set("parameters/Move/blend_position", locomotion_vector)


func _on_observing_state_exited() -> void:
	pass # Replace with function body.
#endregion


#region Closing In State
func _on_closing_in_state_entered() -> void:
	debug_label.text = "ClosingIn"
	
	animation_tree_travel("Move")
	
	move_vector = Vector2.UP


func _on_closing_in_state_physics_processing(delta: float) -> void:
	smooth_look_at(delta)
	
	character_movement()
	move_and_slide()
	
	if global_position.distance_to(player.global_position) < 1.5:
		state_chart.send_event("ToAttacking")


func _on_closing_in_state_processing(delta: float) -> void:
	locomotion_vector = locomotion_vector.move_toward(Vector2(move_vector.x, -move_vector.y), delta * locomotion_transition_speed)
	
	animation_tree.set("parameters/Move/blend_position", locomotion_vector)


func _on_closing_in_state_exited() -> void:
	pass # Replace with function body.
#endregion


#region Attacking State
func _on_attacking_state_entered() -> void:
	debug_label.text = "Attacking"
	
	animation_tree.set("parameters/Attack/blend_position", randf())
	animation_tree_travel("Attack")
	
	hurtbox.area_entered.disconnect(_on_not_attacking_hurtbox_area_entered)
	hurtbox.area_entered.connect(_on_attacking_hurtbox_area_entered)


func _on_attacking_state_physics_processing(delta: float) -> void:
	root_motion_movement(delta)
	move_and_slide()


func _on_attacking_state_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_attacking_hurtbox_area_entered(area: Area3D) -> void:
	hit_sfx.play()
	state_chart.send_event("ToReacting")


func _on_attacking_state_exited() -> void:
	hitbox_collision.set_deferred("disabled", true)
	
	hurtbox.area_entered.connect(_on_not_attacking_hurtbox_area_entered)
	hurtbox.area_entered.disconnect(_on_attacking_hurtbox_area_entered)
#endregion


#region Blocking State
func _on_blocking_state_entered() -> void:
	animation_tree_travel("block-react")
	play_parry_sfx()
#endregion


#region Reacting State
func _on_reacting_state_entered() -> void:
	animation_tree_travel("react-from-left")
#endregion


func _on_not_attacking_hurtbox_area_entered(area: Area3D) -> void:
	print("ENEMY ATTACKED")
	state_chart.send_event("ToBlocking")
