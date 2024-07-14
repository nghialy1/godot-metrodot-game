extends Entity
signal detonate(pos: Vector2, silent: bool)

var active := false
var speed := Global.enemy_parameters['drone']['speed']
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group('Player')
var rng := RandomNumberGenerator.new()
const directions := [-1,1]
var x_direction : int = directions[randi() % 2]

func _ready() -> void:
	health = Global.enemy_parameters['drone']['health']

func _process(_delta: float) -> void:
	if is_on_wall():
			x_direction *= -1
			
	if active:
		var direction := (player.position - position).normalized()
		velocity = direction * speed
	else:
		# idle mode
		velocity.x = x_direction * speed / 3.0
		
	move_and_slide()
	
		
func get_sprites() -> Array:
	return [$AnimatedSprite2D]
	
func trigger_death() -> void:
	if not dead:
		detonate.emit(global_position)
	free_drone()
	
func free_drone() -> void:
	$AnimatedSprite2D.visible = false
	$Timers/InvulTimer.stop()
	call_deferred('disable_collisions')
	dead = true

func disable_collisions() -> void:
	$CollisionShape2D.disabled = true
	$CollisionDetectionArea.monitoring = false
	$PlayerDetectionArea.monitoring = false

func _on_player_detection_area_body_entered(_body: CharacterBody2D) -> void:
	active = true

func _on_player_detection_area_body_exited(_body: CharacterBody2D) -> void:
	velocity = Vector2(0,0)
	active = false
	
func _on_collision_detection_area_body_entered(body: CharacterBody2D) -> void:
	if body != self:
		hit(Global.enemy_parameters['drone']['health'], get_sprites())
		if "hit" in body:
			body.hit(Global.enemy_parameters['drone']['damage'], body.get_sprites())

