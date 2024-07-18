extends Entity

signal died()
signal entered_phase_two()
signal shoot_homing(pos: Vector2, target: CharacterBody2D, origin: CharacterBody2D)
signal shock_wave(pos: Vector2)

var breath_particles := preload("res://particles/breath_particles_2d.tscn")

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group('Player')
@onready var player_camera: Camera2D = player.get_cam()
@onready var cam_size_x := player_camera.get_viewport_rect().size.x / player_camera.zoom.x
@onready var cam_size_y := player_camera.get_viewport_rect().size.y / player_camera.zoom.y
@export var limits_x: Vector2i
@export var limits_y: Vector2i

var off_screen_offset := 55
var attack_wait_range := Vector2(0.8, 1.3)
var x_diff : float
var special_pos_x : float
var direction :=  Vector2.LEFT
var x_range := Vector2(-50,50)
var x_offset: float
var y_range := Vector2(-50,50)
var y_offset: float
var tracking_speed := 2.0
var tracking_weight : float
var rng := RandomNumberGenerator.new()
var phase_two := false
var can_move := false
var phase_two_animation := false
var special_move := false
var special_attack := false

signal detonate(pos: Vector2)

func _ready() -> void:
	health = Global.enemy_parameters['monster']['health']
	$CollisionShape2D.disabled  = true
	
	if 'zone_entered' in level:
		level.connect('zone_entered', on_entered)

func _process(_delta: float) -> void:
	# camera size
	cam_size_x = player_camera.get_viewport_rect().size.x / player_camera.zoom.x
	cam_size_y = player_camera.get_viewport_rect().size.y / player_camera.zoom.y
	
	# phase_two trigger
	if not phase_two and health <= Global.enemy_parameters['monster']['health'] * 0.60:
		start_phase_two()
	
	# Calculate monster position
	var x : float
	var y : float
	
	tracking_speed = 4.0 if x_diff > 150 else 1.0
	
	if phase_two and not phase_two_animation:
		set_flash_value(0.4, get_sprites(), Color.DARK_RED)
		if special_move:
			x = special_pos_x + x_offset
		else:
			x = move_toward(position.x, player.position.x + x_offset, tracking_speed)

		y = player.position.y - cam_size_y / 2 + 30
		y = max(limits_y.x, min(limits_y.y, y)) - off_screen_offset
	else:
		x = player.position.x + cam_size_x / 2 - 25
		y = player.position.y + y_offset
		x = max(limits_x.x, min(limits_x.y, x)) + off_screen_offset
		
	position = Vector2(x,y)
	
	x_diff = abs(position.x - player.position.x)

func start_phase_two() -> void:
	# phase two
	phase_two = true
	phase_two_animation = true
	invulnerable = true
	can_move = false
	$Timers/MoveTimer.wait_time = 0.2
	attack_wait_range = Vector2(0.5, 0.8)
	BgMusic.stop_music()

	# phase two animation
	$AnimationPlayer.play("enter_phase_two")
	var exit_tween := create_tween()
	exit_tween.tween_property(self, 'off_screen_offset', 100, 6)
	await exit_tween.finished
	
	# rest
	await get_tree().create_timer(4).timeout
	
	# change boundary as camera zooms out
	entered_phase_two.emit()
	var limit_tween := create_tween()
	var target_cam_size := Vector2(player_camera.get_viewport_rect().size.x / 1.75, player_camera.get_viewport_rect().size.y / 1.75)
	limit_tween.tween_property(self, 'limits_x:x', (target_cam_size.x/1.75 - 20) - player_camera.limit_left, 3)
	
	# orient boss to sky
	rotate(-PI/2)
	direction = Vector2.DOWN

	# wait for boss to move above player
	invulnerable = false
	phase_two_animation = false
	await get_tree().create_timer(1.5).timeout
	
	# re-enter from above
	var enter_tween := create_tween()
	enter_tween.tween_property(self, 'off_screen_offset', 0, 1.5)
	await enter_tween.finished
	
	# scream
	$AnimationPlayer.play("scream")
	await $AnimationPlayer.animation_finished
	
	$Timers/SpecialTimer.start()
	can_move = true

func scream_shockwave() -> void:
	shock_wave.emit(global_position)

func on_entered() -> void:
	player.block_movement() 
	$Sprite2D.visible = true
	$AnimationPlayer.play("entry")
	
	var entry_tween := create_tween()
	entry_tween.tween_property(self, 'off_screen_offset', 0, 3)
	await $AnimationPlayer.animation_finished
	
	# start battle
	$CollisionShape2D.disabled = false
	player.can_move = true
	can_move = true
	$AnimationPlayer.play("attack")

func return_to_idle() -> void:
	$AnimationPlayer.current_animation = 'idle'

func get_sprites() -> Array:
	return [$Sprite2D]
	
func emit_breath_particles() -> void:
	var breath := breath_particles.instantiate()
	breath.position.x += 15
	add_child(breath)

@warning_ignore("narrowing_conversion")
func explode() -> void:
	var rand_x := rng.randi_range(global_position.x - 20, global_position.x + 20)
	var rand_y := rng.randi_range(global_position.y - 20, global_position.y + 20)
	detonate.emit(Vector2(rand_x, rand_y))
	
func trigger_death() -> void:
	for timer in $Timers.get_children():
		timer.stop()
	
	$AnimationPlayer.current_animation = 'death'
	call_deferred("disable_collisions")
	died.emit()
	
func disable_collisions() -> void:
	$CollisionShape2D.disabled = true

func trigger_attack() -> void:
	var option_index := rng.randi_range(0, $BulletOptions.get_child_count() - 1)
	var selected := $BulletOptions.get_child(option_index)
	for marker in selected.get_children():
		shoot.emit(marker.global_position, direction, Global.guns.ROCKET, self)
		
	# if phase two also shoot two homing bullets
	if phase_two and not phase_two_animation:
		shoot_homing.emit($HomingBulletOptions/Marker2D.global_position, player, Vector2.LEFT, self)
		shoot_homing.emit($HomingBulletOptions/Marker2D2.global_position, player, Vector2.RIGHT, self)

func setup(data: Array) -> void:
	super.setup(data)
	
	# specific entity setup
	if dead:
		$AnimationPlayer.stop()
		$Sprite2D.visible = false

func _on_attack_timer_timeout() -> void:
	if phase_two and not x_diff < 50:
		$Timers/AttackTimer.start()
		pass
	
	if can_move:
		$AnimationPlayer.current_animation = 'attack'
		$Timers/AttackTimer.wait_time = rng.randf_range(attack_wait_range.x, attack_wait_range.y)
	$Timers/AttackTimer.start()

func _on_move_timer_timeout() -> void:
	var tween := create_tween()
	if not special_move and can_move:
		if phase_two:
			tween.tween_property(self, 'x_offset', rng.randf_range(x_range.x, x_range.y), 0.6)
		else:
			tween.tween_property(self, 'y_offset', rng.randf_range(y_range.x, y_range.y), 0.6)
	tween.tween_callback($Timers/MoveTimer.start)

func _on_special_timer_timeout() -> void:
	if phase_two:
		# scream
		special_pos_x = position.x
		special_move = true
		can_move = false
		$Timers/MoveTimer.stop()
		$AnimationPlayer.play("scream")
		await $AnimationPlayer.animation_finished
		
		# attack
		var binary := rng.randi() % 2
		var dir := -1 if binary else 1
		var special_tween1 := create_tween()
		special_tween1.tween_property(self, 'x_offset', dir * -300, 1)
		special_tween1.chain()
		await special_tween1.finished
		special_attack = true
		var special_tween2 := create_tween()
		special_tween2.tween_property(self, 'x_offset', dir * 300, 3)
		await special_tween2.finished
		special_attack = false
		
		# rest for 1.5 second
		await get_tree().create_timer(1).timeout
		
		# random time until next special
		$Timers/SpecialTimer.wait_time = rng.randi_range(9, 14)
		$Timers/SpecialTimer.start()
		$Timers/MoveTimer.start()
		can_move = true
		special_move = false

func _on_special_attack_timer_timeout() -> void:
	if special_attack:
		trigger_attack()
	$Timers/SpecialAttackTimer.start()
