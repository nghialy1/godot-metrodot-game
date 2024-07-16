extends level_template

signal zone_entered()

@onready var boss := $Main/Entities/Enemies/Monster
@onready var boss_animation := $Main/Entities/Enemies/Monster/AnimationPlayer
var cutscene := false

func _ready() -> void:
	super._ready()
	boss.visible = false
	BgMusic.stop_music()
	
	if boss.health < Global.enemy_parameters['monster']['health']:
		$Area2D/CollisionShape2D.position = player.position
	
	if boss.has_signal('died'):
		boss.connect('died', on_boss_died)
	
	if boss.has_signal('entered_phase_two'):
		boss.connect('entered_phase_two', on_phase_two)
	
func _process(delta: float) -> void:
	super._process(delta)
	
	if cutscene and player.is_on_wall() and not $JumpWallsTimer.time_left:
		$JumpWallsTimer.start()
		player.jump = true

func on_phase_two() -> void:
	var phase_two_tween := create_tween()
	phase_two_tween.tween_property(cam, 'zoom', cam.zoom / 2, 3)
	await phase_two_tween.finished

# play game end cutscene
func on_boss_died() -> void:
	# cutscene mode
	player.god_mode = true
	BgMusic.stop_music()
	player.block_movement()
	cutscene = true
	disable_cam = true
	$Main/Entities/Players/Player/Crosshair.visible = false
	
	await boss_animation.animation_finished
	
	# player escapes
	
	$CutsceneCamera2D.zoom = cam.zoom
	$CutsceneCamera2D.limit_left = cam.limit_left
	$CutsceneCamera2D.limit_right = cam.limit_right
	$CutsceneCamera2D.limit_bottom = cam.limit_bottom
	$CutsceneCamera2D.limit_top = cam.limit_top

	player.toggle_cam()
	var end_tween := create_tween()
	end_tween.tween_property($CutsceneCamera2D, 'zoom', $CutsceneCamera2D.zoom + Vector2(2,2), 3)
	CustsceneLayer.cinematics()
	await end_tween.finished
	player.speed = player.speed / 2
	player.direction.x = 1
	await get_tree().create_timer(4).timeout
	
	# end game
	MenuScreen.end_screen()

func _on_area_2d_body_entered(_body: CharacterBody2D) -> void:
	$TransitionGates/TransitionGate.locked = true
	zone_entered.emit()
	$Area2D.set_deferred('monitoring', false)
	boss.visible = true
	BgMusic.play_music('BossMusic')
		
func _exit_tree() -> void:
	super._exit_tree()
	BgMusic.play_music('MainMusic')
