extends Entity

var x_direction := 1
var speed := Global.enemy_parameters['soldier']['speed']
var speed_modifier := 1
var attack := false
@onready var player: = get_tree().get_first_node_in_group('Player')

func _ready() -> void:
	health = Global.enemy_parameters['soldier']['health']
	
func _process(delta: float) -> void:
	super._process(delta)
	
	apply_gravity(delta)
	if health > 0:
		velocity.x = x_direction * speed * speed_modifier
		check_cliff()
		check_player_distance()
		animate()
		move_and_slide()
	
func check_player_distance() -> void:
	if position.distance_to(player.position) < 120:
		attack = true
		speed_modifier = 0
	else:
		attack = false
		speed_modifier = 1

func animate() -> void:
	$Sprite2D.flip_h = x_direction < 0
	if attack:
		var direction: Vector2 = round((player.position - position).normalized())
		var side := 'right'
		$Sprite2D.flip_h = direction.x < 0
		if direction.y == -1 and direction.x == 0:
			side = 'up'
		elif direction.y == 1 and direction.x == 0:
			side = 'down'
			
		$AnimationPlayer.current_animation = 'shoot_' + side
	else:
		$AnimationPlayer.current_animation = 'run' if x_direction else 'idle'

func _on_wall_check_area_body_entered(_body: Node2D) -> void:
	x_direction *= -1
	
func check_cliff() -> void:
	if x_direction > 0 and not $FloorRays/Right.get_collider():
		x_direction = -1
	if x_direction < 0 and not $FloorRays/Left.get_collider():
		x_direction = 1

func trigger_attack() -> void:
	var dir: Vector2 = (player.position - position).normalized()
	x_direction = int(dir.x)
	shoot.emit(position + dir * 20, dir, Global.guns.AK, self)

func get_sprites() -> Array:
	return [$Sprite2D]

func trigger_death() -> void:
	speed_modifier = 0
	$AnimationPlayer.current_animation = 'death'
	call_deferred("disable_collisions")
	
func disable_collisions() -> void:
	$CollisionShape2D.disabled = true
	
func setup(data: Array) -> void:
	super.setup(data)
	
	# specific entity setup
	speed_modifier = 0
	$AnimationPlayer.stop()
	$Sprite2D.frame = 22
