extends Entity

@export_group('move')
@export var speed := 200
@export var acceleration := 700
@export var friction := 900
@export_range(0.1,2.0) var dash_cooldown := 2.0
var direction := Vector2.ZERO
var can_move := true
var dash := false
var ducking := false
var gamepad_active := true

@export_group('jump')
@export var jump_strength := 300
@export var gun_jump_strength := 220
@export var gravity := 600
@export var terminal_velocity := 500
var jump := false
var faster_fall := false
var gravity_multiplier := 1
var gun_jump := false

@export_group("gun")
var current_gun := Global.guns.AK
var aim_direction := Vector2.RIGHT
var aim_input_mouse := Vector2.RIGHT
@export var crosshair_distance := 25
const y_offset := 10
const standing_height := 30
@export_range(0.2, 10.0) var ak_cooldown := 0.9
@export_range(0.2, 10.0) var shotgun_cooldown := 2.0
@export_range(0.2, 10.0) var rocket_cooldown := 5.0

var god_mode := false
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Timers/DashCooldown.wait_time = dash_cooldown
	$Timers/AKReload.wait_time = ak_cooldown
	$Timers/ShotgunReload.wait_time = shotgun_cooldown
	$Timers/RocketReload.wait_time = rocket_cooldown

func _process(delta: float) -> void:
	super._process(delta)
	
	if can_move:
		get_input()
	animate()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	apply_movement(delta)

func animate() -> void:
	$Crosshair.update(aim_direction, crosshair_distance, ducking, aim_input_mouse)
	$PlayerGraphics.update_legs(direction, is_on_floor(), ducking)
	$PlayerGraphics.update_torso(aim_direction, ducking, current_gun)
	
	if $Timers/InvulTimer.time_left and not $Timers/InvulTweenTimer.time_left:
		$Timers/InvulTweenTimer.start()
		
		for sprite: Node2D in get_sprites():
			var invul_tween: Tween = create_tween()
			invul_tween.tween_property(sprite, 'modulate:a', 0, 0.1)
			invul_tween.tween_property(sprite, 'modulate:a', 1, 0.1)

func get_input() -> void:
	# horizontal movement 
	direction.x = Input.get_axis("left", "right")
	
	if Input.is_action_just_pressed("shoot"):
		shoot_gun()
	
	# jump 
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or $Timers/Coyote.time_left:
			jump = true
		
		if velocity.y > 0 and not is_on_floor():
			$Timers/JumpBuffer.start()
		
	if Input.is_action_just_released("jump") and not is_on_floor() and velocity.y < 0:
		faster_fall = true

	# dash
	if Input.is_action_just_pressed("dash") and velocity.x and not $Timers/DashCooldown.time_left:
		dash = true
		$Timers/DashCooldown.start()
	
	# ducking
	ducking = Input.is_action_pressed("duck") and is_on_floor()
	
	# aim
	var aim_input_gamepad := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	aim_input_mouse = get_local_mouse_position()
	var aim_input := aim_input_gamepad if gamepad_active else aim_input_mouse.normalized()
	
	if aim_input.length() > 0.5:
		aim_direction = Vector2(aim_input.x, aim_input.y)
		
	# switch
	if Input.is_action_just_pressed("switch"):
		current_gun = Global.guns[Global.guns.keys()[(current_gun + 1) % len(Global.guns)]]
		
	if Input.is_action_just_pressed("god_mode"):
		god_mode = not god_mode
		
		var color_tween := create_tween()
		
		var start_value: float = $PlayerGraphics/Torso.material.get_shader_parameter('Progress')
		var target_value := 0.0 if not god_mode else 0.35
		color_tween.tween_method(set_flash_value.bind(get_sprites(), Color.GOLD),start_value,target_value, 0.2)
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		gamepad_active = false
	if Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down"):
		gamepad_active = true
	
func apply_movement(delta: float) -> void:
	if direction.x:
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)

		if is_on_floor() and not $Run.playing:
			$Run.play()
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		
	if ducking:
		velocity.x = 0
		# change collision shape and shift
		$CollisionShape2D.shape.height = standing_height - y_offset
		$CollisionShape2D.position.y = y_offset / 2.0
	else:
		$CollisionShape2D.shape.height = standing_height
		$CollisionShape2D.position.y = 0
		
	# jump 
	if jump or $Timers/JumpBuffer.time_left and is_on_floor():
		velocity.y = -jump_strength
		jump = false
		faster_fall = false
	
	# gun jump
	if gun_jump:
		velocity.y = -gun_jump_strength
		gun_jump = false
		faster_fall = false
	
	var on_floor := is_on_floor()
	move_and_slide()
	if on_floor and not is_on_floor() and velocity.y >= 0:
		$Timers/Coyote.start()
	
	# dash
	if dash:
		set_collision_layer_value(2, false)
		set_collision_mask_value(3, false)
		$Dash.play()
		dash = false
		$PlayerGraphics.dash_particles(direction)
		var dash_tween := create_tween()
		dash_tween.tween_property(self, 'velocity:x', direction.x * 600, 0.3)
		dash_tween.connect("finished", on_dash_finish)
		gravity_multiplier = 0
	
func apply_gravity(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.y = velocity.y / 2 if faster_fall and velocity.y < 0 else velocity.y
	velocity.y = velocity.y * gravity_multiplier
	velocity.y = min(velocity.y, terminal_velocity)

func on_dash_finish() -> void:
	velocity.x = move_toward(velocity.x, 0, 500)
	gravity_multiplier = 1
	await get_tree().create_timer(0.2).timeout
	set_collision_layer_value(2, true)
	set_collision_mask_value(3, true)

func block_movement() -> void:
	can_move = false
	velocity = Vector2(0,0)
	direction = Vector2(0,0)
	aim_direction = Vector2.RIGHT
	ducking = false

func hit(damage: int, nodes: Array) -> void:
	if not $Timers/InvulTimer.time_left and not god_mode:
		$Timers/InvulTimer.start()
		flash(nodes)
		health -= damage
		$Hit.play()
		await flash_tween.finished

func shoot_particles() -> void:
	$SmokeParticles.position = $Crosshair.position + aim_direction
	$SmokeParticles.process_material.set('direction', aim_direction)
	$SmokeParticles.restart()

func shoot_gun() -> void:
	var pos := position + aim_direction * crosshair_distance
	#pos = pos if not ducking else pos + Vector2(0, y_offset)
	var shooting_gun := current_gun
	
	$Crosshair.play('shoot')
	if shooting_gun == Global.guns.AK and not $Timers/AKReload.time_left:
		$Timers/AKReload.start()
		var num := 10 if god_mode else 3
		
		# shoot 3 bullets
		for i in range(num):
			var delay := rng.randf_range(0.1, 0.15)
			shoot.emit(pos, aim_direction, shooting_gun, self)
			await get_tree().create_timer(delay).timeout
			pos = position + aim_direction * crosshair_distance
			#pos = pos if not ducking else pos + Vector2(0, y_offset)
			
			shoot_particles()
	
	if shooting_gun == Global.guns.SHOTGUN and not $Timers/ShotgunReload.time_left:
		shoot.emit(pos, aim_direction, shooting_gun, self)
		$Timers/ShotgunReload.start()
		$ShotgunParticles.global_position = pos
		$ShotgunParticles.process_material.set('direction', aim_direction)
		$ShotgunParticles.emitting = true
		
		if aim_direction.y > 0.5:
			gun_jump = true
		shoot_particles()
	if shooting_gun == Global.guns.ROCKET and not $Timers/RocketReload.time_left:
		# shoot 3 bullets in succession
		$Timers/RocketReload.start()
		
		var num := 6 if god_mode else 2
		shoot_particles()
		
		# shoot 2 rockets
		for i in range(num):
			shoot.emit(pos, aim_direction, shooting_gun, self)
			await get_tree().create_timer(0.1).timeout
			pos = position + aim_direction * crosshair_distance
			#pos = pos if not ducking else pos + Vector2(0, y_offset)
			
		
func get_cam() -> Camera2D:
	return $Camera2D
	
func get_sprites() -> Array:
	return [$PlayerGraphics/Legs, $PlayerGraphics/Torso]

func toggle_cam() -> void:
	$Camera2D.enabled = !$Camera2D.enabled

func trigger_death() -> void:
	set_collision_layer_value(2, false)
	block_movement()
	if get_tree().current_scene.name == 'Sky' and get_tree().current_scene.boss.health < Global.enemy_parameters['monster']['health']:
		health = 250
		MenuScreen.retry_screen()
	else:
		MenuScreen.death_screen()
	
