extends Node

# persistence between scenes
var enemy_data: Dictionary
var player_data: Dictionary = {'items': []}
var transition_gate_data: Dictionary

func reset_game_data() -> void:
	enemy_data.clear()
	player_data = {'items': []}
	transition_gate_data.clear()

# weapon data
enum guns {AK, SHOTGUN, ROCKET}
const enemy_parameters = {
	'drone': {'speed': 110, 'health': 20, 'damage': 30},
	'soldier': {'speed': 80, 'health': 60},
	'monster': {'health': 3500}
}

const gun_data = {
	guns.AK: {'damage': 20, 'speed': 270, 'texture': preload("res://graphics/guns/projectiles/default.png")},
	guns.ROCKET: {'damage': 100, 'speed': 200, 'texture': preload("res://graphics/guns/projectiles/large.png")},
	guns.SHOTGUN: {'damage': 250, 'range': 70}
}

const special_bullet_data = {
	'homing_bullet': {'damage': 100, 'speed': 100}
}

# game sounds and music
const bullet_sounds = {
	guns.AK: preload("res://audio/ak_shoot.wav"),
	guns.SHOTGUN: preload("res://audio/shotgun_shoot.wav"),
	guns.ROCKET: preload("res://audio/rocket_shoot.wav")
}

const level_sounds = {
	'dash': preload("res://audio/dash.wav"),
	'music': preload("res://audio/music.mp3"),
	'explosion': preload("res://audio/explosion_medium.wav"),
	'hit': preload("res://audio/hit.ogg")
}
