extends CanvasLayer


func _ready() -> void:
	$ColorRect.modulate = Color(0,0)

func change_scene(scene_path: String) -> void:
	get_tree().get_first_node_in_group('Player').block_movement()
	var tween := create_tween()
	tween.tween_property($ColorRect, 'modulate', Color(0,1), 0.5)
	tween.tween_callback(Callable(self, 'open_scene').bind(scene_path))
	tween.tween_property($ColorRect, 'modulate', Color(0,0), 0.5)

func open_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
