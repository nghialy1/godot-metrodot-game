extends level_template

@onready var boss := $Main/Entities/Monster
@onready var boss_animation := $Main/Entities/Monster/AnimationPlayer
@onready var player := get_tree().get_first_node_in_group('Player')

func _ready():
	super._ready()
	
	if boss.has_signal('died'):
		boss.connect('died', on_boss_died)
		
func on_boss_died():
	$'/root/BgMusic'.get_child(0).stop()
	player.block_movement()
	await boss_animation.animation_finished
	var end_tween = create_tween()
	end_tween.tween_property(cam, 'zoom', cam.zoom + Vector2(0.5,0.5), 3)
	await end_tween.finished
	player.direction.x = 1
	
