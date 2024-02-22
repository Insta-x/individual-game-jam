extends CharacterBody3D


@export var walk_speed := 2.0

@export_group("Animation Parameters")
@export var locomotion_transition_speed := 3.0

@export_group("Node Dependencies")
@export var animation_tree: AnimationTree

var locomotion_vector := Vector2.ZERO


func _process(delta: float) -> void:
	locomotion_vector = locomotion_vector.move_toward(Vector2(velocity.x, -velocity.z), delta * locomotion_transition_speed)
	
	animation_tree.set("parameters/Locomotion/blend_position", locomotion_vector)


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)
	
	move_and_slide()
