extends Sprite2D

@onready var player = get_tree().get_first_node_in_group('Player')

func _ready():
	material.set_shader_parameter('alpha', 0.0)
	
func update(value):
	var tween = create_tween()
	tween.tween_property(self, 'material:shader_parameter/alpha', 1.0, 0.1)
	tween.tween_property(self, 'material:shader_parameter/progress', value / 100.0, 0.2)
	tween.tween_property(self, 'material:shader_parameter/alpha', 0.0, 0.4)
