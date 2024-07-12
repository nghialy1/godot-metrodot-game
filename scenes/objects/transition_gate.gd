@tool
extends Area2D

enum RETURN_MARKERS {left = 0, right = 1}
@export_enum('station', 'sky', 'underground') var level = 'sky'
@export var return_marker: RETURN_MARKERS:
	set(value):
		return_marker = value
		
		if get_child_count() > 0 and value != null:
			current_return = $ReturnMarkers.get_child(value)
			
			for marker in $ReturnMarkers.get_children():
				marker.visible = false
			current_return.visible = true # show new return
@export var current_return: Marker2D
var levels = {}

func _ready():
	if not Engine.is_editor_hint():
		levels['station'] = "res://scenes/levels/station.tscn"
		levels['sky'] = "res://scenes/levels/sky.tscn"
		levels['underground'] = "res://scenes/levels/underground.tscn"

func _on_body_entered(_body):
	TransitionLayer.change_scene(levels[level])
