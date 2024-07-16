extends Area2D

signal detonate(pos: Vector2)

var homing_target: CharacterBody2D
var speed : float = Global.special_bullet_data['homing_bullet']['speed']
var damage := Global.special_bullet_data['homing_bullet']['damage']
var direction := Vector2.DOWN
var velocity := Vector2.ZERO
var acceleration := 175.0
var origin : CharacterBody2D

func setup(target: CharacterBody2D, pos: Vector2, start_dir: Vector2, bullet_origin: CharacterBody2D) -> void:
	homing_target = target
	position = pos
	origin = bullet_origin
	
	# set initial velocity 
	velocity = start_dir * speed * 4

func _process(delta: float) -> void:
	
	if $TrackTimer.time_left:
		direction = position.direction_to(homing_target.position).normalized()
		velocity = velocity.move_toward(direction*speed, 1200*delta)
	speed += acceleration * delta
	
	position += velocity * delta

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
	detonate.emit(position)
	queue_free()
