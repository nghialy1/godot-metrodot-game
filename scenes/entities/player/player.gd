extends Entity

@export_group('move')
@export var speed := 200
@export var acceleration := 700
@export var friction := 900
@export_range(0.1,2) var dash_cooldown := 2
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
@export var crosshair_distance := 25
const y_offset := 10
const standing_height := 30
@export_range(0.2, 2.0) var ak_cooldown := 0.5
@export_range(0.2, 2.0) var shotgun_cooldown := 2
@export_range(0.2, 2.0) var rocket_cooldown := 4

func _ready():
	$Timers/DashCooldown.wait_time = dash_cooldown
	$Timers/AKReload.wait_time = ak_cooldown
	$Timers/ShotgunReload.wait_time = shotgun_cooldown
	$Timers/RocketReload.wait_time = rocket_cooldown

func _process(delta):
	apply_gravity(delta)
	
	if can_move:
		get_input()
	apply_movement(delta)
	animate()

func animate():
	$Crosshair.update(aim_direction, crosshair_distance, ducking)
	$PlayerGraphics.update_legs(direction, is_on_floor(), ducking)
	$PlayerGraphics.update_torso(aim_direction, ducking, current_gun)
	
func get_input():
	# horizontal movement 
	direction.x = Input.get_axis("left", "right")
	
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
	var aim_input_gamepad = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	var aim_input_mouse = get_local_mouse_position().normalized()
	var aim_input = aim_input_gamepad if gamepad_active else aim_input_mouse
	
	if aim_input.length() > 0.5:
		aim_direction = Vector2(round(aim_input.x), round(aim_input.y))
		
	# switch
	if Input.is_action_just_pressed("switch"):
		current_gun = Global.guns[Global.guns.keys()[(current_gun + 1) % len(Global.guns)]]
		
	if Input.is_action_just_pressed("shoot"):
		shoot_gun()
		
func _input(event):
	if event is InputEventMouseMotion:
		gamepad_active = false
	if Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down"):
		gamepad_active = true
	
func apply_movement(delta):
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
	
	var on_floor = is_on_floor()
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
		var dash_tween = create_tween()
		dash_tween.tween_property(self, 'velocity:x', direction.x * 600, 0.3)
		dash_tween.connect("finished", on_dash_finish)
		gravity_multiplier = 0
	
func apply_gravity(delta):
	velocity.y += gravity * delta
	velocity.y = velocity.y / 2 if faster_fall and velocity.y < 0 else velocity.y
	velocity.y = velocity.y * gravity_multiplier
	velocity.y = min(velocity.y, terminal_velocity)

func on_dash_finish():
	set_collision_layer_value(2, true)
	set_collision_mask_value(3, true)
	velocity.x = move_toward(velocity.x, 0, 500)
	gravity_multiplier = 1

func block_movement():
	can_move = false
	velocity = Vector2(0,0)
	direction = Vector2(0,0)

func hit(damage, nodes):
	if not $Timers/InvulTimer.time_left:
		health -= damage
		$Timers/InvulTimer.start()
		$Hit.play()
		flash(nodes)

func shoot_gun():
	var pos = position + aim_direction * crosshair_distance
	pos = pos if not ducking else pos + Vector2(0, y_offset)
	if current_gun == Global.guns.AK and not $Timers/AKReload.time_left:
		shoot.emit(pos, aim_direction, current_gun)
		$Timers/AKReload.start()
	if current_gun == Global.guns.SHOTGUN and not $Timers/ShotgunReload.time_left:
		shoot.emit(pos, aim_direction, current_gun)
		$Timers/ShotgunReload.start()
		$GPUParticles2D.position = $Crosshair.position
		$GPUParticles2D.process_material.set('direction', aim_direction)
		$GPUParticles2D.emitting = true
		
		if aim_direction.y == 1:
			gun_jump = true
	if current_gun == Global.guns.ROCKET and not $Timers/RocketReload.time_left:
		shoot.emit(pos, aim_direction, current_gun)
		$Timers/RocketReload.start()
		
func get_cam():
	return $Camera2D
	
func get_sprites():
	return [$PlayerGraphics/Legs, $PlayerGraphics/Torso]

#func trigger_death():
	#get_tree().quit()

func trigger_death():
	DeathScreen.death_screen()
