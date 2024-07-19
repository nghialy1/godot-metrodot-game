extends AnimatedSprite2D

@onready var y_offset: int = get_parent().y_offset

func update(_direction: Vector2, _distance: float, _ducking: bool, aim_input_mouse: Vector2) -> void:
	#var duck_offset: int = y_offset if ducking else 0
	#if direction.x != 0 and direction.y != 0:
	#	distance *= 0.70
	#position = direction * distance + Vector2(0, duck_offset)
	position = aim_input_mouse
