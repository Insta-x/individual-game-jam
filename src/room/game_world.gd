extends Node3D


@export var debug_displays: Array[Control] = []

@onready var bounce_animation_player: AnimationPlayer = $BouncingBall/AnimationPlayer
@onready var water_plane: MeshInstance3D = $WaterPlane
@onready var simulation: SubViewport = $Simulation

var debug_showing: int = 0


func _ready() -> void:
	bounce_animation_player.play("bounce")
	
	# Don't know why must set in code. Godot 4 bug.
	water_plane.mesh.surface_get_material(0).set_shader_parameter('simulation_texture', simulation.get_texture())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_display"):
		debug_displays[debug_showing].hide()
		debug_showing = (debug_showing + 1) % debug_displays.size()
		debug_displays[debug_showing].show()
	
	if event.is_action_pressed("hide_debug"):
		for debug_display in debug_displays:
			debug_display.hide()


