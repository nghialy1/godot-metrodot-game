extends CanvasLayer

var screens : Dictionary = {}
var current_screen : String = 'PauseScreen'
var active := false

func _ready():
	for child in get_children():
		if child is Control:
			child.visible = false
			screens[child.name] = child
			
func _process(_delta):
	if Input.is_action_just_pressed('pause') and current_screen == 'PauseScreen':
		toggle_pause()

func load_menu(screen: String):
	if screen in screens:
		current_screen = screen
		toggle_pause()
		$'/root/BgMusic'.get_child(0).stop()
	
func toggle_pause():
	screens.get(current_screen).visible = not screens.get(current_screen).visible
	get_tree().paused = not get_tree().paused

func close_menu():
	screens.get(current_screen).visible = false
	get_tree().paused = false
	
func _on_button_pressed():
	CustsceneLayer.reset()
	$EndScreen/AnimationPlayer.play_backwards("fade_to_black")
	reset_game()

func end_screen():
	load_menu('EndScreen')
	$EndScreen/AnimationPlayer.play("fade_to_black")

func reset_game():
	get_tree().change_scene_to_file(ProjectSettings.get_setting('application/run/main_scene'))
	Global.reset_game_data()
	$'/root/BgMusic'.get_child(0).play()
	close_menu()
	current_screen = 'PauseScreen'

func _on_button_2_pressed():
	get_tree().quit()
