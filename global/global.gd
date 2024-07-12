extends Node

enum guns {AK, SHOTGUN, ROCKET}
const enemy_parameters = {
	'drone': {'speed': 120, 'health': 20, 'damage': 15},
	'soldier': {'speed': 50, 'health': 60},
	'monster': {'health': 240}
}

const gun_data = {
	guns.AK: {'damage': 20, 'speed': 200, 'texture': preload("res://graphics/guns/projectiles/default.png")},
	guns.ROCKET: {'damage': 60, 'speed': 120, 'texture': preload("res://graphics/guns/projectiles/large.png")},
	guns.SHOTGUN: {'damage': 30, 'range': 80},
}

var enemy_data: Dictionary

var player_data: Dictionary

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
