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
@export var locked := false
@onready var lock_scene = preload("res://scenes/objects/lock.tscn")
var levels = {}


func _ready():
	if not Engine.is_editor_hint():
		levels['station'] = "res://scenes/levels/station.tscn"
		levels['sky'] = "res://scenes/levels/sky.tscn"
		levels['underground'] = "res://scenes/levels/underground.tscn"

func _on_body_entered(body):
	if not locked:
		TransitionLayer.change_scene(levels[level])
	else:
		# try to unlock
		if 'items' in Global.player_data and 'key' in Global.player_data['items']:
			print(Global.player_data)
			Global.player_data['items'].erase('key')
			print(Global.player_data)
			locked = false
			
			# play unlock
			
			# await
			
			#transition
			TransitionLayer.change_scene(levels[level])
		else:
			# play lock on body
			var lock = lock_scene.instantiate()
			lock.position.y -= 20
			lock.position.x += 12
			body.add_child(lock)
			await lock.get_child(0).animation_finished
			lock.queue_free()

