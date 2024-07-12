extends CharacterBody2D
class_name Entity
signal shoot(pos, dir, bullet_type)

@onready var level = get_tree().get_current_scene()
var flash_tween: Tween
var dead := false

var health := 100:
	set(value):
		health = value
		if is_in_group('Player'):
			get_tree().get_first_node_in_group('HealthCircle').update(value)
		if health <= 0:
			trigger_death()

func _process(_delta):
	# fell to death
	if position.y > level.cam_limits.w * 2:
		hit(health, [])

func hit(damage, nodes):
	if health > 0:
		health -= damage
		$Hit.play()
		flash(nodes)

func flash(nodes, color = "ffffff"):
	flash_tween = create_tween()
	flash_tween.tween_method(set_flash_value.bind(nodes, color), 0.0, 1.0, 0.1).set_trans(Tween.TRANS_QUAD)
	flash_tween.tween_method(set_flash_value.bind(nodes, color), 1.0, 0.1, 0.1).set_trans(Tween.TRANS_QUAD)
	
func set_flash_value(value: float, nodes, color):
	for node in nodes:
		node.material.set_shader_parameter('ColorParameter', color)
		node.material.set_shader_parameter('Progress', value)

func trigger_death():
	pass
	
func apply_gravity(delta):
	velocity.y += 600 * delta
	
func setup(data):
	if self.is_in_group('Enemies'):
		position = data[0]
		velocity = data[1]
		
		if data[2] <= 0:
			dead = true
			
		health = data[2]
	
	if self.is_in_group('Player'):
		position = data[0]
		velocity = data[1]
		
		if data[2] <= 0:
			dead = true
			
		health = data[2]
		
		
