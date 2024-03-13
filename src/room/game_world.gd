extends Node3D

class_name GameWorld


@export var debug_displays: Array[Control] = []

@export_group("Actors")
@export var player: Player
@export var enemy: Enemy
@export var cinematic_player: CharacterBody3D
@export var cinematic_enemy: CharacterBody3D

@export_group("Start Markers")
@export var player_start: Marker3D
@export var enemy_start: Marker3D
@export var cinematic_player_start: Marker3D
@export var cinematic_enemy_start: Marker3D
@export var cinematic_player_win: Marker3D
@export var cinematic_enemy_win: Marker3D

@onready var water_plane: MeshInstance3D = $WaterPlane
@onready var simulation: SubViewport = $Simulation

var debug_showing: int = 0


func _ready() -> void:
	# Don't know why must set in code. Godot 4 bug.
	water_plane.mesh.surface_get_material(0).set_shader_parameter('simulation_texture', simulation.get_texture())
	game_reset()


func game_reset() -> void:
	GlobalSignals.game_begin.emit()
	reset_actors()


func win_actors_position() -> void:
	cinematic_player.global_transform = cinematic_player_win.global_transform
	cinematic_enemy.global_transform = cinematic_enemy_win.global_transform
	
	player.hide()
	enemy.hide()
	cinematic_enemy.show()
	cinematic_player.show()


func reset_actors() -> void:
	player.global_transform = player_start.global_transform
	enemy.global_transform = enemy_start.global_transform
	cinematic_player.global_transform = cinematic_player_start.global_transform
	cinematic_enemy.global_transform = cinematic_enemy_start.global_transform
	
	player.hide()
	enemy.hide()
	cinematic_enemy.show()
	cinematic_player.show()
