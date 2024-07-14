@tool
extends Node2D

@export_enum('0', '1', '2', '3', '4', '5') var type := '0':
	set(value):
		type = value
		if get_child_count() > 0 and value != null:
			for child in $Options.get_children():
				child.hide()
			$Options.get_child(int(type)).show()
@export_color_no_alpha var color: Color = Color(1.0, 1.0, 1.0, 1.0):
	set(value):
		color = value
		
		if get_child_count() > 0 and value != null:
			#$Options.get_child(int(type)).get_child(1).color = value
			for child in $Options.find_children("*", "PointLight2D"):
				child.color = color
@export_range(0,10) var strength := 1.0:
	set(value):
		strength = value
		if get_child_count() > 0 and value != null:
			for child in $Options.find_children("*", "PointLight2D"):
					child.energy = value
@export_range(0,10) var radius := 1.0:
	set(value):
		radius = value
		
		if get_child_count() > 0 and value != null:
			$MainLight.texture_scale = value
@export_range(0,200) var flicker := 100.0

var noise := FastNoiseLite.new()
var value := 0.0
var active_light: PointLight2D

func _ready() -> void:
	for child in $Options.get_children():
		if child.visible:
			active_light = child.get_child(1)

func _process(delta: float) -> void:
	value += flicker * delta
	
	if active_light:
		active_light.energy = strength + strength * (noise.get_noise_1d(value) + 1 / 4.0) + 0.5
	
