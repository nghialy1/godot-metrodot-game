extends CanvasLayer

func _ready() -> void:
	visible = false
	
func cinematics() -> void:
	visible = true
	$AnimationPlayer.play("cinematic_zoom")
	
func reset() -> void:
	visible = false
	$AnimationPlayer.play_backwards("cinematic_zoom")

