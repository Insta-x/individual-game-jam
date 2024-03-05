extends MeshInstance3D



func _on_timer_timeout() -> void:
	visible = not visible
	$Area3D/CollisionShape3D.disabled = not visible
