extends Sprite2D

@onready var y_offset: int = get_parent().y_offset

func update(direction: Vector2, distance: float, ducking: bool) -> void:
	var duck_offset: int = y_offset if ducking else 0
	if direction.x != 0 and direction.y != 0:
		distance *= 0.70
	position = direction * distance + Vector2(0, duck_offset)
