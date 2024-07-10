extends Entity

var active := false
var speed := Global.enemy_parameters['drone']['speed']
@onready var player = get_tree().get_first_node_in_group('Player')
signal detonate(pos: Vector2)

func _ready():
	health = Global.enemy_parameters['drone']['health']

func _process(_delta):
	if active:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		move_and_slide()

func _on_player_detection_area_body_entered(_body):
	active = true

func _on_collision_detection_area_body_entered(body):
	if body != self:
		hit(Global.enemy_parameters['drone']['health'], get_sprites())
		if "hit" in body:
			body.hit(Global.enemy_parameters['drone']['damage'], body.get_sprites())
		
func get_sprites():
	return [$AnimatedSprite2D]
	
func trigger_death():
	detonate.emit(global_position)
	free_drone()
	
func free_drone():
	$AnimatedSprite2D.visible = false
	$Timers/InvulTimer.stop()
	call_deferred('disable_collisions')

func disable_collisions():
	$CollisionShape2D.disabled = true
	$CollisionDetectionArea.monitoring = false
	$PlayerDetectionArea.monitoring = false
