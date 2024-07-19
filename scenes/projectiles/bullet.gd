extends Area2D

# bullet can detonate if rocket
signal detonate(pos: Vector2)

var origin : CharacterBody2D
var direction: Vector2
var speed: int
var damage: int
var explosive := false

func setup(pos: Vector2, dir: Vector2, type: int, bullet_origin: CharacterBody2D) -> void:
	$AudioStreamPlayer2D.stream = Global.bullet_sounds[type]
	$AudioStreamPlayer2D.play()
	
	origin = bullet_origin
	position = pos
	direction = dir.normalized()
	rotate(dir.angle())
	
	# shoot bullet
	if type in [Global.guns.AK, Global.guns.ROCKET]:
		$Sprite2D.texture = Global.gun_data[type]['texture']
		speed = Global.gun_data[type]['speed']
		damage = Global.gun_data[type]['damage']
		explosive = type == Global.guns.ROCKET
		
		if bullet_origin.name == 'Monster':
			speed = Global.gun_data['monster_bullets']['speed']
			damage = Global.gun_data['monster_bullets']['damage']
	else:
		$CollisionShape2D.disabled = true
		$Sprite2D.hide()
		$PointLight2D.hide()
		var enemies := get_tree().get_nodes_in_group('Enemies').filter(func(enemy: CharacterBody2D) -> bool: return enemy.health > 0)

		for enemy: CharacterBody2D in enemies:
			var bullet_angle: float = rad_to_deg(dir.angle()) 
			var enemy_angle: float = rad_to_deg((enemy.position - pos).angle())

			if pos.distance_to(enemy.position) < Global.gun_data[Global.guns.SHOTGUN]['range'] and (abs(bullet_angle - enemy_angle) < 45 or abs(bullet_angle - enemy_angle) > 315):
				enemy.hit(Global.gun_data[Global.guns.SHOTGUN]['damage'], enemy.get_sprites())
		
func _process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	detonate.emit(position)
	
	# hit body 
	if 'hit' in body:
		body.hit(damage, body.get_sprites())
	
	# hit other entities that are close
	for entity in get_tree().get_nodes_in_group('Entity'):
		if entity != origin and entity != body and position.distance_to(entity.position) < 25:
			if 'hit' in entity:
				entity.hit(damage, entity.get_sprites())
	
	queue_free()

func _on_kill_timer_timeout() -> void:
	queue_free()
