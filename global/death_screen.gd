extends CanvasLayer

func _ready():
	visible = false
	
func death_screen():
	visible = true
	
func _on_button_pressed():
	print("reload")
	Global.enemy_data = {}
	get_tree().get_first_node_in_group('Player').health = 100
	get_tree().reload_current_scene()
