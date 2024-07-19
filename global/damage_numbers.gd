extends Node

func display_number(value: int, pos: Vector2, is_critical: bool = false) -> void:
	var number := Label.new()
	number.global_position = pos
	number.text = str(value)
	number.z_index = 10
	number.label_settings = LabelSettings.new()
	
	var color : Color = '#FFF'
	if is_critical:
		color = Color.ORANGE_RED
	if value == 0:
		color = Color.DARK_GRAY
	
	number.scale = Vector2(0.01,0.01)
	number.label_settings.font_color = color
	number.label_settings.font_size = 650
	number.light_mask = 2
	
	call_deferred("add_child", number)
	
	await number.resized
	#number.pivot_offset = Vector2(number.size / 2)
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(number, 'position:y', number.position.y - 10, 0.2)
	tween.tween_property(number, 'position:x', number.position.x + 10, 0.4)
	tween.tween_property(number, 'position:y', number.position.y - 8, 0.2).set_delay(0.2)
	tween.tween_property(number, 'modulate:a', 0.0, 0.25).set_delay(0.6)
	
	await tween.finished
	number.queue_free()
