extends Node2D

var hover_dist := 5

func _process(_delta: float) -> void:
	if not $HoverTimer.time_left:
		$HoverTimer.start()
		var hover_tween := create_tween()
		hover_dist = -hover_dist
		hover_tween.tween_property(self, 'position:y', position.y + hover_dist, 1).set_trans(Tween.TRANS_QUAD)

func _on_area_2d_body_entered(_player: CharacterBody2D) -> void:
	set_deferred("monitoring", false)
	Global.player_data['items'].append('key')
	$AnimationPlayer.play('acquired')
	await $AnimationPlayer.animation_finished
	
	queue_free()

func disable_collisions() -> void:
	$Area2D.monitoring = false

func acquired_sound() -> void:
	$AudioStreamPlayer2D.play()
