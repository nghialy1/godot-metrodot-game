extends Area2D

var path: Path2D
var path_follow: PathFollow2D
@export var speed := 100
@export var forward := true
@export var offset := 0

func _ready() -> void:
	path = get_children()[-1]
	path_follow = PathFollow2D.new()
	path.add_child(path_follow)
	path_follow.progress = offset
	
func _process(delta: float) -> void:
	path_follow.progress += speed * delta * (1 if forward else -1)
	position = path_follow.position

func _on_body_entered(body: CharacterBody2D) -> void:
	if 'hit' in body:
		body.hit(10, body.get_sprites())
