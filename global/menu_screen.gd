extends CanvasLayer

var screens : Dictionary = {}
var current_screen : String = 'PauseScreen'
var active := false

func _ready() -> void:
	for child in get_children():
		if child is Control:
			child.visible = false
			screens[child.name] = child
			
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('pause') and current_screen == 'PauseScreen':
		toggle_pause()

func load_menu(screen: String) -> void:
	if screen in screens:
		current_screen = screen
		toggle_pause()
	
func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	if current_screen != 'DeathScreen' and current_screen != 'RetryScreen':
		BgMusic.toggle_pause()
	screens.get(current_screen).visible = not screens.get(current_screen).visible

func close_menu() -> void:
	screens.get(current_screen).visible = false
	get_tree().paused = false
	
func death_screen() -> void:
	BgMusic.play_music('DeathSound')
	load_menu('DeathScreen')
	$DeathScreen/AnimationPlayer.play("fade_to_black")
	
func retry_screen() -> void:
	BgMusic.play_music('DeathSound')
	load_menu('RetryScreen')
	$RetryScreen/AnimationPlayer.play("fade_to_black")

func end_screen() -> void:
	load_menu('EndScreen')
	$EndScreen/AnimationPlayer.play("fade_to_black")

func reset_game() -> void:
	get_tree().change_scene_to_file(ProjectSettings.get_setting('application/run/main_scene'))
	Global.reset_game_data()
	close_menu()
	current_screen = 'PauseScreen'
	
# BUTTONS
func _on_button_pressed() -> void:
	CustsceneLayer.reset()
	$DeathScreen/AnimationPlayer.play_backwards("fade_to_black")
	$EndScreen/AnimationPlayer.play_backwards("fade_to_black")
	reset_game()

func _on_button_2_pressed() -> void:
	get_tree().quit()

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
	Global.reset_game_data()
	close_menu()
	$RetryScreen/AnimationPlayer.play_backwards("fade_to_black")
	current_screen = 'PauseScreen'
