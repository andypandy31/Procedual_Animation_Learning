extends Node2D

@export var segment_count : int = 20
@export var segment_length : float = 16.0
@export var follow_speed : float = 12.0

var points : Array[Vector2] = []

func _ready() -> void:
	for i in segment_count:
		points.append(global_position)

func _process(delta: float) -> void:
	var target = get_global_mouse_position()
	move_head(target, delta)
	resolve_chain()
	queue_redraw()

func move_head(target : Vector2, delta : float):
	points[0] = points[0].lerp(target, follow_speed * delta)

func resolve_chain():
	for i in range(1, points.size()):
		var dir = points[i] - points[i - 1]
		if dir.length() == 0:
			dir =Vector2.RIGHT
		dir = dir.normalized()
		points[i] = points[i - 1] + dir * segment_length
