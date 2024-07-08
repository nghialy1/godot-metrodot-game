@tool
extends Area2D

@export_enum('station', 'sky', 'underground') var level = 'sky'
var levels = {}

func _ready():
	if not Engine.is_editor_hint():
		levels['station'] = "res://scenes/levels/station.tscn"
		levels['sky'] = "res://scenes/levels/sky.tscn"
		levels['underground'] = "res://scenes/levels/underground.tscn"

func _on_body_entered(_body):
	TransitionLayer.change_scene(levels[level])
