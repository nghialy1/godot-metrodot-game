extends Node2D
class_name level_template

const explosion_scene := preload("res://scenes/projectiles/explosion.tscn")
const bullet_scene := preload("res://scenes/projectiles/bullet.tscn")
const homing_bullet_scene := preload("res://scenes/projectiles/homing_bullet.tscn")
const shock_wave_scene := preload("res://global/shock_wave_layer.tscn")
@onready var cam : Camera2D = get_tree().get_first_node_in_group('Player').get_cam()
@onready var player := get_tree().get_first_node_in_group('Player')
@export var cam_limits: Vector4i
var disable_cam := false

func _ready() -> void:
	# tidy up
	ControlsHint.visible = false
	GunJumpHint.visible = false
	
	cam.limit_left = cam_limits.x
	cam.limit_right = cam_limits.y
	cam.limit_top = cam_limits.z
	cam.limit_bottom = cam_limits.w
	
	var scene_name := get_tree().current_scene.name
	
	# enemy interactions
	for i in $Main/Entities/Enemies.get_child_count():
		var entity := $Main/Entities/Enemies.get_child(i)
		if entity.has_signal('shoot'):
			entity.connect('shoot', create_bullet)
			
		if entity.has_signal('shoot_homing'):
			entity.connect('shoot_homing', create_homing_bullet)
			
		if entity.has_signal('detonate'):
			entity.connect('detonate', create_explosion)
			
		if entity.has_signal('shock_wave'):
			entity.connect('shock_wave', create_shock_wave)
			
		if scene_name in Global.enemy_data:
			entity.setup(Global.enemy_data[scene_name][i])
	
	# load player data
	if player.has_signal('shoot'):
		player.connect('shoot', create_bullet)
	
	if scene_name in Global.player_data:
		player.setup(Global.player_data[scene_name])
	
	if 'health' in Global.player_data:
		player.health = Global.player_data['health']
		
	if 'current_gun' in Global.player_data:
		player.current_gun = Global.player_data['current_gun']
		
	# load transition gate data
	for i in $TransitionGates.get_child_count():
		if scene_name in Global.transition_gate_data:
			var gate := $TransitionGates.get_child(i)
			gate.setup(Global.transition_gate_data[scene_name][i])

func _process(_delta: float) -> void:
	if not disable_cam:
		$CutsceneCamera2D.global_position = player.position

func create_bullet(pos: Vector2, dir: Vector2, bullet_type: int, origin: CharacterBody2D) -> void:
	var bullet := bullet_scene.instantiate()
	
	# bullet cant hit entites of itself
	bullet.collision_mask = origin.collision_layer ^ bullet.collision_mask 
	
	# player layer is 0 when dashing 
	if origin == player:
		bullet.set_collision_mask_value(2, false)
	
	$Main/Projectiles.add_child(bullet)
	bullet.setup(pos, dir, bullet_type, origin)
	
	# shooting rocket
	if bullet_type == Global.guns.ROCKET:
		bullet.connect('detonate', create_explosion)
		
func create_homing_bullet(pos: Vector2, target: CharacterBody2D, start_dir: Vector2, origin: CharacterBody2D) -> void:
	var homing_bullet := homing_bullet_scene.instantiate()
	homing_bullet.collision_mask = origin.collision_layer ^ homing_bullet.collision_mask
	
	# player layer is 0 when dashing 
	if origin == player:
		homing_bullet.set_collision_mask_value(2, false)
		
	$Main/Projectiles.add_child(homing_bullet)
	homing_bullet.setup(target, pos, start_dir, origin)
	
	homing_bullet.connect('detonate', create_explosion)

func create_explosion(pos: Vector2) -> void:
	var explosion := explosion_scene.instantiate()
	$Main/Projectiles.add_child(explosion)
	explosion.position = pos
	
func create_shock_wave(pos: Vector2) -> void:
	var shock_wave := shock_wave_scene.instantiate()
	var shock_material : ShaderMaterial = shock_wave.get_shock_material()
	var center : Vector2 = shock_wave.calculate_center(cam, pos, get_viewport_rect().size)
	shock_material.set_shader_parameter('center', center)
	$Main/Shockwaves.add_child(shock_wave)

@warning_ignore("unassigned_variable")
func _exit_tree() -> void:
	# enemy persistance
	var current_enemy_data: Array
	for entity in $Main/Entities/Enemies.get_children():
		current_enemy_data.append([entity.position, entity.velocity, entity.health])
	Global.enemy_data[get_tree().current_scene.name] = current_enemy_data
	
	# closest player return position for the scene
	var closest := Vector2(INF, INF)
	var current_gate_data: Array
	
	# player persistance
	for gate in $TransitionGates.get_children():
		current_gate_data.append([gate.locked])
		# for each gate
		var dist_gate: float = player.position.distance_to(gate.current_return.global_position)
		var dist_closest: float = player.position.distance_to(closest)
		if dist_gate < dist_closest:
			closest = gate.current_return.global_position
	
	# save player data for scene
	Global.player_data[get_tree().current_scene.name] = [closest, player.velocity, player.health]
	Global.player_data['health'] = player.health
	Global.player_data['current_gun'] = player.current_gun
	
	# save transition gate data
	Global.transition_gate_data[get_tree().current_scene.name] = current_gate_data

## TEMPORARY IMPLEMENTATION
## STATION LEVEL
func _on_area_2d_body_entered(_body: CharacterBody2D) -> void:
	await get_tree().create_timer(0.75).timeout
	var hint_box := ControlsHint.get_child(0)
	hint_box.modulate.a = 0.0
	var fade_tween := create_tween()
	fade_tween.tween_property(hint_box, 'modulate:a', 1.0, 1.0)
	ControlsHint.visible = true

func _on_area_2d_body_exited(_body: CharacterBody2D) -> void:
	var hint_box := ControlsHint.get_child(0)
	hint_box.modulate.a = 1.0
	var fade_tween := create_tween()
	fade_tween.tween_property(hint_box, 'modulate:a', 0.0, 0.5)
	await fade_tween.finished
	ControlsHint.visible = false

## UNDERGROUND LEVEL

var timer : SceneTreeTimer
var show_hint := false

func gun_jump_hint() -> void:
	var hint_box := GunJumpHint.get_child(0)
	hint_box.modulate.a = 0.0
	var fade_tween := create_tween()
	fade_tween.tween_property(hint_box, 'modulate:a', 1.0, 1.0)
	GunJumpHint.visible = true

func _on_area_2d_body_entered_corner(_body: CharacterBody2D) -> void:
	if show_hint:
		gun_jump_hint()
	else:
		timer = get_tree().create_timer(5.0)
		await timer.timeout
		
		if timer and not show_hint:
			show_hint = true
			gun_jump_hint()

func _on_area_2d_body_exited_corner(_body: CharacterBody2D) -> void:
	timer = null
	var hint_box := GunJumpHint.get_child(0)
	hint_box.modulate.a = 1.0
	var fade_tween := create_tween()
	fade_tween.tween_property(hint_box, 'modulate:a', 0.0, 0.5)
	await fade_tween.finished
	GunJumpHint.visible = false
