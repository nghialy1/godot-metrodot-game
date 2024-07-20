extends Node

var current_music : String = 'MainMusic'
var songs: Dictionary
var wait_timer: SceneTreeTimer

func _ready() -> void:
	for song in get_children():
		songs[song.name] = song
		
	play_music(current_music)
		
func play_music(song_name: String) -> void:
	if song_name in songs:
		songs.get(current_music).stop()
		current_music = song_name
		var new_song: AudioStreamPlayer = songs.get(current_music)
		crescendo(new_song)

func toggle_pause() -> void:
	songs.get(current_music).stream_paused = not songs.get(current_music).stream_paused
		
func stop_music() -> void:
	songs.get(current_music).stop()

func crescendo(new_song : AudioStreamPlayer) -> void:
		var volume_setting := new_song.volume_db
		new_song.volume_db = volume_setting - 30
		new_song.play()
		var volume_tween := create_tween()
		volume_tween.tween_property(new_song, 'volume_db', volume_setting, 4).set_trans(Tween.TRANS_LINEAR)
		await volume_tween.finished

func get_wind_sound() -> AudioStreamPlayer:
	return $WindSound
