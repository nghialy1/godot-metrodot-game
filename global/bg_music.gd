extends Node

var current_music : String = 'MainMusic'
var songs: Dictionary

func _ready() -> void:
	for song in get_children():
		songs[song.name] = song
		
	songs.get(current_music).play()
		
func play_music(song_name: String) -> void:
	if song_name in songs:
		songs.get(current_music).stop()
		current_music = song_name
		var new_song: AudioStreamPlayer = songs.get(current_music)
		new_song.volume_db = -20
		new_song.play()
		
		var volume_tween := create_tween()
		volume_tween.tween_property(new_song, 'volume_db', 0, 4).set_trans(Tween.TRANS_LINEAR)
		
		
func toggle_pause() -> void:
	songs.get(current_music).stream_paused = not songs.get(current_music).stream_paused
		
func stop_music() -> void:
	songs.get(current_music).stop()
