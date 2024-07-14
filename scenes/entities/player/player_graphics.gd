extends Node2D

@onready var y_offset: int = get_parent().y_offset

func update_legs(direction: Vector2, on_floor: bool, ducking: bool) -> void:
	# flip 
	if direction.x:
		$Legs.flip_h = direction.x < 0
		
	# state
	var state := 'idle' if not ducking else 'duck'
	if on_floor and direction.x and not ducking:
		state = 'run'
	if not on_floor:
		state = 'jump'
	$Legs.animation = state
	
func update_torso(direction: Vector2, ducking: bool, current_gun: int) -> void:
	$AnimationTree.selected_gun = current_gun
	$Torso.position.y = y_offset if ducking else 0
	$AnimationTree['parameters/AK/blend_position'] = direction
	$AnimationTree["parameters/SHOTGUN/blend_position"] = direction
	$AnimationTree["parameters/ROCKET/blend_position"] = direction

func dash_particles(direction: Vector2) -> void:
	$DashParticles.process_material.set('direction', direction)
	$DashParticles.restart()
