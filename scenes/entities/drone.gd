extends Entity

var active := false
var speed := Global.enemy_parameters['drone']['speed']
@onready var player = get_tree().get_first_node_in_group('Player')
signal detonate(pos: Vector2)

func _ready():
	health = Global.enemy_parameters['drone']['health']

func _process(_delta):
	if false:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		move_and_slide()

func _on_player_detection_area_body_entered(_body):
	active = true

func _on_collision_detection_area_body_entered(body):
	if body != self:
		detonate.emit(global_position)
		if "hit" in body:
			body.hit(Global.enemy_parameters['drone']['damage'], body.get_sprites())
		queue_free()
		
func get_sprites():
	return [$AnimatedSprite2D]
	
func trigger_death():
	detonate.emit(global_position)
	queue_free()
