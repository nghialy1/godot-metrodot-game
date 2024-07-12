extends CanvasLayer

func _ready():
	visible = false
	
func cinematics():
	visible = true
	$AnimationPlayer.play("cinematic_zoom")
	
func reset():
	visible = false
	$AnimationPlayer.play_backwards("cinematic_zoom")

