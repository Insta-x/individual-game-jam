extends CharacterBody3D


signal dead

@export var walk_speed := 2.0
@export var look_at_target: Node3D

@export_group("Animation Parameters")
@export var locomotion_transition_speed := 3.0

@export_group("Node Dependencies")
@export var animation_tree: AnimationTree
@export var player_pcam: PhantomCamera3D

var input_vector := Vector2.ZERO
var locomotion_vector := Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("die_test"):
		animation_tree["parameters/playback"].travel("dying")
		dead.emit()


func _process(delta: float) -> void:
	locomotion_vector = locomotion_vector.move_toward(Vector2(input_vector.x, -input_vector.y), delta * locomotion_transition_speed)
	
	animation_tree.set("parameters/Locomotion/blend_position", locomotion_vector)


func _physics_process(delta: float) -> void:
	look_at(look_at_target.global_position)
	set_pcam_rotation()
	
	input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
	
	if direction:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)
	
	move_and_slide()


func set_pcam_rotation() -> void:
	player_pcam.set_third_person_rotation(global_rotation)
