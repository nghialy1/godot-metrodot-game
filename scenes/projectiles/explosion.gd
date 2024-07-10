extends AnimatedSprite2D

func _ready():
	$AudioStreamPlayer.play()

func _on_animation_finished():
	queue_free()
