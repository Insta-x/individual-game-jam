extends CharacterBody3D

class_name Enemy


signal dead

@export var walk_speed := 2.0
@export var look_at_target: Node3D

@export_group("Animation Parameters")
@export var locomotion_transition_speed := 3.0

@export_group("Node Dependencies")
@export var animation_tree: AnimationTree

var input_vector := Vector2.ZERO
var locomotion_vector := Vector2.ZERO


func _process(delta: float) -> void:
	locomotion_vector = locomotion_vector.move_toward(Vector2(input_vector.x, -input_vector.y), delta * locomotion_transition_speed)
	
	animation_tree.set("parameters/Move/blend_position", locomotion_vector)


func _physics_process(delta: float) -> void:
	var target_position := look_at_target.transform.origin
	target_position.y = 0
	var new_transform := transform.looking_at(target_position, Vector3.UP)
	transform = transform.interpolate_with(new_transform, 5.0 * delta)
	
	#input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	#var direction := (transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
	#
	#if direction:
		#velocity.x = direction.x * walk_speed
		#velocity.z = direction.z * walk_speed
	#else:
		#velocity.x = move_toward(velocity.x, 0, walk_speed)
		#velocity.z = move_toward(velocity.z, 0, walk_speed)
	#
	#move_and_slide()
