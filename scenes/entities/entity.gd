extends CharacterBody2D
class_name Entity

signal shoot(pos: Vector2, dir: Vector2, bullet_type: int, origin: Entity)
signal particles(instance: GPUParticles2D)

@onready var level := get_tree().get_current_scene()
var flash_tween: Tween
var dead := false
var invulnerable := false

var health := 250:
	set(value):
		if not invulnerable:
			health = value
			if is_in_group('Player'):
				get_tree().get_first_node_in_group('HealthCircle').update(value)
			if health <= 0:
				trigger_death()

func _process(_delta: float) -> void:
	# fell to death
	if position.y > level.cam_limits.w * 2:
		hit(health, [])

func hit(damage: int, nodes: Array) -> void:
	if health > 0:
		health -= damage
		$Hit.play()
		flash(nodes)

func flash(nodes: Array, color: Color = Color.WHITE) -> void:
	flash_tween = create_tween()
	flash_tween.tween_method(set_flash_value.bind(nodes, color), 0.0, 1.0, 0.1).set_trans(Tween.TRANS_QUAD)
	flash_tween.tween_method(set_flash_value.bind(nodes, color), 1.0, 0.1, 0.1).set_trans(Tween.TRANS_QUAD)
	
func set_flash_value(value: float, nodes: Array, color: Color) -> void:
	for node: Node2D in nodes:
		node.material.set_shader_parameter('ColorParameter', color)
		node.material.set_shader_parameter('Progress', value)

func trigger_death() -> void:
	pass
	
func apply_gravity(delta: float) -> void:
	velocity.y += 600 * delta
	
func setup(data: Array) -> void:
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
		
		
