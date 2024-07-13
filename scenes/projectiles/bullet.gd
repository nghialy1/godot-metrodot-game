extends Area2D

signal detonate(pos: Vector2)

var direction: Vector2
var speed: int
var damage: int
var explosive := false
@export var bullet_speed := 250

func setup(pos, dir, type):
	$AudioStreamPlayer2D.stream = Global.bullet_sounds[type]
	$AudioStreamPlayer2D.play()
	
	position = pos
	direction = dir.normalized()
	
	if type in [Global.guns.AK, Global.guns.ROCKET]:
		$Sprite2D.texture = Global.gun_data[type]['texture']
		speed = Global.gun_data[type]['speed']
		damage = Global.gun_data[type]['damage']
		explosive = type == Global.guns.ROCKET
	else:
		$CollisionShape2D.disabled = true
		$Sprite2D.hide()
		$PointLight2D.hide()
		var enemies = get_tree().get_nodes_in_group('Enemies').filter(func(enemy): return enemy.health > 0)

		for enemy in enemies:
			var bullet_angle = rad_to_deg(dir.angle()) 
			var enemy_angle = rad_to_deg((enemy.position - pos).angle())
			
			print(bullet_angle, " shot at ", enemy_angle, " distance of ", pos.distance_to(enemy.position))
			print(abs(bullet_angle - enemy_angle))
			

			if pos.distance_to(enemy.position) < Global.gun_data[Global.guns.SHOTGUN]['range'] and (abs(bullet_angle - enemy_angle) < 45 or abs(bullet_angle - enemy_angle) > 315):
				enemy.hit(Global.gun_data[Global.guns.SHOTGUN]['damage'], enemy.get_sprites())
		
func _process(delta):
	position += direction * bullet_speed * delta

func _on_body_entered(body):
	detonate.emit(position)
	if 'hit' in body:
		body.hit(damage, body.get_sprites())
	queue_free()

func _on_kill_timer_timeout():
	queue_free()
