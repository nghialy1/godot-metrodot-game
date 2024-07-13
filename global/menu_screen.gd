extends CanvasLayer

var screens : Dictionary = {}
var current_screen : String = "PauseScreen"
var active := false

func _ready():
	for child in get_children():
		if child is Control:
			child.visible = false
			screens[child.name] = child
			
func _process(_delta):
	if Input.is_action_just_pressed("pause") and current_screen == "PauseScreen":
		print("paused in menu")
		toggle_pause()
	
func load_menu(screen: String):
	print("change: ", screen)
	if screen in screens:
		current_screen = screen
		toggle_pause()
		$'/root/BgMusic'.get_child(0).stop()
	
func toggle_pause():
	screens.get(current_screen).visible = not screens.get(current_screen).visible
	get_tree().paused = not get_tree().paused

func _on_button_pressed():
	CustsceneLayer.reset()
	reset_game()
	toggle_pause()

func reset_game():
	get_tree().change_scene_to_file(ProjectSettings.get_setting('application/run/main_scene'))
	Global.enemy_data.clear()
	Global.player_data.clear()
	$'/root/BgMusic'.get_child(0).play()

func _on_button_2_pressed():
	get_tree().quit()
