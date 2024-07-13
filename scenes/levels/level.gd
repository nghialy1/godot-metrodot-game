extends Node2D
class_name level_template

const explosion_scene := preload("res://scenes/projectiles/explosion.tscn")
const bullet_scene := preload("res://scenes/projectiles/bullet.tscn")
@onready var cam = get_tree().get_first_node_in_group('Player').get_cam()
@export var cam_limits: Vector4i
@onready var player = get_tree().get_first_node_in_group('Player')
var disable_cam := false

func _ready():
	cam.limit_left = cam_limits.x
	cam.limit_right = cam_limits.y
	cam.limit_top = cam_limits.z
	cam.limit_bottom = cam_limits.w
	
	var scene_name = get_tree().current_scene.name
	for i in $Main/Entities.get_child_count():
		var entity = $Main/Entities.get_child(i)
		if entity.has_signal('shoot'):
			entity.connect('shoot', create_bullet)
			
		if entity.has_signal('detonate'):
			entity.connect('detonate', create_explosion)
			
		if scene_name in Global.enemy_data:
			entity.setup(Global.enemy_data[scene_name][i])
	
	if scene_name in Global.player_data:
		player.setup(Global.player_data[scene_name])

func _process(_delta):
	if not disable_cam:
		$CutsceneCamera2D.global_position = player.position

func create_bullet(pos, dir, bullet_type, origin):
	var bullet = bullet_scene.instantiate()
	
	# bullet cant hit entites of itself
	bullet.collision_mask = origin.collision_layer ^ bullet.collision_mask 
	
	# player layer is 0 when dashing 
	if origin == player:
		bullet.set_collision_mask_value(2, false)
	
	$Main/Projectiles.add_child(bullet)
	bullet.setup(pos, dir, bullet_type)
	
	# shooting rocket
	if bullet_type == Global.guns.ROCKET:
		bullet.connect('detonate', create_explosion)

func create_explosion(pos):
	var explosion = explosion_scene.instantiate()
	$Main/Projectiles.add_child(explosion)
	explosion.position = pos

@warning_ignore("unassigned_variable")
func _exit_tree():
	# enemy persistance
	var current_enemy_data: Array
	for entity in $Main/Entities.get_children():
		current_enemy_data.append([entity.position, entity.velocity, entity.health])
	Global.enemy_data[get_tree().current_scene.name] = current_enemy_data
	
	# closest player return position for the scene
	var closest := Vector2(INF, INF)
	
	# player persistance
	for gate in $TransitionGates.get_children():
		# for each gate
		var dist_gate = player.position.distance_to(gate.current_return.global_position)
		var dist_closest = player.position.distance_to(closest)
		if dist_gate < dist_closest:
			closest = gate.current_return.global_position
	
	# save player data for scene
	Global.player_data[get_tree().current_scene.name] = [closest, player.velocity, player.health]
