extends Node2D

func _on_area_2d_body_entered(body):
	print(Global.player_data)
	Global.player_data['items'].append('key')
	queue_free()
