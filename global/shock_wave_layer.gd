extends CanvasLayer

func _ready() -> void:
	$ShockWaveRect.material.set_shader_parameter('size', 0.0)
	
	var shock_tween := create_tween()
	shock_tween.tween_property($ShockWaveRect.material, 'shader_parameter/size', 2.0, 0.5)
	await shock_tween.finished
	
	queue_free()

func get_shock_material() -> ShaderMaterial:
	return $ShockWaveRect.material

func calculate_center(cam: Camera2D, target_pos: Vector2, view_port_size: Vector2) -> Vector2:
	var zoomed_view := view_port_size / cam.zoom
	
	var cam_relative_pos : Vector2 = (target_pos - cam.get_screen_center_position()) \
							+ zoomed_view / 2.0
	var ratio : float = zoomed_view.x / zoomed_view.y
	
	var x : float = cam_relative_pos.x / zoomed_view.x
	var y : float = cam_relative_pos.y / zoomed_view.y
	x = (x - 0.5) * ratio + 0.5 # reversing the effect of scaling in shader
	
	return Vector2(x,y)
