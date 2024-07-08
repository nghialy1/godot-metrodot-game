extends CharacterBody2D
class_name Entity

signal shoot(pos, dir, bullet_type)
var health := 100:
	set(value):
		health = value
		if is_in_group('Player'):
			get_tree().get_first_node_in_group('HealthCircle').update(value)
		if health <= 0:
			trigger_death()

func hit(damage, nodes):
	if not $Timers/InvulTimer.time_left:
		health -= damage
		$Timers/InvulTimer.start()
		flash(nodes)

func flash(nodes):
	var tween = create_tween()
	tween.tween_method(set_flash_value.bind(nodes), 0.0, 1.0, 0.1).set_trans(Tween.TRANS_QUAD)
	tween.tween_method(set_flash_value.bind(nodes), 1.0, 0.1, 0.1).set_trans(Tween.TRANS_QUAD)
	
func set_flash_value(value: float, nodes):
	for node in nodes:
		node.material.set_shader_parameter('Progress', value)

func trigger_death():
	pass
	
func setup(data):
	if self.is_in_group('Enemies'):
		position = data[0]
		velocity = data[1]
		health = data[2]
