extends CharacterBody3D

class_name Player


const ATTACK_CHARGE_NEEDED = 5

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
@export var hitbox_collision: CollisionShape3D
@export var parry_particles: GPUParticles3D
@export var charge_particles: Array[GPUParticles3D]
@export_subgroup("Audio")
@export var parry_sfx: AudioStreamPlayer3D
@export var hit_sfx: AudioStreamPlayer3D

@export_group("External Node Dependencies")
@export var player_pcam: PhantomCamera3D
@export var enemy: Enemy

var input_vector := Vector2.ZERO
var locomotion_vector := Vector2.ZERO

var attack_charge := 0 :
	set(value):
		attack_charge = value
		for i in range(charge_particles.size()):
			if i < attack_charge:
				charge_particles[i].show()
			else:
				charge_particles[i].hide()
		if attack_charge >= ATTACK_CHARGE_NEEDED:
			GlobalSignals.player_charged.emit()

@onready var cheat: Cheat = $Cheat


func _ready() -> void:
	GlobalSignals.fight_start.connect(on_fight_start)
	GlobalSignals.fight_finished.connect(on_fight_finished)


func set_pcam_rotation() -> void:
	player_pcam.set_third_person_rotation(global_rotation)


func animation_tree_travel(new_state: String) -> void:
	animation_tree["parameters/playback"].travel(new_state)


func root_motion_movement(delta: float, move_factor := 1.0) -> void:
	var current_rotation := transform.basis.get_rotation_quaternion()
	velocity = (current_rotation.normalized() * animation_tree.get_root_motion_position()) / delta * move_factor


func smooth_look_at(delta: float) -> void:
	var target_position := enemy.transform.origin
	target_position.y = 0
	var new_transform := transform.looking_at(target_position, Vector3.UP)
	transform = transform.interpolate_with(new_transform, turning_speed * delta)


func play_parry_sfx() -> void:
	parry_sfx.pitch_scale = randf_range(0.5, 0.7)
	parry_sfx.play()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_attack_charge"):
		attack_charge = ATTACK_CHARGE_NEEDED
		get_viewport().set_input_as_handled()


#region Idle State
func _on_idle_state_entered() -> void:
	animation_tree_travel("Move")
	input_vector = Vector2.ZERO
	locomotion_vector = Vector2.ZERO
	animation_tree.set("parameters/Move/blend_position", Vector2.ZERO)
#endregion


#region Moving State
func _on_moving_state_entered() -> void:
	animation_tree_travel("Move")


func _on_moving_state_unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("block"):
		state_chart.send_event("ToBlocking")
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("attack") and attack_charge >= ATTACK_CHARGE_NEEDED:
		state_chart.send_event("ToAttacking")
		get_viewport().set_input_as_handled()


func _on_moving_state_physics_processing(delta: float) -> void:
	smooth_look_at(delta)
	
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
	play_parry_sfx()
	parry_particles.emitting = true
	attack_charge = clampi(attack_charge + 1, 0, 5)


func _on_blocking_state_exited() -> void:
	hurtbox.area_entered.disconnect(_on_blocking_hurtbox_detected)
	hurtbox.area_entered.connect(_on_not_blocking_hurtbox_area_entered)
#endregion


#region Attacking State
func _on_attacking_state_entered() -> void:
	animation_tree_travel("jump-attack")
	if not cheat.is_cheat_activated:
		attack_charge = 0


func _on_attacking_state_physics_processing(delta: float) -> void:
	root_motion_movement(delta, attack_move_factor)
	move_and_slide()


func _on_attacking_state_exited() -> void:
	hitbox_collision.set_deferred("disabled", true)
#endregion


#region Dying State
func _on_dying_state_entered() -> void:
	hitbox_collision.set_deferred("disabled", true)
	animation_tree_travel("dying")
	dead.emit()


func _on_dying_state_physics_processing(delta: float) -> void:
	root_motion_movement(delta)
	move_and_slide()
#endregion


func die() -> void:
	state_chart.send_event("Died")
	GlobalSignals.fight_finished.emit(false)


func on_fight_start() -> void:
	set_pcam_rotation()
	state_chart.send_event("FightStarted")
	attack_charge = 0
	cheat.is_cheat_activated = false


func on_fight_finished(player_win: bool) -> void:
	if player_win:
		state_chart.send_event("Won")


func _on_not_blocking_hurtbox_area_entered(area: Area3D) -> void:
	hit_sfx.play()
	die()


func _on_cheat_cheat_activated() -> void:
	attack_charge = ATTACK_CHARGE_NEEDED
	print("cheat_activated")


func _on_cheat_cheat_deactivated() -> void:
	print("cheat_deactivated")
