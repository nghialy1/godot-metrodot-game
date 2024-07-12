extends level_template

@onready var boss := $Main/Entities/Monster
@onready var boss_animation := $Main/Entities/Monster/AnimationPlayer
var cutscene := false

func _ready():
	super._ready()
	
	if boss.has_signal('died'):
		boss.connect('died', on_boss_died)
	

func _process(delta):
	super._process(delta)
	
	if cutscene and player.is_on_wall() and not $JumpWallsTimer.time_left:
		$JumpWallsTimer.start()
		player.jump = true
		
# play game end cutscene
func on_boss_died():
	$'/root/BgMusic'.get_child(0).stop()
	player.block_movement()
	await boss_animation.animation_finished
	cutscene = true
	player.toggle_cam()
	disable_cam = true
	var end_tween = create_tween()
	end_tween.tween_property($CutsceneCamera2D, 'zoom', $CutsceneCamera2D.zoom + Vector2(1.5,1.5), 3)
	
	# player walks off screen and game ends
	CustsceneLayer.cinematics()
	await end_tween.finished
	player.speed = player.speed / 2
	player.direction.x = 1
	await get_tree().create_timer(4).timeout
	player.health = 0
	
	
