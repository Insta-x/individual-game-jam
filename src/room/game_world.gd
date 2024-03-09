extends Node3D

class_name GameWorld


@export var debug_displays: Array[Control] = []

@export_group("Actors")
@export var player: Player
@export var enemy: Enemy

@export_group("Start Markers")
@export var player_start: Marker3D
@export var enemy_start: Marker3D

@onready var bounce_animation_player: AnimationPlayer = $BouncingBall/AnimationPlayer
@onready var water_plane: MeshInstance3D = $WaterPlane
@onready var simulation: SubViewport = $Simulation

var debug_showing: int = 0


func _ready() -> void:
	bounce_animation_player.play("bounce")
	
	# Don't know why must set in code. Godot 4 bug.
	water_plane.mesh.surface_get_material(0).set_shader_parameter('simulation_texture', simulation.get_texture())


func reset_actors() -> void:
	player.global_transform = player_start.global_transform
	enemy.global_transform = enemy_start.global_transform
